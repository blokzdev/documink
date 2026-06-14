import 'dart:convert';
import 'dart:typed_data';

import 'package:documink/data/app_database.dart';
import 'package:documink/features/audit/audit_event_type.dart';
import 'package:documink/features/custom_entities/custom_entity_definition.dart';
import 'package:documink/features/custom_entities/custom_entity_repository.dart';
import 'package:documink/features/documents/document_repository.dart';
import 'package:documink/features/projects/project_repository.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late ProjectRepository repo;
  var seq = 0;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    seq = 0;
    // Deterministic ids + a monotonically increasing clock so `updatedAt`
    // ordering is stable.
    repo = ProjectRepository(
      db,
      idGenerator: () => 'id_${seq++}',
      clock: () => DateTime.fromMillisecondsSinceEpoch(seq * 1000),
    );
  });

  tearDown(() async => db.close());

  String manifestJson({
    String template = 'medical',
    String name = 'Medical Records 2026',
    List<Map<String, dynamic>> seeds = const [],
  }) => jsonEncode({
    'manifest_schema_version': 1,
    'template_id': template,
    'name': name,
    'permissions': {'read_documents': true, 'decode': 'requires_biometric'},
    'default_policy': {'PERSON': 'token_random'},
    'custom_entity_types': seeds,
    'mink_persona': 'medical_records_conservative',
  });

  Future<List<AuditLogData>> auditOf(String eventType) => (db.select(
    db.auditLog,
  )..where((a) => a.eventType.equals(eventType))).get();

  test('create round-trips and lists as active at version 1', () async {
    final id = await repo.create(name: 'P1', manifestJson: manifestJson());

    final project = await repo.getById(id);
    expect(project, isNotNull);
    expect(project!.name, 'P1');
    expect(project.templateId, 'medical'); // from the manifest
    expect(project.manifestVersion, 1);
    expect(project.archived, 0);

    final active = await repo.listActive();
    expect(active.map((p) => p.id), [id]);

    final audit = await auditOf(AuditEventType.projectCreated);
    expect(audit.single.projectId, id);
    expect(audit.single.success, 1);
  });

  test('seeds manifest custom entities as Project-scoped rows', () async {
    final id = await repo.create(
      name: 'Med',
      manifestJson: manifestJson(
        seeds: [
          {
            'label': 'PROVIDER_NPI',
            'regex': r'\b\d{10}\b',
            'validator': 'luhn',
            'default_operator': 'fpe',
          },
          // Unsupported validator + missing operator → defensive fallbacks.
          {'label': 'WARD_CODE', 'regex': r'W-\d+', 'validator': 'luhn_npi'},
        ],
      ),
    );

    final entities = CustomEntityRepository(db);
    final scoped = await entities.listInScope(
      DocumentRepository.defaultWorkspaceId,
      projectId: id,
    );
    expect(scoped.map((e) => e.label).toSet(), {'PROVIDER_NPI', 'WARD_CODE'});

    final npi = scoped.firstWhere((e) => e.label == 'PROVIDER_NPI');
    expect(npi.validator, CustomValidator.luhn);
    expect(npi.defaultOperator.policyName, 'fpe');

    final ward = scoped.firstWhere((e) => e.label == 'WARD_CODE');
    expect(ward.validator, CustomValidator.none); // unsupported → none
    expect(ward.defaultOperator.policyName, 'redact'); // missing → redact

    // The seeds are Project-scoped, not workspace-global.
    final global = await entities.listInScope(
      DocumentRepository.defaultWorkspaceId,
    );
    expect(global, isEmpty);
  });

  test('updateManifest bumps version, persists, and audits', () async {
    final id = await repo.create(name: 'P', manifestJson: manifestJson());

    await repo.updateManifest(id, manifestJson(name: 'Renamed'));

    final project = await repo.getById(id);
    expect(project!.manifestVersion, 2);
    expect(jsonDecode(project.manifestJson)['name'], 'Renamed');

    final audit = await auditOf(AuditEventType.projectModified);
    expect(audit.single.projectId, id);
    expect(jsonDecode(audit.single.metadataJson!), {
      'fromVersion': 1,
      'toVersion': 2,
    });
  });

  test('updateManifest on a missing project throws', () async {
    expect(() => repo.updateManifest('nope', manifestJson()), throwsStateError);
  });

  test(
    'archive hides from listActive and is reversible, both audited',
    () async {
      final id = await repo.create(name: 'P', manifestJson: manifestJson());

      await repo.setArchived(id, true);
      expect(await repo.listActive(), isEmpty);
      expect((await repo.getById(id))!.archived, 1);

      await repo.setArchived(id, false);
      expect((await repo.listActive()).map((p) => p.id), [id]);

      final audit = await auditOf(AuditEventType.projectArchived);
      expect(audit.length, 2);
      expect(audit.map((a) => jsonDecode(a.metadataJson!)['archived']), [
        true,
        false,
      ]);
    },
  );

  test('listActive orders by updatedAt descending', () async {
    final a = await repo.create(name: 'A', manifestJson: manifestJson());
    final b = await repo.create(name: 'B', manifestJson: manifestJson());
    // Touch A so it becomes the most-recently-updated.
    await repo.updateManifest(a, manifestJson(name: 'A2'));

    final active = await repo.listActive();
    expect(active.map((p) => p.id), [a, b]);
  });

  group('document isolation (§6.7)', () {
    late DocumentRepository docs;

    setUp(() {
      docs = DocumentRepository(
        db,
        idGenerator: () => 'doc_${seq++}',
        clock: () => DateTime.fromMillisecondsSinceEpoch(seq * 1000),
      );
    });

    Future<void> insertDoc(String id, {String? projectId}) async {
      await db
          .into(db.documents)
          .insert(
            DocumentsCompanion.insert(
              id: id,
              workspaceId: DocumentRepository.defaultWorkspaceId,
              projectId: Value(projectId),
              name: id,
              type: 'text',
              sourceHash: Uint8List.fromList([1, 2, 3]),
              createdAt: 0,
              updatedAt: 0,
              status: 'redacted',
            ),
          );
    }

    test(
      'listDocuments filters by project; null shows the whole workspace',
      () async {
        final pA = await repo.create(name: 'A', manifestJson: manifestJson());
        final pB = await repo.create(name: 'B', manifestJson: manifestJson());
        await insertDoc('d_global');
        await insertDoc('d_a', projectId: pA);
        await insertDoc('d_b', projectId: pB);

        expect((await docs.listDocuments(projectId: pA)).map((d) => d.id), [
          'd_a',
        ]);
        expect((await docs.listDocuments(projectId: pB)).map((d) => d.id), [
          'd_b',
        ]);
        expect((await docs.listDocuments()).map((d) => d.id).toSet(), {
          'd_global',
          'd_a',
          'd_b',
        });
      },
    );
  });
}
