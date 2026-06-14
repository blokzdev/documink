import '../anonymization/operator.dart';

/// Optional checksum validator applied to a custom-entity regex match
/// (roadmap §6: `luhn` | `none`). Filters false positives before a match
/// becomes a span.
enum CustomValidator {
  none('none'),
  luhn('luhn');

  const CustomValidator(this.id);

  final String id;

  static CustomValidator fromId(String? id) {
    if (id == null || id.isEmpty) return CustomValidator.none;
    return values.firstWhere(
      (v) => v.id == id,
      orElse: () => throw FormatException('Unknown validator: $id'),
    );
  }
}

/// A user-defined entity type (blueprint `custom_entity_types`, roadmap §6):
/// a label + regex + optional validator + a default operator. Workspace-global
/// when [projectId] is null, else Project-scoped.
class CustomEntityDefinition {
  const CustomEntityDefinition({
    required this.id,
    required this.workspaceId,
    this.projectId,
    required this.label,
    required this.regexPattern,
    this.validator = CustomValidator.none,
    this.examples = const [],
    required this.defaultOperator,
    required this.createdAtEpochMs,
  });

  final String id;
  final String workspaceId;
  final String? projectId;
  final String label;
  final String regexPattern;
  final CustomValidator validator;
  final List<String> examples;
  final Operator defaultOperator;
  final int createdAtEpochMs;
}
