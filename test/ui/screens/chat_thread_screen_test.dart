import 'package:documink/data/app_database.dart';
import 'package:documink/features/audit/audit_log_repository.dart';
import 'package:documink/features/chat/chat_providers.dart';
import 'package:documink/features/chat/chat_repository.dart';
import 'package:documink/features/detection/detection_pipeline.dart';
import 'package:documink/features/documents/document_repository.dart';
import 'package:documink/features/llm/llm_backend.dart';
import 'package:documink/features/memory/memory_guard.dart';
import 'package:documink/features/memory/memory_pii_scanner.dart';
import 'package:documink/features/memory/memory_repository.dart';
import 'package:documink/features/memory/memory_router.dart';
import 'package:documink/features/mink/context_assembler.dart';
import 'package:documink/features/mink/mink_providers.dart';
import 'package:documink/features/mink/mink_service.dart';
import 'package:documink/features/mink/tool_registry.dart';
import 'package:documink/features/projects/project_manifest.dart';
import 'package:documink/services/authenticator.dart';
import 'package:documink/services/database_providers.dart';
import 'package:documink/ui/screens/chat_thread_screen.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _Llm implements LlmBackend {
  _Llm(this.reply);
  final String reply;
  @override
  Future<bool> isAvailable() async => true;
  @override
  Future<String> generate(String prompt, {int maxOutputTokens = 512}) async =>
      reply;
}

class _Auth implements Authenticator {
  @override
  Future<bool> authenticate({required String reason}) async => true;
}

void main() {
  late AppDatabase db;
  late ChatRepository chat;

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
    chat = ChatRepository(db);
  });

  tearDown(() => db.close());

  MinkService realService(String reply) {
    final guard = const MemoryWriteGuard(
      MemoryPiiScanner(DetectionPipeline([])),
    );
    final router = MemoryRouter(MemoryRepository(db, guard));
    return MinkService(
      chat: chat,
      memoryRouter: router,
      tools: ToolRegistry(
        memoryRouter: router,
        documents: DocumentRepository(db),
      ),
      assembler: const ContextAssembler(),
      llm: _Llm(reply),
      audit: AuditLogRepository(db),
      authenticator: _Auth(),
    );
  }

  MinkTurnContext context({bool available = true}) => MinkTurnContext(
    workspaceId: 'ws_default',
    permissions: ProjectPermissions.fromJson(const {'read_documents': true}),
    tier: 'standard',
    variantId: 'balanced',
    modelId: 'gemma-test',
    available: available,
    unavailableReason: available ? null : 'On-device AI is not enabled.',
  );

  Widget app(String reply, {bool available = true}) => ProviderScope(
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
      minkServiceProvider.overrideWithValue(realService(reply)),
      minkTurnContextProvider.overrideWith(
        (ref) async => context(available: available),
      ),
    ],
    child: const MaterialApp(home: ChatThreadScreen(sessionId: 's1')),
  );

  Future<void> seedSessionS1() => db
      .into(db.chatSessions)
      .insert(
        ChatSessionsCompanion.insert(
          id: 's1',
          workspaceId: 'ws_default',
          createdAt: 0,
          updatedAt: 0,
          tierAtCreation: 'standard',
          variantAtCreation: 'balanced',
          modelIdAtCreation: 'gemma-test',
        ),
      );

  testWidgets('sending a message shows the user turn and Mink reply', (
    tester,
  ) async {
    await seedSessionS1();

    await tester.pumpWidget(app('Hello from Mink.'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'hi there');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pumpAndSettle();

    expect(find.text('hi there'), findsOneWidget);
    expect(find.text('Hello from Mink.'), findsOneWidget);
    expect(find.text('Report'), findsOneWidget);
  });

  testWidgets('masks token references and renders tool-call chips', (
    tester,
  ) async {
    await seedSessionS1();
    await chat.addMessage(
      sessionId: 's1',
      role: ChatRole.toolCall,
      content: '',
      toolCallJson: '{"tool":"search_documents","args":{}}',
      modelId: 'gemma-test',
    );
    await chat.addMessage(
      sessionId: 's1',
      role: ChatRole.toolResult,
      content: '',
      toolResultJson: '{"ok":true,"data":[]}',
      modelId: 'gemma-test',
    );
    await chat.addMessage(
      sessionId: 's1',
      role: ChatRole.mink,
      content: 'I found <<tok_01ABC>> in your files.',
      modelId: 'gemma-test',
    );

    await tester.pumpWidget(app('ignored'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Mink used'), findsOneWidget);
    // tool_result is not rendered as its own row.
    expect(find.textContaining('search_documents'), findsOneWidget);
    // The raw token marker never appears; a masked chip does.
    expect(find.textContaining('tok_01ABC'), findsNothing);
    expect(find.textContaining('⟨hidden⟩'), findsOneWidget);
  });

  testWidgets('unavailable Mink surfaces a banner instead of sending', (
    tester,
  ) async {
    await seedSessionS1();

    await tester.pumpWidget(app('unused', available: false));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'hi');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pumpAndSettle();

    expect(find.text('On-device AI is not enabled.'), findsOneWidget);
    expect(find.text('hi'), findsNothing); // not persisted
  });
}
