import 'package:documink/data/app_database.dart';
import 'package:documink/features/anonymization/operator.dart';
import 'package:documink/features/custom_entities/custom_entity_definition.dart';
import 'package:documink/features/custom_entities/custom_entity_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late CustomEntityRepository repo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = CustomEntityRepository(db);
    // Satisfy the workspace_id / project_id foreign keys.
    await db
        .into(db.workspaces)
        .insert(
          WorkspacesCompanion.insert(
            id: 'ws',
            name: 'Test',
            createdAt: 0,
            kekVersion: 1,
          ),
        );
    for (final p in ['p1', 'p2']) {
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
  });
  tearDown(() async => db.close());

  CustomEntityDefinition def(String id, {String? projectId}) =>
      CustomEntityDefinition(
        id: id,
        workspaceId: 'ws',
        projectId: projectId,
        label: 'LABEL_$id',
        regexPattern: r'\d{16}',
        validator: CustomValidator.luhn,
        examples: const ['4111111111111111'],
        defaultOperator: Operator.fpe,
        createdAtEpochMs: 123,
      );

  test('round-trips all fields', () async {
    await repo.save(def('a'));
    final loaded = (await repo.listInScope('ws')).single;
    expect(loaded.label, 'LABEL_a');
    expect(loaded.regexPattern, r'\d{16}');
    expect(loaded.validator, CustomValidator.luhn);
    expect(loaded.examples, ['4111111111111111']);
    expect(loaded.defaultOperator, Operator.fpe);
  });

  test('scoping: global vs project', () async {
    await repo.save(def('global'));
    await repo.save(def('p1', projectId: 'p1'));
    await repo.save(def('p2', projectId: 'p2'));

    final globalOnly = await repo.listInScope('ws');
    expect(globalOnly.map((d) => d.id), ['global']);

    final inP1 = await repo.listInScope('ws', projectId: 'p1');
    expect(inP1.map((d) => d.id).toSet(), {'global', 'p1'});
    expect(inP1.map((d) => d.id), isNot(contains('p2')));
  });

  test('delete removes a definition', () async {
    await repo.save(def('a'));
    await repo.delete('a');
    expect(await repo.listInScope('ws'), isEmpty);
  });
}
