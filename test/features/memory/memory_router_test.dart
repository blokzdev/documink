import 'package:documink/data/app_database.dart';
import 'package:documink/features/detection/detection_pipeline.dart';
import 'package:documink/features/detection/recognizers/email_recognizer.dart';
import 'package:documink/features/detection/recognizers/ssn_recognizer.dart';
import 'package:documink/features/memory/memory_guard.dart';
import 'package:documink/features/memory/memory_pii_scanner.dart';
import 'package:documink/features/memory/memory_repository.dart';
import 'package:documink/features/memory/memory_router.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late MemoryRouter router;
  var counter = 0;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    final guard = MemoryWriteGuard(
      MemoryPiiScanner(DetectionPipeline([EmailRecognizer(), SsnRecognizer()])),
    );
    counter = 0;
    router = MemoryRouter(
      MemoryRepository(db, guard),
      idGenerator: () => 'id${++counter}',
      clock: () => DateTime.fromMillisecondsSinceEpoch(5000),
    );
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
  });
  tearDown(() async => db.close());

  test('remember core then recall_core', () async {
    final wrote = await router.dispatch(
      const MemoryToolCall('remember', {
        'type': 'core',
        'key': 'tone',
        'value': 'formal',
      }),
      workspaceId: 'ws',
    );
    expect(wrote.isOk, isTrue);
    expect((wrote.data as Map)['id'], 'id1');

    final recalled = await router.dispatch(
      const MemoryToolCall('recall_core'),
      workspaceId: 'ws',
    );
    expect(recalled.isOk, isTrue);
    final list = recalled.data as List;
    expect(list.single['key'], 'tone');
    expect(list.single['value'], 'formal');
  });

  test('remember with unreferenced PII fails (and stores nothing)', () async {
    final result = await router.dispatch(
      const MemoryToolCall('remember', {
        'type': 'core',
        'key': 'c',
        'value': 'email me at a@b.com',
      }),
      workspaceId: 'ws',
    );
    expect(result.isOk, isFalse);
    expect(result.error, contains('token references'));

    final recalled = await router.dispatch(
      const MemoryToolCall('recall_core'),
      workspaceId: 'ws',
    );
    expect(recalled.data as List, isEmpty);
  });

  test('remember episodic then recall_episodic with limit', () async {
    await router.dispatch(
      const MemoryToolCall('remember', {
        'type': 'episodic',
        'summary': 'scanned 12 docs',
        'episode_type': 'scan',
        'occurred_at': 1000,
      }),
      workspaceId: 'ws',
    );
    await router.dispatch(
      const MemoryToolCall('remember', {
        'type': 'episodic',
        'summary': 'exported a PDF',
        'episode_type': 'export',
        'occurred_at': 2000,
      }),
      workspaceId: 'ws',
    );

    final recent = await router.dispatch(
      const MemoryToolCall('recall_episodic', {'limit': 1}),
      workspaceId: 'ws',
    );
    final list = recent.data as List;
    expect(list, hasLength(1));
    expect(list.single['summary'], 'exported a PDF'); // newest first
  });

  test('forget removes an entry', () async {
    await router.dispatch(
      const MemoryToolCall('remember', {
        'type': 'core',
        'key': 'k',
        'value': 'v',
      }),
      workspaceId: 'ws',
    );
    final del = await router.dispatch(
      const MemoryToolCall('forget', {'type': 'core', 'id': 'id1'}),
      workspaceId: 'ws',
    );
    expect(del.isOk, isTrue);
    final recalled = await router.dispatch(
      const MemoryToolCall('recall_core'),
      workspaceId: 'ws',
    );
    expect(recalled.data as List, isEmpty);
  });

  test('scope: global remember is visible without a project', () async {
    await router.dispatch(
      const MemoryToolCall('remember', {
        'type': 'core',
        'key': 'k',
        'value': 'g',
        'scope': 'global',
      }),
      workspaceId: 'ws',
      projectId: 'p1',
    );
    final recalled = await router.dispatch(
      const MemoryToolCall('recall_core'),
      workspaceId: 'ws',
    );
    expect((recalled.data as List).single['value'], 'g');
  });

  test('unknown tool yields a failure', () async {
    final r = await router.dispatch(
      const MemoryToolCall('nope'),
      workspaceId: 'ws',
    );
    expect(r.isOk, isFalse);
    expect(r.error, contains('unknown memory tool'));
  });
}
