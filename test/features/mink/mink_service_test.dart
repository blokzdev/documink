import 'dart:convert';
import 'dart:typed_data';

import 'package:documink/data/app_database.dart';
import 'package:documink/features/audit/audit_event_type.dart';
import 'package:documink/features/audit/audit_log_repository.dart';
import 'package:documink/features/chat/chat_repository.dart';
import 'package:documink/features/detection/detection_pipeline.dart';
import 'package:documink/features/detection/recognizers/email_recognizer.dart';
import 'package:documink/features/detection/recognizers/ssn_recognizer.dart';
import 'package:documink/features/documents/document_repository.dart';
import 'package:documink/features/llm/llm_backend.dart';
import 'package:documink/features/memory/memory_guard.dart';
import 'package:documink/features/memory/memory_pii_scanner.dart';
import 'package:documink/features/memory/memory_repository.dart';
import 'package:documink/features/memory/memory_router.dart';
import 'package:documink/features/mink/context_assembler.dart';
import 'package:documink/features/mink/mink_service.dart';
import 'package:documink/features/mink/tool_registry.dart';
import 'package:documink/features/projects/project_manifest.dart';
import 'package:documink/services/authenticator.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Returns the canned responses in order; repeats the last one if the loop
/// asks for more (so "always calls a tool" scripts are easy).
class ScriptedLlm implements LlmBackend {
  ScriptedLlm(this.responses);
  final List<String> responses;
  int calls = 0;

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<String> generate(String prompt, {int maxOutputTokens = 512}) async {
    final r = responses[calls.clamp(0, responses.length - 1)];
    calls++;
    return r;
  }
}

class FakeAuthenticator implements Authenticator {
  FakeAuthenticator(this.result);
  bool result;
  int calls = 0;

  @override
  Future<bool> authenticate({required String reason}) async {
    calls++;
    return result;
  }
}

String _toolCall(String name, [Map<String, dynamic> args = const {}]) =>
    jsonEncode({'tool': name, 'args': args});

