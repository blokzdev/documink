import '../documents/document_repository.dart';
import '../memory/memory_router.dart';

/// Scope a tool runs in: the workspace and (optionally) the active Project.
class ToolContext {
  const ToolContext({required this.workspaceId, this.projectId});

  final String workspaceId;
  final String? projectId;
}

/// The structured outcome of a tool execution, fed back to Mink as a
/// `tool_result` (PII-safe — repositories return ids/types/spans, never
/// plaintext; reversible reveals go through the biometric `decode_token` path).
class MinkToolOutcome {
  const MinkToolOutcome.ok(this.data) : isOk = true, error = null;
  const MinkToolOutcome.failure(this.error) : isOk = false, data = null;

  final bool isOk;
  final Object? data;
  final String? error;

  Map<String, dynamic> toJson() =>
      isOk ? {'ok': true, 'data': data} : {'ok': false, 'error': error};
}

/// Executes the tools Mink may call, delegating to existing services rather than
/// reimplementing them (blueprint §5). This build wires the memory tools (via the
/// deterministic [MemoryRouter]) and the read tools; permission + biometric gating
/// is enforced by the caller ([MinkService]) before `run` is reached.
///
/// Tools not wired here surface as a failed outcome ("not available in this
/// build") so Mink can react gracefully — they are added in a follow-up slice.
class ToolRegistry {
  ToolRegistry({
    required MemoryRouter memoryRouter,
    required DocumentRepository documents,
  }) : _memory = memoryRouter,
       _documents = documents;

  final MemoryRouter _memory;
  final DocumentRepository _documents;

  static const Set<String> memoryTools = {
    'remember',
    'recall_core',
    'recall_episodic',
    'forget',
  };

  /// Tools this build can actually execute.
  static const Set<String> wired = {
    ...memoryTools,
    'search_documents',
    'list_entities',
  };

  bool knows(String tool) => wired.contains(tool);

  Future<MinkToolOutcome> run(
    String tool,
    Map<String, dynamic> args,
    ToolContext ctx,
  ) async {
    if (memoryTools.contains(tool)) {
      final result = await _memory.dispatch(
        MemoryToolCall(tool, args),
        workspaceId: ctx.workspaceId,
        projectId: ctx.projectId,
      );
      return result.isOk
          ? MinkToolOutcome.ok(result.data)
          : MinkToolOutcome.failure(result.error);
    }

    switch (tool) {
      case 'search_documents':
        final docs = await _documents.listDocuments(projectId: ctx.projectId);
        return MinkToolOutcome.ok([
          for (final d in docs)
            {
              'id': d.id,
              'name': d.name,
              'type': d.type,
              'status': d.status,
              'created_at': d.createdAt,
            },
        ]);
      case 'list_entities':
        final docId = args['document_id'] as String?;
        if (docId == null || docId.isEmpty) {
          return const MinkToolOutcome.failure(
            'list_entities: "document_id" is required',
          );
        }
        final entities = await _documents.entitiesForDocument(docId);
        return MinkToolOutcome.ok([
          for (final e in entities)
            {
              'entity_type': e.entityType,
              'detector': e.detector,
              'operator': e.operatorApplied,
              'start': e.spanStart,
              'end': e.spanEnd,
              'confidence': e.confidence,
            },
        ]);
      default:
        return MinkToolOutcome.failure(
          'tool not available in this build: $tool',
        );
    }
  }
}

/// The tool catalog text injected into Mink's prompt — names, when to use each,
/// and the strict JSON call protocol. Kept in sync with [ToolRegistry.wired].
const String minkToolCatalog = '''
You can call tools to act on the user's vault. To call a tool, reply with ONLY a
single JSON object and nothing else: {"tool": "<name>", "args": { ... }}.
To answer the user directly, reply in plain text (no JSON).

Available tools:
- recall_core {}: your stable notes about the user/projects.
- recall_episodic {"limit": int?, "since": int?, "episode_type": string?}: recent events.
- remember {"type": "core"|"episodic", "scope": "global"?, ...}: store a memory.
    core: {"key": string, "value": any}. episodic: {"summary": string, "episode_type": string?}.
    NEVER put raw personal data in a memory — reference detected values as token refs.
- forget {"type": "core"|"episodic", "id": string}: delete a memory you created.
- search_documents {}: list documents in the current scope (ids, names, status).
- list_entities {"document_id": string}: detected entity types/spans for a document
    (types and positions only — never the underlying values).

After a tool runs you receive a tool_result; then either call another tool or
answer the user. Keep answers concise and reference values as <PERSON>, <EMAIL>,
etc. — never reveal decoded personal data in your replies.''';
