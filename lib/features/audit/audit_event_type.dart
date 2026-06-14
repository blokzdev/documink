/// Canonical `audit_log.event_type` values (blueprint §3.1, roadmap §15).
/// Every privacy-relevant action records one of these (privacy-invariants #7).
class AuditEventType {
  const AuditEventType._();

  static const String decode = 'decode';
  static const String documentOriginalRevealed = 'document_original_revealed';
  static const String export = 'export';
  static const String syncPush = 'sync_push';
  static const String syncPull = 'sync_pull';
  static const String vaultUnlock = 'vault_unlock';
  static const String biometricFailed = 'biometric_failed';
  static const String minkToolCall = 'mink_tool_call';
  static const String suggestionOffered = 'suggestion_offered';
  static const String suggestionDismissed = 'suggestion_dismissed';
  static const String suggestionActioned = 'suggestion_actioned';
  static const String tierChange = 'tier_change';
  static const String variantChange = 'variant_change';
  static const String modelInstall = 'model_install';
  static const String modelUninstall = 'model_uninstall';
  static const String manifestUpdate = 'manifest_update';
  static const String projectCreated = 'project_created';
  static const String projectModified = 'project_modified';
  static const String projectArchived = 'project_archived';
}
