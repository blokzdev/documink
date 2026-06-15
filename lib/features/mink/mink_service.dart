import 'dart:convert';

import '../../data/id_generator.dart';
import '../audit/audit_event_type.dart';
import '../audit/audit_log_repository.dart';
import '../chat/chat_repository.dart';
import '../llm/llm_backend.dart';
import '../memory/memory_router.dart';
import '../projects/project_manifest.dart';
import '../projects/tool_permission_registry.dart';
import '../../services/authenticator.dart';
import 'context_assembler.dart';
import 'mink_tools.dart';
import 'tool_registry.dart';

/// The result of one user turn: Mink's final reply plus the tools it ran (for
/// the UI to render inline and for tests to assert on).
class ChatTurnResult {
  const ChatTurnResult({required this.reply, required this.toolsCalled});

  final String reply;
  final List<String> toolsCalled;
}

/// Mink's conversational orchestrator (blueprint §5). For each user turn it
/// assembles context (system + persona + tier-scaled memory + transcript),
/// generates with the on-device [LlmBackend], and runs a bounded tool loop:
/// parse a tool call → permission-gate (deny-by-default) → biometric-gate →
/// execute via [ToolRegistry] → audit (`mink_tool_call`) → feed the result back.
///
/// Pure-Dart and fully fake-testable: every dependency is an injected seam.
/// PII safety is inherited — `remember`/`forget` go only through [MemoryRouter]
/// (→ the write guard), never a direct table write.
class MinkService {
  MinkService({
    required ChatRepository chat,
    required MemoryRouter memoryRouter,
    required ToolRegistry tools,
    required ContextAssembler assembler,
    required LlmBackend llm,
    required AuditLogRepository audit,
    required Authenticator authenticator,
    ToolPermissionRegistry permissions = const ToolPermissionRegistry(),
    IdGenerator? idGenerator,
    DateTime Function()? clock,
    int maxToolIterations = 5,
  }) : _chat = chat,
       _memory = memoryRouter,
       _tools = tools,
       _assembler = assembler,
       _llm = llm,
       _audit = audit,
       _authenticator = authenticator,
       _permissions = permissions,
       _newId = idGenerator ?? defaultIdGenerator,
       _clock = clock ?? DateTime.now,
       _maxToolIterations = maxToolIterations;

  final ChatRepository _chat;
  final MemoryRouter _memory;
  final ToolRegistry _tools;
  final ContextAssembler _assembler;
  final LlmBackend _llm;
  final AuditLogRepository _audit;
  final Authenticator _authenticator;
  final ToolPermissionRegistry _permissions;
  final IdGenerator _newId;
  final DateTime Function() _clock;
  final int _maxToolIterations;

  /// `decode_token` authenticates + audits inside `RevealService` (the blessed
  /// reveal path); not wired in this build, but listed so the central biometric
  /// gate never double-prompts it once it is. (Logged in docs/DECISIONS.md.)
  static const Set<String> _selfGatingTools = {'decode_token'};

  Future<ChatTurnResult> sendMessage({
    required String sessionId,
    required String userText,
    required String workspaceId,
    String? projectId,
    required ProjectPermissions permissions,
    required String tier,
    required String modelId,
    String? persona,
    String? systemPromptAddendum,
  }) async {
    await _chat.addMessage(
      sessionId: sessionId,
      role: ChatRole.user,
      content: userText,
      modelId: modelId,
    );

    final ctx = ToolContext(workspaceId: workspaceId, projectId: projectId);
    final toolsCalled = <String>[];

    for (var i = 0; i <= _maxToolIterations; i++) {
      final prompt = await _assemble(
        sessionId: sessionId,
        ctx: ctx,
        tier: tier,
        persona: persona,
        systemPromptAddendum: systemPromptAddendum,
      );

      final completion = await _llm.generate(prompt);
      final invocation = parseToolInvocation(completion);

      // Plain reply → final answer.
      if (invocation == null || i == _maxToolIterations) {
        final reply = invocation == null
            ? completion.trim()
            : "I wasn't able to finish that — I kept needing tools. "
                  'Could you narrow it down?';
        await _chat.addMessage(
          sessionId: sessionId,
          role: ChatRole.mink,
          content: reply,
          modelId: modelId,
        );
        await _maybeCaptureEpisodic(ctx, tier, toolsCalled);
        return ChatTurnResult(reply: reply, toolsCalled: toolsCalled);
      }

      toolsCalled.add(invocation.name);
      await _chat.addMessage(
        sessionId: sessionId,
        role: ChatRole.toolCall,
        content: '',
        toolCallJson: jsonEncode({
          'tool': invocation.name,
          'args': invocation.args,
        }),
        modelId: modelId,
      );

      final outcome = await _runGated(
        invocation,
        ctx,
        permissions,
        workspaceId,
        projectId,
      );

      await _chat.addMessage(
        sessionId: sessionId,
        role: ChatRole.toolResult,
        content: '',
        toolResultJson: jsonEncode(outcome.toJson()),
        modelId: modelId,
      );
    }

    // Unreachable: the loop returns at i == _maxToolIterations.
    throw StateError('Mink tool loop exited without a reply');
  }

