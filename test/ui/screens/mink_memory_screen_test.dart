import 'package:documink/data/app_database.dart';
import 'package:documink/features/detection/detection_pipeline.dart';
import 'package:documink/features/memory/memory_guard.dart';
import 'package:documink/features/memory/memory_pii_scanner.dart';
import 'package:documink/features/memory/memory_providers.dart';
import 'package:documink/features/memory/memory_repository.dart';
import 'package:documink/services/database_providers.dart';
import 'package:documink/ui/screens/mink_memory_screen.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late MemoryRepository repo;

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
    final guard = const MemoryWriteGuard(
      MemoryPiiScanner(DetectionPipeline([])),
    );
    repo = MemoryRepository(db, guard);
  });

  tearDown(() => db.close());

  Widget app() => ProviderScope(
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
      memoryRepositoryProvider.overrideWithValue(repo),
    ],
    child: const MaterialApp(home: MinkMemoryScreen()),
  );

  testWidgets('empty state when nothing is remembered', (tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    expect(find.text('Nothing remembered yet'), findsOneWidget);
  });

  testWidgets('lists core + episodic with provenance', (tester) async {
    await repo.writeCore(
      id: 'c1',
      workspaceId: 'ws_default',
      key: 'preferred_name',
      value: 'Dr. A',
      provenance: 'user',
      nowEpochMs: 0,
    );
    await repo.writeEpisodic(
      id: 'e1',
      workspaceId: 'ws_default',
      occurredAt: 0,
      summary: 'Redacted a lab report',
      episodeType: 'chat',
      nowEpochMs: 0,
    );

    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    expect(find.text('preferred_name'), findsOneWidget);
    expect(find.text('You told me'), findsOneWidget);
    expect(find.text('Redacted a lab report'), findsOneWidget);
    // SectionHeader upper-cases its title.
    expect(find.text('GLOBAL'), findsOneWidget);
  });

  testWidgets('deleting an entry removes it after confirmation', (
    tester,
  ) async {
    await repo.writeCore(
      id: 'c1',
      workspaceId: 'ws_default',
      key: 'preferred_name',
      value: 'Dr. A',
      provenance: 'user',
      nowEpochMs: 0,
    );

    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.delete_outline).first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Forget'));
    await tester.pumpAndSettle();

    expect(find.text('preferred_name'), findsNothing);
    expect(await repo.recallCore('ws_default'), isEmpty);
  });
}
