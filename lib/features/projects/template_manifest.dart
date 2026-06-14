import 'dart:convert';

/// A verified Project-templates catalog (blueprint §6.3/§6.4), parsed from the
/// signed templates manifest body. Versioned like the model manifest.
class TemplateManifest {
  const TemplateManifest({
    required this.version,
    required this.signedAt,
    required this.templates,
  });

  final int version;
  final String signedAt;
  final List<TemplateDefinition> templates;

  factory TemplateManifest.fromJson(Map<String, dynamic> json) =>
      TemplateManifest(
        version: json['version'] as int,
        signedAt: json['signed_at'] as String? ?? '',
        templates: [
          for (final t in (json['templates'] as List<dynamic>? ?? const []))
            TemplateDefinition.fromJson((t as Map).cast<String, dynamic>()),
        ],
      );
}

/// One Verified Project template: a declarative §6.1 Project manifest plus
/// catalog metadata (description, category). [buildProjectManifestJson] turns it
/// into the `manifest_json` string consumed by `ProjectRepository.create`.
class TemplateDefinition {
  const TemplateDefinition(this._raw);

  /// The raw template entry from the manifest (kept whole so the §6.1 manifest
  /// fields — permissions, default_policy, custom_entity_types, persona — pass
  /// straight through to the created Project).
  final Map<String, dynamic> _raw;

  factory TemplateDefinition.fromJson(Map<String, dynamic> json) =>
      TemplateDefinition(json);

  String get templateId => _raw['template_id'] as String;
  String get name => _raw['name'] as String;
  String get description => _raw['description'] as String? ?? '';
  String? get domain => _raw['domain'] as String?;
  String? get minkPersona => _raw['mink_persona'] as String?;

  /// The default policy as a label→operator-name map (for a preview).
  Map<String, String> get defaultPolicy => {
    for (final e in ((_raw['default_policy'] as Map?) ?? const {}).entries)
      e.key as String: e.value as String,
  };

  /// The seeded custom-entity labels (for a preview).
  List<String> get customEntityLabels => [
    for (final c in (_raw['custom_entity_types'] as List<dynamic>? ?? const []))
      (c as Map)['label'] as String,
  ];

  /// Builds the §6.1 Project manifest JSON for [ProjectRepository.create],
  /// optionally overriding the Project name (the catalog `name` is the default).
  /// Catalog-only keys (`description`) are harmless — `ProjectManifest.fromJson`
  /// ignores unknown fields.
  String buildProjectManifestJson({String? projectName}) {
    final manifest = Map<String, dynamic>.of(_raw);
    manifest['manifest_schema_version'] = _raw['manifest_schema_version'] ?? 1;
    if (projectName != null) manifest['name'] = projectName;
    return jsonEncode(manifest);
  }
}
