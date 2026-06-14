import 'package:documink/data/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Migration coverage for the schema v1 → v2 step (Phase 4c added the
/// `document_originals` table). The DB ships at v2, so we simulate a v1 database
/// (drop the v2 table, mark user_version = 1) and then run the real
/// `onUpgrade` callback, asserting the table is (re)created and existing rows
/// survive.
void main() {
  test('schemaVersion is 2', () {
    final db = AppDatabase(NativeDatabase.memory());
    expect(db.schemaVersion, 2);
    db.close();
  });

  test(
    'onUpgrade(1→2) creates document_originals and preserves data',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      // Seed a workspace (pre-existing v1 data we expect to survive).
      await db
          .into(db.workspaces)
          .insert(
            WorkspacesCompanion.insert(
              id: 'ws1',
              name: 'My Vault',
              createdAt: 0,
              kekVersion: 1,
            ),
          );

      // Simulate a v1 database: the new table doesn't exist yet.
      await db.customStatement('DROP TABLE document_originals');
      var tables = await _tableNames(db);
      expect(tables, isNot(contains('document_originals')));

      // Run the real migration callback for the 1 → 2 step.
      await db.migration.onUpgrade(db.createMigrator(), 1, 2);

      tables = await _tableNames(db);
      expect(tables, contains('document_originals'));

      // Pre-existing data is intact.
      final ws = await db.select(db.workspaces).get();
      expect(ws.single.id, 'ws1');
    },
  );
}

Future<Set<String>> _tableNames(AppDatabase db) async {
  final rows = await db
      .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
      .get();
  return rows.map((r) => r.read<String>('name')).toSet();
}
