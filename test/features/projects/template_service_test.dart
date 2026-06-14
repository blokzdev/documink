import 'dart:convert';
import 'dart:io';

import 'package:documink/data/app_database.dart';
import 'package:documink/features/custom_entities/custom_entity_repository.dart';
import 'package:documink/features/documents/document_repository.dart';
import 'package:documink/features/projects/project_repository.dart';
import 'package:documink/features/projects/template_service.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// An [AssetBundle] that returns a fixed string for any key — feeds the shipped
/// (or a tampered) signed manifest to [TemplateService] without a real bundle.
class _StringBundle extends CachingAssetBundle {
  _StringBundle(this._payload);
  final String _payload;
  @override
  Future<ByteData> load(String key) async =>
      ByteData.sublistView(Uint8List.fromList(utf8.encode(_payload)));
}

void main() {
  // The shipped, signed templates catalog (read from disk, not via rootBundle).
  final signedJson = File(
    'assets/template_manifest/manifest.signed.json',
  ).readAsStringSync();

  TemplateService serviceFor(String payload) =>
      TemplateService(bundle: _StringBundle(payload));

  group('TemplateService', () {
    test('verifies + parses the 8 shipped Verified templates', () async {
      final templates = await serviceFor(signedJson).verifiedTemplates();
      expect(templates.map((t) => t.templateId), [
        'personal',
        'medical',
        'legal',
        'tax',
        'research',
        'creative',
        'engineering',
        'blank',
      ]);

      final medical = templates.firstWhere((t) => t.templateId == 'medical');
      expect(medical.name, 'Medical');
      expect(medical.domain, 'healthcare');
      expect(medical.minkPersona, 'medical_records_conservative');
      expect(medical.defaultPolicy['MRN'], 'fpe');
      expect(medical.customEntityLabels, ['PROVIDER_NPI']);
    });

    test('rejects a tampered body', () async {
      final outer = jsonDecode(signedJson) as Map<String, dynamic>;
      final tampered = jsonEncode({
        ...outer,
        'body': (outer['body'] as String).replaceFirst(
          '"version": 1',
          '"version": 2',
        ),
      });
      expect(
        () => serviceFor(tampered).verifiedManifest(),
        throwsA(isA<TemplateManifestException>()),
      );
    });

    test('rejects a tampered signature', () async {
      final outer = jsonDecode(signedJson) as Map<String, dynamic>;
      final sig = base64.decode(outer['signature'] as String);
      sig[0] ^= 0xff;
      final tampered = jsonEncode({...outer, 'signature': base64.encode(sig)});
      expect(
        () => serviceFor(tampered).verifiedManifest(),
        throwsA(isA<TemplateManifestException>()),
      );
    });

    test('rejects an unsupported algorithm', () async {
      final outer = jsonDecode(signedJson) as Map<String, dynamic>;
      final bad = jsonEncode({...outer, 'alg': 'rsa'});
      expect(
        () => serviceFor(bad).verifiedManifest(),
        throwsA(isA<TemplateManifestException>()),
      );
    });

    test('rejects non-JSON', () async {
      expect(
        () => serviceFor('not json').verifiedManifest(),
        throwsA(isA<TemplateManifestException>()),
      );
    });
  });

  group('TemplateDefinition.buildProjectManifestJson', () {
    test(
      'round-trips through the §6.1 parser with a renamed project',
      () async {
        final medical = (await serviceFor(
          signedJson,
        ).verifiedTemplates()).firstWhere((t) => t.templateId == 'medical');

        final json =
            jsonDecode(
                  medical.buildProjectManifestJson(projectName: 'My Records'),
                )
                as Map<String, dynamic>;
        expect(json['manifest_schema_version'], 1);
        expect(json['template_id'], 'medical');
        expect(json['name'], 'My Records'); // overridden
        expect((json['default_policy'] as Map)['MRN'], 'fpe');
      },
    );

    test(
      'creates a Project from a template, seeding its custom entities',
      () async {
        final db = AppDatabase(NativeDatabase.memory());
        addTearDown(db.close);
        final medical = (await serviceFor(
          signedJson,
        ).verifiedTemplates()).firstWhere((t) => t.templateId == 'medical');

        final id = await ProjectRepository(db).create(
          name: 'Records',
          templateId: medical.templateId,
          manifestJson: medical.buildProjectManifestJson(
            projectName: 'Records',
          ),
        );

        final project = await ProjectRepository(db).getById(id);
        expect(project!.templateId, 'medical');

        final seeded = await CustomEntityRepository(
          db,
        ).listInScope(DocumentRepository.defaultWorkspaceId, projectId: id);
        expect(seeded.map((e) => e.label), ['PROVIDER_NPI']);
        expect(seeded.single.defaultOperator.policyName, 'fpe');
      },
    );
  });
}
