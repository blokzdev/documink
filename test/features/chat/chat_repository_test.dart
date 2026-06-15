import 'package:documink/data/app_database.dart';
import 'package:documink/features/chat/chat_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late ChatRepository repo;
  int n = 0;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db
        .into(db.workspaces)
        .insert(
          WorkspacesCompanion.insert(
            id: 'ws',
            name: 'W',
            createdAt: 0,
            kekVersion: 1,
          ),
        );
    for (final p in ['p1']) {
      await db
          .into(db.projects)
          .insert(
            ProjectsCompanion.insert(
              id: p,
              workspaceId: 'ws',
              name: p,
              manifestJson: '{}',
              createdAt: 0,
              updatedAt: 0,
            ),
          );
    }
    n = 0;
    repo = ChatRepository(
      db,
      idGenerator: () => 'id${n++}',
      clock: () => DateTime.fromMillisecondsSinceEpoch(n * 1000),
    );
  });

  tearDown(() => db.close());

  Future<String> session({String? projectId}) => repo.createSession(
    workspaceId: 'ws',
    projectId: projectId,
    tierAtCreation: 'standard',
    variantAtCreation: 'balanced',
    modelIdAtCreation: 'm',
  );

  test('messages persist in transcript order and bump updated_at', () async {
    final s = await session();
    final before = (await repo.listSessions()).single.updatedAt;

    await repo.addMessage(
      sessionId: s,
      role: ChatRole.user,
      content: 'hi',
      modelId: 'm',
    );
    await repo.addMessage(
      sessionId: s,
      role: ChatRole.mink,
      content: 'hello',
      modelId: 'm',
    );

    final msgs = await repo.messagesForSession(s);
    expect(msgs.map((m) => m.content), ['hi', 'hello']);

    final after = (await repo.listSessions()).single.updatedAt;
    expect(after, greaterThan(before));
  });

  test('listSessions isolates global vs project scope', () async {
    await session();
    await session(projectId: 'p1');

    final global = await repo.listSessions();
    final project = await repo.listSessions(projectId: 'p1');
    expect(global, hasLength(1));
    expect(global.single.projectId, isNull);
    expect(project, hasLength(1));
    expect(project.single.projectId, 'p1');
  });

  test('archived sessions are hidden by default', () async {
    final s = await session();
    await repo.archiveSession(s);

    expect(await repo.listSessions(), isEmpty);
    expect(await repo.listSessions(includeArchived: true), hasLength(1));
  });

  test('rename updates the title', () async {
    final s = await session();
    await repo.renameSession(s, 'Tax docs');
    expect((await repo.listSessions()).single.title, 'Tax docs');
  });
}