void main() {
  late AppDatabase db;
  late ChatRepository chat;
  late MemoryRepository memoryRepo;
  late MemoryRouter router;
  late DocumentRepository documents;
  late AuditLogRepository audit;
  late FakeAuthenticator auth;

  // Distinct per-table counters keep PKs unique within a table.
  int chatN = 0, audN = 0, memN = 0;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db
        .into(db.workspaces)
        .insert(
          WorkspacesCompanion.insert(
            id: 'ws_default',
            name: 'W',
            createdAt: 0,
            kekVersion: 1,
          ),
        );

    chat = ChatRepository(
      db,
      idGenerator: () => 'c${chatN++}',
      clock: () => DateTime.fromMillisecondsSinceEpoch(chatN),
    );
    final guard = MemoryWriteGuard(
      MemoryPiiScanner(DetectionPipeline([EmailRecognizer(), SsnRecognizer()])),
    );
    memoryRepo = MemoryRepository(db, guard);
    router = MemoryRouter(memoryRepo, idGenerator: () => 'm${memN++}');
    documents = DocumentRepository(db);
    audit = AuditLogRepository(db);
    auth = FakeAuthenticator(true);
  });

  tearDown(() => db.close());

  MinkService build(ScriptedLlm llm, {int maxToolIterations = 5}) =>
      MinkService(
        chat: chat,
        memoryRouter: router,
        tools: ToolRegistry(memoryRouter: router, documents: documents),
        assembler: const ContextAssembler(),
        llm: llm,
        audit: audit,
        authenticator: auth,
        idGenerator: () => 'a${audN++}',
        maxToolIterations: maxToolIterations,
      );

  Future<String> newSession() => chat.createSession(
    workspaceId: 'ws_default',
    tierAtCreation: 'standard',
    variantAtCreation: 'balanced',
    modelIdAtCreation: 'test-model',
  );

  Future<void> insertDocument(String id, String name) => db
      .into(db.documents)
      .insert(
        DocumentsCompanion.insert(
          id: id,
          workspaceId: 'ws_default',
          name: name,
          type: 'text',
          sourceHash: Uint8List.fromList([1, 2, 3]),
          createdAt: 0,
          updatedAt: 0,
          status: 'redacted',
        ),
      );

  ProjectPermissions perms(Map<String, dynamic> json) =>
      ProjectPermissions.fromJson(json);

  Future<ChatTurnResult> send(
    MinkService mink,
    String sessionId,
    String text, {
    ProjectPermissions? permissions,
    String tier = 'standard',
  }) => mink.sendMessage(
    sessionId: sessionId,
    userText: text,
    workspaceId: 'ws_default',
    permissions: permissions ?? perms(const {}),
    tier: tier,
    modelId: 'test-model',
  );

  test('plain reply: no tools, transcript is user then mink', () async {
    final mink = build(ScriptedLlm(['You have no documents yet.']));
    final s = await newSession();

    final result = await send(mink, s, 'hi');

    expect(result.reply, 'You have no documents yet.');
    expect(result.toolsCalled, isEmpty);
    final msgs = await chat.messagesForSession(s);
    expect(msgs.map((m) => m.role), [ChatRole.user, ChatRole.mink]);
  });

  test('read tool then answer: dispatch, audit, transcript order', () async {
    await insertDocument('d1', 'Lab report');
    final mink = build(
      ScriptedLlm([_toolCall('search_documents'), 'You have 1 document.']),
    );
    final s = await newSession();

    final result = await send(
      mink,
      s,
      'what do I have?',
      permissions: perms({'read_documents': true}),
    );

    expect(result.reply, 'You have 1 document.');
    expect(result.toolsCalled, ['search_documents']);

    final msgs = await chat.messagesForSession(s);
    expect(msgs.map((m) => m.role), [
      ChatRole.user,
      ChatRole.toolCall,
      ChatRole.toolResult,
      ChatRole.mink,
    ]);
    final toolResult = jsonDecode(msgs[2].toolResultJson!) as Map;
    expect(toolResult['ok'], true);
    expect((toolResult['data'] as List).single['name'], 'Lab report');

    final events = await audit.query('ws_default');
    final call = events.firstWhere(
      (e) => e.eventType == AuditEventType.minkToolCall,
    );
    expect(call.toolName, 'search_documents');
    expect(call.success, isTrue);
  });

  test('permission denied: failed tool_result + audit deny', () async {
    final mink = build(
      ScriptedLlm([_toolCall('search_documents'), 'Okay, I cannot do that.']),
    );
    final s = await newSession();

    await send(mink, s, 'list docs', permissions: perms(const {}));

    final msgs = await chat.messagesForSession(s);
    final toolResult = jsonDecode(msgs[2].toolResultJson!) as Map;
    expect(toolResult['ok'], false);
    expect(toolResult['error'], contains('Permission denied'));

    final call = (await audit.query(
      'ws_default',
    )).firstWhere((e) => e.eventType == AuditEventType.minkToolCall);
    expect(call.success, isFalse);
    expect(call.metadata!['decision'], 'deny');
  });

  test('biometric required and passed: gate runs, outcome ok', () async {
    await insertDocument('d1', 'Doc');
    auth.result = true;
    final mink = build(ScriptedLlm([_toolCall('search_documents'), 'Done.']));
    final s = await newSession();

    await send(
      mink,
      s,
      'q',
      permissions: perms({'read_documents': 'requires_biometric'}),
    );

    expect(auth.calls, 1);
    final call = (await audit.query(
      'ws_default',
    )).firstWhere((e) => e.eventType == AuditEventType.minkToolCall);
    expect(call.success, isTrue);
    expect(call.biometricResult, 'passed');
  });

  test('biometric required and denied: tool blocked, audit failed', () async {
    auth.result = false;
    final mink = build(
      ScriptedLlm([_toolCall('search_documents'), 'Understood.']),
    );
    final s = await newSession();

    await send(
      mink,
      s,
      'q',
      permissions: perms({'read_documents': 'requires_biometric'}),
    );

    final msgs = await chat.messagesForSession(s);
    final toolResult = jsonDecode(msgs[2].toolResultJson!) as Map;
    expect(toolResult['ok'], false);
    expect(toolResult['error'], contains('Biometric'));

    final call = (await audit.query(
      'ws_default',
    )).firstWhere((e) => e.eventType == AuditEventType.minkToolCall);
    expect(call.success, isFalse);
    expect(call.biometricResult, 'failed');
  });

  test('memory tools bypass project permissions and persist', () async {
    final mink = build(
      ScriptedLlm([
        _toolCall('remember', {
          'type': 'core',
          'key': 'preferred_name',
          'value': 'Dr. A',
        }),
        'Saved that for you.',
      ]),
    );
    final s = await newSession();

    // No permissions granted at all — memory must still work.
    await send(
      mink,
      s,
      'remember my name is Dr. A',
      permissions: perms(const {}),
    );

    final core = await memoryRepo.recallCore('ws_default');
    expect(core.single.key, 'preferred_name');

    final call = (await audit.query(
      'ws_default',
    )).firstWhere((e) => e.eventType == AuditEventType.minkToolCall);
    expect(call.toolName, 'remember');
    expect(call.metadata!['decision'], 'memory');
  });

  test('memory write with unreferenced PII is rejected, not stored', () async {
    final mink = build(
      ScriptedLlm([
        _toolCall('remember', {
          'type': 'core',
          'key': 'contact',
          'value': 'email me at jane@example.com',
        }),
        'I cannot store that as-is.',
      ]),
    );
    final s = await newSession();

    await send(mink, s, 'remember my email', permissions: perms(const {}));

    expect(await memoryRepo.recallCore('ws_default'), isEmpty);
    final msgs = await chat.messagesForSession(s);
    final toolResult = jsonDecode(msgs[2].toolResultJson!) as Map;
    expect(toolResult['ok'], false);
    expect(toolResult['error'], contains('PII'));
  });

  test('tool loop is bounded and ends with a fallback reply', () async {
    // Always asks for a tool, never answers.
    final mink = build(
      ScriptedLlm([_toolCall('search_documents')]),
      maxToolIterations: 2,
    );
    final s = await newSession();

    final result = await send(
      mink,
      s,
      'loop',
      permissions: perms({'read_documents': true}),
    );

    expect(result.toolsCalled, hasLength(2));
    expect(result.reply, contains("wasn't able to finish"));
    final msgs = await chat.messagesForSession(s);
    expect(msgs.last.role, ChatRole.mink);
  });

  test('episodic capture is tier-scaled', () async {
    await insertDocument('d1', 'Doc');

    // Standard tier captures an episodic "chat" entry after a tool runs.
    final s1 = await newSession();
    await send(
      build(ScriptedLlm([_toolCall('search_documents'), 'Done.'])),
      s1,
      'q',
      permissions: perms({'read_documents': true}),
      tier: 'standard',
    );
    final afterStandard = await memoryRepo.recallEpisodic('ws_default');
    expect(afterStandard.where((e) => e.episodeType == 'chat'), isNotEmpty);

    // Minimum tier captures nothing.
    final before = (await memoryRepo.recallEpisodic('ws_default')).length;
    final s2 = await newSession();
    await send(
      build(ScriptedLlm([_toolCall('search_documents'), 'Done.'])),
      s2,
      'q',
      permissions: perms({'read_documents': true}),
      tier: 'minimum',
    );
    expect((await memoryRepo.recallEpisodic('ws_default')).length, before);
  });
}
