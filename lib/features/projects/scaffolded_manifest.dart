import 'dart:convert';

import '../anonymization/operator.dart';
import '../detection/pii_span.dart';

/// `template_id` marking a Project (or personal template) created by the AI
/// upload→scaffold path (blueprint §6.2 "no match" branch). Carried so the UI can
/// badge it **AI-scaffolded** and keep it re-reviewable — it is *never* presented
/// as a Verified template (blueprint §15 #22).
const String aiScaffoldedTemplateId = 'ai_scaffolded';

/// Common PII labels the scaffold pre-loads into the default policy so the
/// Project is protective out of the box. The user reviews/edits these before the
/// document is redacted (no silent permission grants — §15 #18).
const List<String> _scaffoldLabels = <String>[
  PiiLabels.person,
  PiiLabels.email,
  PiiLabels.phone,
  PiiLabels.ssn,
  PiiLabels.creditCard,
  PiiLabels.dateOfBirth,
  PiiLabels.location,
  PiiLabels.mrn,
];

/// Composes a §6.1 Project manifest for the AI-scaffolded creation path
/// (blueprint §6.2 "no match"): conservative, deny-by-default permissions plus
/// the on-device-inferred [domain]. Pure for testability — mirrors
/// `composeBlankManifest`.
///
/// Conservative by design (privacy invariant — no permission a Verified template
/// wouldn't grant): `export` is **off**, `decode` is **biometric-gated**, content
/// `rewrite`/`expand` are **denied** (omitted ⇒ deny-by-default), and every
/// common PII label defaults to **redact**. The user reviews this before use and
/// can widen it in project settings.
String composeScaffoldedManifest({required String name, String? domain}) =>
    jsonEncode({
      'manifest_schema_version': 1,
      'template_id': aiScaffoldedTemplateId,
      'name': name,
      'domain': (domain == null || domain.trim().isEmpty)
          ? 'general'
          : domain.trim(),
      'permissions': {
        'read_documents': true,
        'detect_pii': true,
        'anonymize': true,
        'decode': 'requires_biometric',
        'export': false,
        'modify_project_settings': true,
      },
      'default_policy': {
        for (final l in _scaffoldLabels) l: Operator.redact.policyName,
      },
      'custom_entity_types': <dynamic>[],
    });
