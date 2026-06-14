import 'project_manifest.dart';

/// The required permission (and biometric flag) for a Mink tool (blueprint §5
/// tool table).
class ToolSpec {
  const ToolSpec(this.permission, {this.biometric = false});
  final String permission;
  final bool biometric;
}

/// Outcome of a tool-permission check (blueprint §5 dispatch flow).
enum ToolPermissionDecision {
  /// Allowed; run immediately.
  allow,

  /// Allowed only after a successful biometric gate.
  allowWithBiometric,

  /// Not permitted by the Project manifest — deny with a transparent message
  /// (and an audit `permission_denied` result).
  deny,
}

/// Maps Mink tool calls to the Project permission they require, and decides
/// whether a call is allowed under a Project's manifest (blueprint §5/§6.7).
/// Deny-by-default: unknown tools and ungranted permissions are denied.
class ToolPermissionRegistry {
  const ToolPermissionRegistry();

  static const Map<String, ToolSpec> tools = {
    'detect_pii': ToolSpec('detect_pii'),
    'anonymize_document': ToolSpec('anonymize'),
    'decode_token': ToolSpec('decode', biometric: true),
    'search_documents': ToolSpec('read_documents'),
    'list_entities': ToolSpec('read_documents'),
    'summarize_document': ToolSpec('read_documents'),
    'rewrite_content': ToolSpec('rewrite_content'),
    'expand_content': ToolSpec('expand_content'),
    'export_document': ToolSpec('export'),
    'create_custom_entity': ToolSpec('modify_project_settings'),
    'modify_policy': ToolSpec('modify_project_settings'),
  };

  ToolPermissionDecision evaluate(String toolName, ProjectPermissions perms) {
    final spec = tools[toolName];
    if (spec == null) return ToolPermissionDecision.deny;

    final level = perms.level(spec.permission);
    if (level == PermissionLevel.denied) return ToolPermissionDecision.deny;

    final needsBiometric =
        spec.biometric || level == PermissionLevel.requiresBiometric;
    return needsBiometric
        ? ToolPermissionDecision.allowWithBiometric
        : ToolPermissionDecision.allow;
  }
}
