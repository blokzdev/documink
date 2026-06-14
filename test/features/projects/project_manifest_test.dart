import 'package:documink/features/anonymization/operator.dart';
import 'package:documink/features/projects/project_manifest.dart';
import 'package:documink/features/projects/tool_permission_registry.dart';
import 'package:flutter_test/flutter_test.dart';

// The blueprint §6.1 example manifest (medical template).
const _medicalManifest = '''
{
  "manifest_schema_version": 1,
  "template_id": "medical",
  "name": "Medical Records 2026",
  "domain": "healthcare",
  "permissions": {
    "read_documents": true,
    "detect_pii": true,
    "anonymize": true,
    "decode": "requires_biometric",
    "rewrite_content": false,
    "export": true,
    "modify_project_settings": true,
    "cross_project_search": false
  },
  "default_policy": {
    "PERSON": "token_random",
    "MRN": "fpe",
    "DATE_OF_BIRTH": "redact"
  },
  "custom_entity_types": [
    { "label": "PROVIDER_NPI", "regex": "\\\\b\\\\d{10}\\\\b", "validator": "luhn_npi" }
  ],
  "mink_persona": "medical_records_conservative",
  "expected_file_types": ["pdf", "image"]
}
''';

void main() {
  group('ProjectManifest.parse', () {
    final manifest = ProjectManifest.parse(_medicalManifest);

    test('parses scalar fields', () {
      expect(manifest.schemaVersion, 1);
      expect(manifest.templateId, 'medical');
      expect(manifest.name, 'Medical Records 2026');
      expect(manifest.domain, 'healthcare');
      expect(manifest.minkPersona, 'medical_records_conservative');
      expect(manifest.expectedFileTypes, ['pdf', 'image']);
    });

    test('parses permission levels (bool / requires_biometric / missing)', () {
      final p = manifest.permissions;
      expect(p.level('read_documents'), PermissionLevel.granted);
      expect(p.level('decode'), PermissionLevel.requiresBiometric);
      expect(p.level('rewrite_content'), PermissionLevel.denied);
      expect(p.level('search_web'), PermissionLevel.denied); // absent
    });

    test('exposes default policy as an AnonymizationPolicy', () {
      expect(manifest.defaultPolicy.operatorFor('MRN'), Operator.fpe);
      expect(
        manifest.defaultPolicy.operatorFor('PERSON'),
        Operator.tokenRandom,
      );
    });

    test('keeps custom entity seeds raw (tolerates luhn_npi)', () {
      expect(manifest.customEntitySeeds.single['label'], 'PROVIDER_NPI');
      expect(manifest.customEntitySeeds.single['validator'], 'luhn_npi');
    });
  });

  group('ToolPermissionRegistry', () {
    const registry = ToolPermissionRegistry();
    final perms = ProjectManifest.parse(_medicalManifest).permissions;

    test('allows a granted tool', () {
      expect(
        registry.evaluate('detect_pii', perms),
        ToolPermissionDecision.allow,
      );
      expect(
        registry.evaluate('anonymize_document', perms),
        ToolPermissionDecision.allow,
      );
    });

    test('requires biometric for decode_token', () {
      expect(
        registry.evaluate('decode_token', perms),
        ToolPermissionDecision.allowWithBiometric,
      );
    });

    test('denies an ungranted tool', () {
      expect(
        registry.evaluate('rewrite_content', perms),
        ToolPermissionDecision.deny,
      );
    });

    test('read_documents grants the read-family tools', () {
      for (final t in [
        'search_documents',
        'list_entities',
        'summarize_document',
      ]) {
        expect(registry.evaluate(t, perms), ToolPermissionDecision.allow);
      }
    });

    test(
      'modify_project_settings gates create_custom_entity / modify_policy',
      () {
        expect(
          registry.evaluate('create_custom_entity', perms),
          ToolPermissionDecision.allow,
        );
        expect(
          registry.evaluate('modify_policy', perms),
          ToolPermissionDecision.allow,
        );
      },
    );

    test('denies an unknown tool (deny-by-default)', () {
      expect(registry.evaluate('rm_rf', perms), ToolPermissionDecision.deny);
    });

    test('granted-but-biometric permission forces a biometric gate', () {
      const perms = ProjectPermissions({
        'export': PermissionLevel.requiresBiometric,
      });
      expect(
        registry.evaluate('export_document', perms),
        ToolPermissionDecision.allowWithBiometric,
      );
    });
  });
}
