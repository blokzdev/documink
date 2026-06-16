import 'package:documink/data/app_database.dart';
import 'package:documink/features/audit/audit_event_type.dart';
import 'package:documink/features/audit/audit_log_repository.dart';
import 'package:documink/features/documents/document_repository.dart';
import 'package:documink/features/projects/personal_template.dart';
import 'package:documink/features/projects/personal_template_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late PersonalTemplateRepository repo;
  var seq = 0;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    seq = 0;
    repo = PersonalTemplateRepository(
      db,
      idGenerator: () => 'audit_${seq++}',
      clock: () => DateTime.fromMillisecondsSinceEpoch(seq * 1000),
    );
  });

  tearDown(() async => db.close());

  PersonalTemplate template({
    String id = 'pt_1',
    String name = 'My Intake',
    int createdAt = 100,
    PersonalTemplateOrigin origin = PersonalTemplateOrigin.aiScaffolded,
  }) => PersonalTemplate(
    id: id,
    name: name,
    manifestJson:
        '{"manifest_schema_version":1,"template_id":"ai_scaffolded",'
        '"name":"$name"}',
    createdAtEpochMs: createdAt,
    origin: origin,
  );

  test('save → getById round-trips every field', () async {
    final t = template();
    await repo.save(t);

    final loaded = await repo.getById('pt_1');
    expect(loaded, isNotNull);
    expect(loaded!.id, t.id);
    expect(loaded.name, t.name);
    expect(loaded.manifestJson, t.manifestJson);
    expect(loaded.createdAtEpochMs, t.createdAtEpochMs);
    expect(loaded.origin, PersonalTemplateOrigin.aiScaffolded);
  });

  test('getById returns null for an unknown id', () async {
    expect(await repo.getById('nope'), isNull);
  });

  test('save replaces an existing template by id (no duplicate)', () async {
    await repo.save(template(name: 'First'));
    await repo.save(template(name: 'Renamed'));

    final all = await repo.list();
    expect(all, hasLength(1));
    expect(all.single.name, 'Renamed');
  });

  test('list returns all templates, newest-created first', () async {
    await repo.save(template(id: 'a', name: 'Older', createdAt: 100));
    await repo.save(template(id: 'b', name: 'Newer', createdAt: 200));

    final all = await repo.list();
    expect(all.map((t) => t.id), ['b', 'a']);
  });

  test('handles a non-ASCII name (utf-8 round-trip)', () async {
    await repo.save(template(name: 'Médecin — dossiers'));
    expect((await repo.getById('pt_1'))!.name, 'Médecin — dossiers');
  });

  test('delete removes the template', () async {
    await repo.save(template());
    await repo.delete('pt_1');
    expect(await repo.getById('pt_1'), isNull);
    expect(await repo.list(), isEmpty);
  });

  test('save and delete are audited with the id only (no PII/body)', () async {
    await repo.save(template());
    await repo.delete('pt_1');

    final audit = AuditLogRepository(db);
    final saved = await audit.query(
      DocumentRepository.defaultWorkspaceId,
      eventTypes: [AuditEventType.personalTemplateSaved],
    );
    final deleted = await audit.query(
      DocumentRepository.defaultWorkspaceId,
      eventTypes: [AuditEventType.personalTemplateDeleted],
    );

    expect(saved, hasLength(1));
    expect(saved.single.metadata?['templateId'], 'pt_1');
    expect(saved.single.metadata?['origin'], 'aiScaffolded');
    // The manifest body never reaches the audit metadata.
    expect(saved.single.metadata.toString(), isNot(contains('manifest')));

    expect(deleted, hasLength(1));
    expect(deleted.single.metadata?['templateId'], 'pt_1');
  });
}
