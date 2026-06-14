import 'dart:convert';

import 'package:drift/drift.dart';

import '../../data/app_database.dart';
import 'memory_guard.dart';

/// A Core Memory entry (stable identity/preference fact). `value` is decoded
/// JSON that may contain token references but never raw PII (memory.md §2.1).
class CoreMemoryEntry {
  const CoreMemoryEntry({
    required this.id,
    required this.workspaceId,
    this.projectId,
    required this.key,
    required this.value,
    required this.provenance,
    this.confidence,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String workspaceId;
  final String? projectId;
  final String key;
  final Object? value;
  final String provenance;
  final double? confidence;
  final int createdAt;
  final int updatedAt;
}

/// An Episodic Memory entry (time-stamped activity summary, memory.md §2.2).
class EpisodicEntry {
  const EpisodicEntry({
    required this.id,
    required this.workspaceId,
    this.projectId,
    required this.occurredAt,
    required this.summary,
    this.details,
    required this.episodeType,
    this.tokenRefs,
    required this.createdAt,
  });

  final String id;
  final String workspaceId;
  final String? projectId;
  final int occurredAt;
  final String summary;
  final Object? details;
  final String episodeType;
  final List<String>? tokenRefs;
  final int createdAt;
}

/// Read/write access to the **active-V1** Mink memory types (Core, Episodic),
/// memory.md §2/§4. Every write passes through [MemoryWriteGuard] so raw PII can
/// never be persisted (§3.3). Recall is scope-aware: current Project + globals
/// (§4.3, §6).
class MemoryRepository {
  MemoryRepository(this._db, this._guard);

  final AppDatabase _db;
  final MemoryWriteGuard _guard;

  // --- Core Memory -------------------------------------------------------

  Future<void> writeCore({
    required String id,
    required String workspaceId,
    String? projectId,
    required String key,
    required Object? value,
    required String provenance,
    double? confidence,
    required int nowEpochMs,
  }) async {
    await _guard.assertNoPlaintext(value);
    await _db
        .into(_db.minkCoreMemory)
        .insertOnConflictUpdate(
          MinkCoreMemoryCompanion.insert(
            id: id,
            workspaceId: workspaceId,
            projectId: Value(projectId),
            key: key,
            valueJson: jsonEncode(value),
            provenance: provenance,
            confidence: Value(confidence),
            createdAt: nowEpochMs,
            updatedAt: nowEpochMs,
          ),
        );
  }

  /// Core entries for the current scope: the Project's plus workspace globals.
  Future<List<CoreMemoryEntry>> recallCore(
    String workspaceId, {
    String? projectId,
  }) async {
    final query = _db.select(_db.minkCoreMemory)
      ..where((t) => t.workspaceId.equals(workspaceId))
      ..where(
        (t) => projectId == null
            ? t.projectId.isNull()
            : t.projectId.isNull() | t.projectId.equals(projectId),
      );
    final rows = await query.get();
    return [
      for (final r in rows)
        CoreMemoryEntry(
          id: r.id,
          workspaceId: r.workspaceId,
          projectId: r.projectId,
          key: r.key,
          value: jsonDecode(r.valueJson),
          provenance: r.provenance,
          confidence: r.confidence,
          createdAt: r.createdAt,
          updatedAt: r.updatedAt,
        ),
    ];
  }

  Future<void> forgetCore(String id) =>
      (_db.delete(_db.minkCoreMemory)..where((t) => t.id.equals(id))).go();

  // --- Episodic Memory ---------------------------------------------------

  Future<void> writeEpisodic({
    required String id,
    required String workspaceId,
    String? projectId,
    required int occurredAt,
    required String summary,
    Object? details,
    required String episodeType,
    List<String>? tokenRefs,
    required int nowEpochMs,
  }) async {
    await _guard.assertNoPlaintext({'summary': summary, 'details': details});
    await _db
        .into(_db.minkEpisodicMemory)
        .insertOnConflictUpdate(
          MinkEpisodicMemoryCompanion.insert(
            id: id,
            workspaceId: workspaceId,
            projectId: Value(projectId),
            occurredAt: occurredAt,
            summary: summary,
            detailsJson: Value(details == null ? null : jsonEncode(details)),
            episodeType: episodeType,
            tokenRefsJson: Value(
              tokenRefs == null ? null : jsonEncode(tokenRefs),
            ),
            createdAt: nowEpochMs,
          ),
        );
  }

  /// Episodes in scope, newest first (memory.md §2.2 retrieval): optional
  /// `since` time bound, optional `episodeType` filter, optional `limit`.
  Future<List<EpisodicEntry>> recallEpisodic(
    String workspaceId, {
    String? projectId,
    int? sinceEpochMs,
    String? episodeType,
    int? limit,
  }) async {
    final query = _db.select(_db.minkEpisodicMemory)
      ..where((t) => t.workspaceId.equals(workspaceId))
      ..where(
        (t) => projectId == null
            ? t.projectId.isNull()
            : t.projectId.isNull() | t.projectId.equals(projectId),
      );
    if (sinceEpochMs != null) {
      query.where((t) => t.occurredAt.isBiggerOrEqualValue(sinceEpochMs));
    }
    if (episodeType != null) {
      query.where((t) => t.episodeType.equals(episodeType));
    }
    query.orderBy([(t) => OrderingTerm.desc(t.occurredAt)]);
    if (limit != null) query.limit(limit);

    final rows = await query.get();
    return [
      for (final r in rows)
        EpisodicEntry(
          id: r.id,
          workspaceId: r.workspaceId,
          projectId: r.projectId,
          occurredAt: r.occurredAt,
          summary: r.summary,
          details: r.detailsJson == null ? null : jsonDecode(r.detailsJson!),
          episodeType: r.episodeType,
          tokenRefs: r.tokenRefsJson == null
              ? null
              : (jsonDecode(r.tokenRefsJson!) as List<dynamic>).cast<String>(),
          createdAt: r.createdAt,
        ),
    ];
  }

  Future<void> forgetEpisodic(String id) =>
      (_db.delete(_db.minkEpisodicMemory)..where((t) => t.id.equals(id))).go();
}
