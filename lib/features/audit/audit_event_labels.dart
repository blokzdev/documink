import 'audit_event_type.dart';

/// Renders a raw `audit_log.event_type` as a human-readable label, e.g.
/// `document_saved` → "Document saved", `mink_tool_call` → "Mink tool call".
///
/// Event types are canonical **data** identifiers (not UI chrome copy), so they
/// are prettified deterministically from the value rather than enumerated as
/// localized strings — the same way the app shows raw PII labels / operator
/// names elsewhere. The viewer's chrome (title, filters, actions) *is* localized.
String prettifyAuditEvent(String type) {
  if (type.isEmpty) return type;
  final words = type.split('_').where((w) => w.isNotEmpty).toList();
  if (words.isEmpty) return type;
  final first = words.first;
  final head = '${first[0].toUpperCase()}${first.substring(1)}';
  return [head, ...words.skip(1)].join(' ');
}

/// The audit event types offered in the viewer's type filter, grouped for
/// display (roadmap §15 "filterable by event type"). Includes both the
/// [AuditEventType] constants and the `document_*` literals recorded directly by
/// `DocumentRepository`. Order is presentation order.
const Map<String, List<String>> auditEventTypeGroups = {
  'documents': [
    'document_saved',
    'document_deleted',
    AuditEventType.documentOriginalRevealed,
    AuditEventType.export,
  ],
  'security': [
    AuditEventType.decode,
    AuditEventType.vaultUnlock,
    AuditEventType.biometricFailed,
  ],
  'ai': [
    AuditEventType.minkToolCall,
    AuditEventType.aiOutputReported,
    AuditEventType.suggestionOffered,
    AuditEventType.suggestionDismissed,
    AuditEventType.suggestionActioned,
    AuditEventType.tierChange,
    AuditEventType.variantChange,
    AuditEventType.modelInstall,
    AuditEventType.modelUninstall,
    AuditEventType.manifestUpdate,
  ],
  'projects': [
    AuditEventType.projectCreated,
    AuditEventType.projectModified,
    AuditEventType.projectArchived,
    AuditEventType.personalTemplateSaved,
    AuditEventType.personalTemplateDeleted,
  ],
  'sync': [AuditEventType.syncPush, AuditEventType.syncPull],
};

/// Flat list of every filterable event type (across all groups).
List<String> get auditFilterableEventTypes => [
  for (final group in auditEventTypeGroups.values) ...group,
];
