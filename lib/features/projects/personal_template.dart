import 'dart:convert';

/// How a [PersonalTemplate] came to be (blueprint §6.5). Saved either from an
/// AI-scaffolded Project or from a Project the user customized — both are **local
/// user data**, never Verified templates.
enum PersonalTemplateOrigin {
  aiScaffolded,
  customized;

  static PersonalTemplateOrigin fromName(String? name) =>
      PersonalTemplateOrigin.values.firstWhere(
        (o) => o.name == name,
        orElse: () => PersonalTemplateOrigin.customized,
      );
}

/// A user's saved Project template ("Yours" in the picker — blueprint §6.5). It
/// wraps a §6.1 Project [manifestJson] so creating from it reuses the same
/// `ProjectRepository.create` path as a Verified template. Stored locally in
/// `vault_meta`; CRDT sync is deferred (V3).
class PersonalTemplate {
  const PersonalTemplate({
    required this.id,
    required this.name,
    required this.manifestJson,
    required this.createdAtEpochMs,
    this.origin = PersonalTemplateOrigin.customized,
  });

  final String id;
  final String name;
  final String manifestJson;
  final int createdAtEpochMs;
  final PersonalTemplateOrigin origin;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'manifest_json': manifestJson,
    'created_at': createdAtEpochMs,
    'origin': origin.name,
  };

  factory PersonalTemplate.fromJson(Map<String, dynamic> json) =>
      PersonalTemplate(
        id: json['id'] as String,
        name: json['name'] as String,
        manifestJson: json['manifest_json'] as String,
        createdAtEpochMs: json['created_at'] as int,
        origin: PersonalTemplateOrigin.fromName(json['origin'] as String?),
      );

  String encode() => jsonEncode(toJson());

  factory PersonalTemplate.decode(String raw) =>
      PersonalTemplate.fromJson(jsonDecode(raw) as Map<String, dynamic>);
}