  Future<String> _assemble({
    required String sessionId,
    required ToolContext ctx,
    required String tier,
    String? persona,
    String? systemPromptAddendum,
  }) async {
    final core = await _recall('recall_core', const {}, ctx);
    final episodicLimit = _assembler.episodicLimitForTier(tier);
    final episodic = episodicLimit == 0
        ? const <Map<String, dynamic>>[]
        : await _recall('recall_episodic', {'limit': episodicLimit}, ctx);
    final history = await _chat.messagesForSession(sessionId);

    return _assembler.build(
      coreMemory: core,
      episodic: episodic,
      history: history,
      toolCatalog: minkToolCatalog,
      persona: persona,
      systemPromptAddendum: systemPromptAddendum,
    );
  }

  Future<List<Map<String, dynamic>>> _recall(
    String tool,
    Map<String, dynamic> args,
    ToolContext ctx,
  ) async {
    final result = await _memory.dispatch(
      MemoryToolCall(tool, args),
      workspaceId: ctx.workspaceId,
      projectId: ctx.projectId,
    );
    final data = result.data;
    if (!result.isOk || data is! List) return const [];
    return [
      for (final e in data)
        if (e is Map) e.cast<String, dynamic>(),
    ];
  }

  /// Permission- and biometric-gates a tool call, executes it on allow, and
  /// audits every outcome (allow / deny / biometric-fail) as `mink_tool_call`
  /// with PII-safe metadata (tool name + decision only).
  Future<MinkToolOutcome> _runGated(
    MinkToolInvocation inv,
    ToolContext ctx,
    ProjectPermissions permissions,
    String workspaceId,
    String? projectId,
  ) async {
    // Memory tools are always available: the deterministic, PII-guarded
    // MemoryRouter is their gate, not the project permission system
    // (memory.md §4). They are still executed via the registry and audited.
    if (ToolRegistry.memoryTools.contains(inv.name)) {
      final outcome = await _tools.run(inv.name, inv.args, ctx);
      await _recordToolCall(
        inv.name,
        workspaceId,
        projectId,
        success: outcome.isOk,
        metadata: {'decision': 'memory'},
      );
      return outcome;
    }

    final decision = _permissions.evaluate(inv.name, permissions);

    if (decision == ToolPermissionDecision.deny) {
      await _recordToolCall(
        inv.name,
        workspaceId,
        projectId,
        success: false,
        metadata: {'decision': 'deny'},
      );
      return MinkToolOutcome.failure(
        'Permission denied: "${inv.name}" is not allowed in this project.',
      );
    }

    String? biometricResult;
    if (decision == ToolPermissionDecision.allowWithBiometric &&
        !_selfGatingTools.contains(inv.name)) {
      final ok = await _authenticator.authenticate(
        reason: 'Authorize Mink to run "${inv.name}"',
      );
      biometricResult = ok ? 'passed' : 'failed';
      if (!ok) {
        await _recordToolCall(
          inv.name,
          workspaceId,
          projectId,
          success: false,
          biometricResult: biometricResult,
          metadata: {'decision': 'allow_with_biometric'},
        );
        return MinkToolOutcome.failure(
          'Biometric authentication was required for "${inv.name}" and was '
          'not completed.',
        );
      }
    }

    final outcome = await _tools.run(inv.name, inv.args, ctx);
    await _recordToolCall(
      inv.name,
      workspaceId,
      projectId,
      success: outcome.isOk,
      biometricResult: biometricResult,
      metadata: {'decision': decision.name},
    );
    return outcome;
  }

  Future<void> _recordToolCall(
    String toolName,
    String workspaceId,
    String? projectId, {
    required bool success,
    String? biometricResult,
    Map<String, dynamic>? metadata,
  }) {
    return _audit.record(
      id: _newId(),
      workspaceId: workspaceId,
      projectId: projectId,
      eventType: AuditEventType.minkToolCall,
      toolName: toolName,
      success: success,
      biometricResult: biometricResult,
      metadata: metadata,
      nowEpochMs: _clock().millisecondsSinceEpoch,
    );
  }

  /// Best-effort, tier-scaled episodic capture (memory.md §7): records a
  /// PII-safe summary of the tools used (never user content). Disabled at
  /// Minimum/floor; failures are swallowed so a turn never fails on capture.
  Future<void> _maybeCaptureEpisodic(
    ToolContext ctx,
    String tier,
    List<String> toolsCalled,
  ) async {
    if (toolsCalled.isEmpty) return;
    if (!ContextAssembler.episodicEnabledForTier(tier)) return;
    try {
      await _memory.dispatch(
        MemoryToolCall('remember', {
          'type': 'episodic',
          'episode_type': 'chat',
          'summary': 'Chat turn ran tools: ${toolsCalled.join(', ')}.',
        }),
        workspaceId: ctx.workspaceId,
        projectId: ctx.projectId,
      );
    } on Object {
      // Capture is best-effort; never fail the user's turn on it.
    }
  }
}
