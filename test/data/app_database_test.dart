import 'package:documink/data/app_database.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Schema tests for V1 Phase 1a. These run against an in-memory executor so
/// they exercise the table/index/constraint definitions without needing the
/// keyed SQLCipher file path (that is covered by VaultService in Phase 1c, and
/// requires the encrypted native build, which may be unavailable on bare CI).
void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  // The 16 relational tables from blueprint §3.1 + §3.2. The `mink_embeddings`
  // vec0 virtual table is intentionally deferred to V1.2 (see ADR-018), so it
  // must NOT be present.
  const expectedTables = {
    'workspaces',
    'projects',
    'documents',
    'entities',
    'tokens',
    'custom_entity_types',
    'audit_log',
    'vault_meta',
    'sync_state',
    'chat_sessions',
    'chat_messages',
    'mink_core_memory',
    'mink_episodic_memory',
    'mink_semantic_memory',
    'mink_semantic_relationships',
    'mink_procedural_memory',
  };

  const expectedIndexes = {
    'idx_tokens_fingerprint',
    'idx_entities_document',
    'idx_chat_messages_session',
    'idx_episodic_time',
    'idx_semantic_fingerprint',
    'idx_semantic_parent',
    'idx_rel_from',
    'idx_rel_to',
  };

  Future<Set<String>> objectNames(String type) async {
    final rows = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = ? AND name NOT LIKE 'sqlite_%'",
          variables: [Variable<String>(type)],
        )
        .get();
    return rows.map((r) => r.read<String>('name')).toSet();
  }

  test('creates exactly the 16 relational tables (no vec0 table)', () async {
    final tables = await objectNames('table');
    expect(tables, containsAll(expectedTables));
    expect(tables, isNot(contains('mink_embeddings')));
    expect(
      tables.where((t) => !t.startsWith('__')),
      hasLength(expectedTables.length),
    );
  });

  test('creates all declared indexes', () async {
    final indexes = await objectNames('index');
    expect(indexes, containsAll(expectedIndexes));
  });

  test('foreign keys are enforced', () async {
    // projects.workspace_id references a non-existent workspace.
    expect(
      () => db
          .into(db.projects)
          .insert(
            ProjectsCompanion.insert(
              id: 'p1',
              workspaceId: 'missing-ws',
              name: 'Orphan',
              manifestJson: '{}',
              createdAt: 1,
              updatedAt: 1,
            ),
          ),
      throwsA(isA<SqliteException>()),
    );
  });

  test('self-referencing FK on mink_semantic_memory resolves', () async {
    await db
        .into(db.workspaces)
        .insert(
          WorkspacesCompanion.insert(
            id: 'ws1',
            name: 'Default',
            createdAt: 1,
            kekVersion: 1,
          ),
        );
    await db
        .into(db.minkSemanticMemory)
        .insert(
          MinkSemanticMemoryCompanion.insert(
            id: 'sem-root',
            workspaceId: 'ws1',
            entityType: 'PERSON',
            firstSeenAt: 1,
            lastSeenAt: 1,
            createdAt: 1,
            updatedAt: 1,
          ),
        );
    await db
        .into(db.minkSemanticMemory)
        .insert(
          MinkSemanticMemoryCompanion.insert(
            id: 'sem-child',
            workspaceId: 'ws1',
            entityType: 'PERSON',
            firstSeenAt: 1,
            lastSeenAt: 1,
            createdAt: 1,
            updatedAt: 1,
            parentId: const Value('sem-root'),
          ),
        );

    final child = await (db.select(
      db.minkSemanticMemory,
    )..where((t) => t.id.equals('sem-child'))).getSingle();
    expect(child.parentId, 'sem-root');

    // A dangling parent_id must be rejected by the self-referencing FK.
    expect(
      () => db
          .into(db.minkSemanticMemory)
          .insert(
            MinkSemanticMemoryCompanion.insert(
              id: 'sem-bad',
              workspaceId: 'ws1',
              entityType: 'PERSON',
              firstSeenAt: 1,
              lastSeenAt: 1,
              createdAt: 1,
              updatedAt: 1,
              parentId: const Value('does-not-exist'),
            ),
          ),
      throwsA(isA<SqliteException>()),
    );
  });

  test(
    'embedding_id accepts a value with no referenced table (vec0 deferred)',
    () async {
      await db
          .into(db.workspaces)
          .insert(
            WorkspacesCompanion.insert(
              id: 'ws1',
              name: 'Default',
              createdAt: 1,
              kekVersion: 1,
            ),
          );
      // embedding_id is a plain nullable TEXT with no FK, so an arbitrary value
      // is accepted even though mink_embeddings does not exist yet.
      await db
          .into(db.minkSemanticMemory)
          .insert(
            MinkSemanticMemoryCompanion.insert(
              id: 'sem1',
              workspaceId: 'ws1',
              entityType: 'CONCEPT',
              firstSeenAt: 1,
              lastSeenAt: 1,
              createdAt: 1,
              updatedAt: 1,
              embeddingId: const Value('emb-not-yet-a-real-row'),
            ),
          );
      final row = await db.select(db.minkSemanticMemory).getSingle();
      expect(row.embeddingId, 'emb-not-yet-a-real-row');
    },
  );

  test('unique(workspace_id, project_id, key) on mink_core_memory', () async {
    await db
        .into(db.workspaces)
        .insert(
          WorkspacesCompanion.insert(
            id: 'ws1',
            name: 'Default',
            createdAt: 1,
            kekVersion: 1,
          ),
        );
    await db
        .into(db.projects)
        .insert(
          ProjectsCompanion.insert(
            id: 'proj1',
            workspaceId: 'ws1',
            name: 'Medical',
            manifestJson: '{}',
            createdAt: 1,
            updatedAt: 1,
          ),
        );
    // A non-null project_id is used: under SQL semantics two rows with NULL
    // project_id are NOT considered equal by the UNIQUE constraint, so
    // global-scope (project_id IS NULL) uniqueness is enforced at the
    // repository layer (blueprint §3.3), not by this constraint.
    Future<void> insertCore(String id) => db
        .into(db.minkCoreMemory)
        .insert(
          MinkCoreMemoryCompanion.insert(
            id: id,
            workspaceId: 'ws1',
            projectId: const Value('proj1'),
            key: 'user_preferred_tone',
            valueJson: '"formal"',
            provenance: 'explicit_user_statement',
            createdAt: 1,
            updatedAt: 1,
          ),
        );
    await insertCore('core1');
    expect(() => insertCore('core2'), throwsA(isA<SqliteException>()));
  });

  test('blob columns round-trip', () async {
    await db
        .into(db.vaultMeta)
        .insert(
          VaultMetaCompanion.insert(
            key: 'argon2_salt',
            value: Uint8List.fromList([1, 2, 3, 4, 5]),
          ),
        );
    final row = await db.select(db.vaultMeta).getSingle();
    expect(row.value, [1, 2, 3, 4, 5]);
  });
}
