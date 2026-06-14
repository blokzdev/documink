import 'dart:convert';

import 'package:drift/drift.dart';

import '../../data/app_database.dart';

/// A single audit-log record (blueprint §3.1). Carries IDs/token-refs and
/// metadata only — **never raw PII** (the caller is responsible for keeping
/// plaintext out of [metadata]).
class AuditEntry {
  const AuditEntry({
    required this.id,
    required this.workspaceId,
    this.projectId,
    required this.eventType,
    this.documentId,
    this.entityId,
    this.toolName,
    required this.success,
    this.biometricResult,
    this.metadata,
    required this.createdAt,
  });

  final String id;
  final String workspaceId;
  final String? projectId;
  final String eventType;
  final String? documentId;
  final String? entityId;
  final String? toolName;
  final bool success;
  final String? biometricResult;
  final Map<String, dynamic>? metadata;
  final int createdAt;
}

/// Append-only audit trail (roadmap §15). Records every privacy-relevant action
/// and supports filtered, paginated reads plus CSV export.
class AuditLogRepository {
  AuditLogRepository(this._db);

  final AppDatabase _db;

  Future<void> record({
    required String id,
    required String workspaceId,
    String? projectId,
    required String eventType,
    String? documentId,
    String? entityId,
    String? toolName,
    required bool success,
    String? biometricResult,
    Map<String, dynamic>? metadata,
    required int nowEpochMs,
  }) async {
    await _db
        .into(_db.auditLog)
        .insert(
          AuditLogCompanion.insert(
            id: id,
            workspaceId: workspaceId,
            projectId: Value(projectId),
            eventType: eventType,
            documentId: Value(documentId),
            entityId: Value(entityId),
            toolName: Value(toolName),
            success: success ? 1 : 0,
            biometricResult: Value(biometricResult),
            metadataJson: Value(metadata == null ? null : jsonEncode(metadata)),
            createdAt: nowEpochMs,
          ),
        );
  }

  /// Reads audit entries newest-first, filterable by event type(s) and time
  /// range, with pagination (Settings → Audit Log, roadmap §15).
  Future<List<AuditEntry>> query(
    String workspaceId, {
    List<String>? eventTypes,
    int? sinceEpochMs,
    int? untilEpochMs,
    int? limit,
    int offset = 0,
  }) async {
    final q = _db.select(_db.auditLog)
      ..where((t) => t.workspaceId.equals(workspaceId));
    if (eventTypes != null && eventTypes.isNotEmpty) {
      q.where((t) => t.eventType.isIn(eventTypes));
    }
    if (sinceEpochMs != null) {
      q.where((t) => t.createdAt.isBiggerOrEqualValue(sinceEpochMs));
    }
    if (untilEpochMs != null) {
      q.where((t) => t.createdAt.isSmallerThanValue(untilEpochMs));
    }
    q.orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    if (limit != null) q.limit(limit, offset: offset);

    final rows = await q.get();
    return rows.map(_fromRow).toList();
  }

  AuditEntry _fromRow(AuditLogData r) => AuditEntry(
    id: r.id,
    workspaceId: r.workspaceId,
    projectId: r.projectId,
    eventType: r.eventType,
    documentId: r.documentId,
    entityId: r.entityId,
    toolName: r.toolName,
    success: r.success != 0,
    biometricResult: r.biometricResult,
    metadata: r.metadataJson == null
        ? null
        : jsonDecode(r.metadataJson!) as Map<String, dynamic>,
    createdAt: r.createdAt,
  );

  /// Renders [entries] as RFC-4180 CSV (roadmap §15 export).
  static String exportCsv(List<AuditEntry> entries) {
    const header = [
      'created_at',
      'event_type',
      'success',
      'project_id',
      'tool_name',
      'document_id',
      'entity_id',
      'biometric_result',
      'metadata_json',
    ];
    final buffer = StringBuffer()..writeln(header.map(_csvField).join(','));
    for (final e in entries) {
      buffer.writeln(
        [
          e.createdAt.toString(),
          e.eventType,
          e.success.toString(),
          e.projectId ?? '',
          e.toolName ?? '',
          e.documentId ?? '',
          e.entityId ?? '',
          e.biometricResult ?? '',
          e.metadata == null ? '' : jsonEncode(e.metadata),
        ].map(_csvField).join(','),
      );
    }
    return buffer.toString();
  }

  static String _csvField(String value) {
    if (value.contains(',') ||
        value.contains('"') ||
        value.contains('\n') ||
        value.contains('\r')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
