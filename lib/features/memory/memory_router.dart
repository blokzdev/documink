import 'dart:math';

import 'memory_guard.dart';
import 'memory_repository.dart';

/// A memory tool call emitted by Mink (name + params). The router maps these to
/// repository operations deterministically — no LLM involvement (memory.md §4).
class MemoryToolCall {
  const MemoryToolCall(this.name, [this.params = const {}]);

  final String name;
  final Map<String, dynamic> params;
}

/// The result handed back to Mink as a `tool_result`.
class MemoryToolResult {
  const MemoryToolResult.ok(this.data) : isOk = true, error = null;
  const MemoryToolResult.failure(this.error) : isOk = false, data = null;

  final bool isOk;
  final Object? data;
  final String? error;
}

/// The deterministic memory router (memory.md §4.1/§4.2): dispatches Mink's
/// memory tool calls to [MemoryRepository]. ~No LLM, fast, debuggable. Supported
/// tools: `remember`, `recall_core`, `recall_episodic`, `forget`.
///
/// A rejected write (unreferenced PII) surfaces as a failed [MemoryToolResult]
/// rather than throwing, so Mink can react ("I can't store that as-is…").
class MemoryRouter {
  MemoryRouter(
    this._repo, {
    String Function()? idGenerator,
    DateTime Function()? clock,
  }) : _newId = idGenerator ?? _defaultId,
       _clock = clock ?? DateTime.now;

  final MemoryRepository _repo;
  final String Function() _newId;
  final DateTime Function() _clock;

  Future<MemoryToolResult> dispatch(
    MemoryToolCall call, {
    required String workspaceId,
    String? projectId,
  }) async {
    try {
      switch (call.name) {
        case 'remember':
          return await _remember(call.params, workspaceId, projectId);
        case 'recall_core':
          return await _recallCore(call.params, workspaceId, projectId);
        case 'recall_episodic':
          return await _recallEpisodic(call.params, workspaceId, projectId);
        case 'forget':
          return await _forget(call.params);
        default:
          return MemoryToolResult.failure('unknown memory tool: ${call.name}');
      }
    } on MemoryPiiLeakError catch (e) {
      return MemoryToolResult.failure(e.message);
    } on ArgumentError catch (e) {
      return MemoryToolResult.failure(e.message.toString());
    }
  }

  Future<MemoryToolResult> _remember(
    Map<String, dynamic> p,
    String workspaceId,
    String? projectId,
  ) async {
    final type = p['type'] as String?;
    final effectiveProject = (p['scope'] == 'global') ? null : projectId;
    final now = _clock().millisecondsSinceEpoch;
    final id = _newId();

    switch (type) {
      case 'core':
        await _repo.writeCore(
          id: id,
          workspaceId: workspaceId,
          projectId: effectiveProject,
          key: p['key'] as String,
          value: p['value'],
          provenance: p['provenance'] as String? ?? 'mink',
          confidence: (p['confidence'] as num?)?.toDouble(),
          nowEpochMs: now,
        );
      case 'episodic':
        await _repo.writeEpisodic(
          id: id,
          workspaceId: workspaceId,
          projectId: effectiveProject,
          occurredAt: (p['occurred_at'] as int?) ?? now,
          summary: p['summary'] as String,
          details: p['details'],
          episodeType: p['episode_type'] as String? ?? 'note',
          tokenRefs: (p['token_refs'] as List<dynamic>?)?.cast<String>(),
          nowEpochMs: now,
        );
      default:
        return MemoryToolResult.failure('remember: unknown type "$type"');
    }
    return MemoryToolResult.ok({'id': id});
  }

  Future<MemoryToolResult> _recallCore(
    Map<String, dynamic> p,
    String workspaceId,
    String? projectId,
  ) async {
    final entries = await _repo.recallCore(workspaceId, projectId: projectId);
    return MemoryToolResult.ok([
      for (final e in entries)
        {
          'id': e.id,
          'key': e.key,
          'value': e.value,
          'provenance': e.provenance,
          'project_id': e.projectId,
        },
    ]);
  }

  Future<MemoryToolResult> _recallEpisodic(
    Map<String, dynamic> p,
    String workspaceId,
    String? projectId,
  ) async {
    final entries = await _repo.recallEpisodic(
      workspaceId,
      projectId: projectId,
      sinceEpochMs: p['since'] as int?,
      episodeType: p['episode_type'] as String?,
      limit: p['limit'] as int?,
    );
    return MemoryToolResult.ok([
      for (final e in entries)
        {
          'id': e.id,
          'occurred_at': e.occurredAt,
          'summary': e.summary,
          'episode_type': e.episodeType,
          'token_refs': e.tokenRefs,
        },
    ]);
  }

  Future<MemoryToolResult> _forget(Map<String, dynamic> p) async {
    final id = p['id'] as String;
    switch (p['type']) {
      case 'core':
        await _repo.forgetCore(id);
      case 'episodic':
        await _repo.forgetEpisodic(id);
      default:
        return MemoryToolResult.failure('forget: unknown type "${p['type']}"');
    }
    return MemoryToolResult.ok({'forgotten': id});
  }

  static final Random _random = Random();
  static String _defaultId() =>
      'mem_${DateTime.now().microsecondsSinceEpoch}_${_random.nextInt(1 << 32)}';
}
