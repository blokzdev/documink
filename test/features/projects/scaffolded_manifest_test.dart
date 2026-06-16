import 'package:documink/features/anonymization/operator.dart';
import 'package:documink/features/projects/project_manifest.dart';
import 'package:documink/features/projects/scaffolded_manifest.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('composeScaffoldedManifest', () {
    test('parses as a valid §6.1 manifest with the ai_scaffolded id', () {
      final manifest = ProjectManifest.parse(
        composeScaffoldedManifest(name: 'Intake Notes', domain: 'healthcare'),
      );

      expect(manifest.schemaVersion, 1);
      expect(manifest.templateId, aiScaffoldedTemplateId);
      expect(manifest.name, 'Intake Notes');
      expect(manifest.domain, 'healthcare');
    });

    test('grants conservative, deny-by-default permissions', () {
      final m = ProjectManifest.parse(composeScaffoldedManifest(name: 'P'));

      // The functional minimum is granted...
      expect(m.permissions.isGranted('read_documents'), isTrue);
      expect(m.permissions.isGranted('detect_pii'), isTrue);
      expect(m.permissions.isGranted('anonymize'), isTrue);
      expect(m.permissions.isGranted('modify_project_settings'), isTrue);
      // ...decode is biometric-gated, not freely granted...
      expect(m.permissions.level('decode'), PermissionLevel.requiresBiometric);
      // ...and the riskier capabilities are denied (export off; no rewrite/expand).
      expect(m.permissions.isGranted('export'), isFalse);
      expect(m.permissions.isGranted('rewrite_content'), isFalse);
      expect(m.permissions.isGranted('expand_content'), isFalse);
    });

    test('redacts common PII labels by default', () {
      final m = ProjectManifest.parse(composeScaffoldedManifest(name: 'P'));

      expect(m.defaultPolicyOperators['PERSON'], Operator.redact);
      expect(m.defaultPolicyOperators['EMAIL'], Operator.redact);
      expect(m.defaultPolicyOperators['SSN'], Operator.redact);
      expect(m.defaultPolicyOperators, isNotEmpty);
    });

    test('falls back to a general domain when none is inferred', () {
      expect(
        ProjectManifest.parse(composeScaffoldedManifest(name: 'P')).domain,
        'general',
      );
      expect(
        ProjectManifest.parse(
          composeScaffoldedManifest(name: 'P', domain: '  '),
        ).domain,
        'general',
      );
    });

    test('seeds no custom entities (scaffold leaves that to the user)', () {
      final m = ProjectManifest.parse(composeScaffoldedManifest(name: 'P'));
      expect(m.customEntitySeeds, isEmpty);
    });
  });
}
