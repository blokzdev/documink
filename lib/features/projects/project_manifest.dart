import 'dart:convert';

import '../anonymization/anonymization_policy.dart';
import '../anonymization/operator.dart';

/// Grant level for a single Project permission (blueprint §6.1). A permission is
/// either off, on, or on-but-biometric-gated (e.g. `decode`).
enum PermissionLevel { denied, granted, requiresBiometric }

/// The `permissions` block of a Project manifest. Unknown/absent keys default to
/// [PermissionLevel.denied] (deny-by-default; project-isolation invariant).
class ProjectPermissions {
  const ProjectPermissions(this._levels);

  final Map<String, PermissionLevel> _levels;

  PermissionLevel level(String permission) =>
      _levels[permission] ?? PermissionLevel.denied;

  bool isGranted(String permission) =>
      level(permission) != PermissionLevel.denied;

  factory ProjectPermissions.fromJson(Map<String, dynamic> json) =>
      ProjectPermissions({
        for (final entry in json.entries) entry.key: _parseLevel(entry.value),
      });

  static PermissionLevel _parseLevel(Object? value) {
    if (value == true) return PermissionLevel.granted;
    if (value == 'requires_biometric') return PermissionLevel.requiresBiometric;
    return PermissionLevel.denied;
  }
}

/// A declarative Project configuration (blueprint §6.1), stored in
/// `projects.manifest_json` and versioned. Defines the Project's permissions,
/// default anonymization policy, seed custom entities, and Mink persona.
class ProjectManifest {
  const ProjectManifest({
    required this.schemaVersion,
    required this.templateId,
    required this.name,
    this.domain,
    required this.permissions,
    required this.defaultPolicyOperators,
    this.customEntitySeeds = const [],
    this.minkPersona,
    this.minkSystemPromptAddendum,
    this.expectedFileTypes = const [],
  });

  final int schemaVersion;
  final String templateId;
  final String name;
  final String? domain;
  final ProjectPermissions permissions;

  /// `default_policy` as label→operator. Use [defaultPolicy] for an applyable
  /// [AnonymizationPolicy].
  final Map<String, Operator> defaultPolicyOperators;

  /// Raw `custom_entity_types` seeds (applied with assigned ids at project
  /// creation; kept raw to tolerate manifest-only validators like `luhn_npi`).
  final List<Map<String, dynamic>> customEntitySeeds;

  final String? minkPersona;
  final String? minkSystemPromptAddendum;
  final List<String> expectedFileTypes;

  /// The manifest's default policy as an applyable [AnonymizationPolicy].
  AnonymizationPolicy get defaultPolicy =>
      AnonymizationPolicy(Map.of(defaultPolicyOperators));

  factory ProjectManifest.fromJson(
    Map<String, dynamic> json,
  ) => ProjectManifest(
    schemaVersion: json['manifest_schema_version'] as int,
    templateId: json['template_id'] as String,
    name: json['name'] as String,
    domain: json['domain'] as String?,
    permissions: ProjectPermissions.fromJson(
      (json['permissions'] as Map?)?.cast<String, dynamic>() ?? const {},
    ),
    defaultPolicyOperators: {
      for (final e in ((json['default_policy'] as Map?) ?? const {}).entries)
        e.key as String: Operator.fromPolicyName(e.value as String),
    },
    customEntitySeeds: [
      for (final c in (json['custom_entity_types'] as List<dynamic>? ?? []))
        (c as Map).cast<String, dynamic>(),
    ],
    minkPersona: json['mink_persona'] as String?,
    minkSystemPromptAddendum: json['mink_system_prompt_addendum'] as String?,
    expectedFileTypes: [
      for (final t in (json['expected_file_types'] as List<dynamic>? ?? []))
        t as String,
    ],
  );

  static ProjectManifest parse(String jsonString) =>
      ProjectManifest.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
}
