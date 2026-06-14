import 'dart:convert';

import 'package:crypto/crypto.dart' as crypto;
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/app_database.dart';
import '../../data/id_generator.dart';
import '../../services/vault_providers.dart';
import '../../services/vault_service.dart';
import '../anonymization/anonymization_service.dart';
import '../anonymization/operator.dart';
import '../audit/audit_log_repository.dart';
import '../detection/detection_pipeline.dart';
import '../projects/active_project_provider.dart';

/// Persists anonymized documents into the unlocked vault: a `documents` row, its
/// detected `entities`, and the reversible `tokens` (blueprint §3.1), all in one
/// transaction, plus a `document_saved` audit entry (privacy invariant #7).
class DocumentRepository {
  DocumentRepository(
    this._db, {
    IdGenerator? idGenerator,
    DateTime Function()? clock,
  }) : _newId = idGenerator ?? defaultIdGenerator,
       _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final IdGenerator _newId;
  final DateTime Function() _clock;

  /// Single-tenant V1 default workspace (the projects/multi-workspace UI is a
  /// later phase; logged in DECISIONS.md).
  static const String defaultWorkspaceId = 'ws_default';

  /// Ensures the default workspace row exists and returns its id.
  Future<String> ensureDefaultWorkspace() async {
    final existing = await (_db.select(
      _db.workspaces,
    )..where((w) => w.id.equals(defaultWorkspaceId))).getSingleOrNull();
    if (existing == null) {
      await _db
          .into(_db.workspaces)
          .insert(
            WorkspacesCompanion.insert(
              id: defaultWorkspaceId,
              name: 'My Vault',
              createdAt: _clock().millisecondsSinceEpoch,
              kekVersion: VaultService.currentDekVersion,
            ),
          );
    }
    return defaultWorkspaceId;
  }

  /// Saves a redacted text document. Returns the new document id. When
  /// [projectId] is given the document is scoped to that Project (§6.7
  /// isolation); null keeps it workspace-global.
  Future<String> saveAnonymizedText({
    required String name,
    required String originalText,
    required DetectionResult detection,
    required Map<String, Operator> operators,
    required AnonymizationOutcome outcome,
    String? projectId,
  }) async {
    final workspaceId = await ensureDefaultWorkspace();
    final now = _clock().millisecondsSinceEpoch;
    final documentId = _newId();
    final sourceHash = Uint8List.fromList(
      crypto.sha256.convert(utf8.encode(originalText)).bytes,
    );

    await _db.transaction(() async {
      await _db
          .into(_db.documents)
          .insert(
            DocumentsCompanion.insert(
              id: documentId,
              workspaceId: workspaceId,
              projectId: Value(projectId),
              name: name,
              type: 'text',
              sourceHash: sourceHash,
              createdAt: now,
              updatedAt: now,
              status: 'redacted',
              metadataJson: Value(
                jsonEncode({'redactedText': outcome.result.text}),
              ),
            ),
          );

      for (final span in detection.spans) {
        final entityId = _newId();
        final op = operators[span.label] ?? Operator.redact;
        await _db
            .into(_db.entities)
            .insert(
              EntitiesCompanion.insert(
                id: entityId,
                workspaceId: workspaceId,
                documentId: documentId,
                entityType: span.label,
                detector: span.detector,
                spanStart: span.start,
                spanEnd: span.end,
                confidence: span.score,
                operatorApplied: op.policyName,
                createdAt: now,
              ),
            );

        final record = outcome.tokensBySpan[span];
        if (record != null) {
          await _db
              .into(_db.tokens)
              .insert(
                TokensCompanion.insert(
                  id: _newId(),
                  workspaceId: workspaceId,
                  entityId: entityId,
                  tokenValue: record.surrogate,
                  plaintextFingerprint: record.fingerprint,
                  ciphertext: record.ciphertext,
                  keyVersion: VaultService.currentDekVersion,
                  createdAt: now,
                ),
              );
        }
      }

      await AuditLogRepository(_db).record(
        id: _newId(),
        workspaceId: workspaceId,
        eventType: 'document_saved',
        documentId: documentId,
        success: true,
        metadata: {
          'entityCount': detection.spans.length,
          'tokenCount': outcome.tokensBySpan.length,
        },
        nowEpochMs: now,
      );
    });

    return documentId;
  }

  /// Documents in the default workspace, newest first. When [projectId] is given
  /// only that Project's documents are returned (§6.7 isolation); null returns
  /// the whole workspace (the global view).
  Future<List<Document>> listDocuments({String? projectId}) async {
    final workspaceId = await ensureDefaultWorkspace();
    return (_db.select(_db.documents)
          ..where((d) => d.workspaceId.equals(workspaceId))
          ..where(
            (d) => projectId == null
                ? const Constant(true)
                : d.projectId.equals(projectId),
          )
          ..orderBy([(d) => OrderingTerm.desc(d.createdAt)]))
        .get();
  }

  /// A single document by id, or null if absent.
  Future<Document?> documentById(String id) => (_db.select(
    _db.documents,
  )..where((d) => d.id.equals(id))).getSingleOrNull();

  /// Deletes a document and all its entities + tokens (one transaction), and
  /// audits `document_deleted`.
  Future<void> deleteDocument(String documentId) async {
    await _db.transaction(() async {
      final entityIds =
          await (_db.selectOnly(_db.entities)
                ..addColumns([_db.entities.id])
                ..where(_db.entities.documentId.equals(documentId)))
              .map((r) => r.read(_db.entities.id)!)
              .get();
      if (entityIds.isNotEmpty) {
        await (_db.delete(
          _db.tokens,
        )..where((t) => t.entityId.isIn(entityIds))).go();
      }
      await (_db.delete(
        _db.entities,
      )..where((e) => e.documentId.equals(documentId))).go();
      // Encrypted original (Phase 4c), if any, is removed in the same cascade.
      await (_db.delete(
        _db.documentOriginals,
      )..where((o) => o.documentId.equals(documentId))).go();
      await (_db.delete(
        _db.documents,
      )..where((d) => d.id.equals(documentId))).go();
      await AuditLogRepository(_db).record(
        id: _newId(),
        workspaceId: defaultWorkspaceId,
        eventType: 'document_deleted',
        documentId: documentId,
        success: true,
        nowEpochMs: _clock().millisecondsSinceEpoch,
      );
    });
  }

  /// The detected entities of [documentId], in document order.
  Future<List<Entity>> entitiesForDocument(String documentId) async {
    return (_db.select(_db.entities)
          ..where((e) => e.documentId.equals(documentId))
          ..orderBy([(e) => OrderingTerm.asc(e.spanStart)]))
        .get();
  }

  /// The reversible tokens belonging to [documentId] (joined via its entities).
  Future<List<Token>> tokensForDocument(String documentId) async {
    final query = _db.select(_db.tokens).join([
      innerJoin(_db.entities, _db.entities.id.equalsExp(_db.tokens.entityId)),
    ])..where(_db.entities.documentId.equals(documentId));
    final rows = await query.get();
    return [for (final row in rows) row.readTable(_db.tokens)];
  }
}

/// Document persistence against the unlocked vault. Reading it while locked
/// throws (the `database` getter throws), matching the other vault-backed providers.
final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  ref.watch(vaultServiceProvider);
  return DocumentRepository(ref.read(vaultServiceProvider.notifier).database);
});

/// The saved documents in the vault (newest first), scoped to the active Project
/// (null = the whole workspace). Auto-disposes so it refetches each time the
/// vault browser is opened, and refetches when the active Project changes.
final documentsListProvider = FutureProvider.autoDispose<List<Document>>((ref) {
  final projectId = ref.watch(activeProjectProvider);
  return ref
      .watch(documentRepositoryProvider)
      .listDocuments(projectId: projectId);
});

/// A single saved document by id.
final documentByIdProvider = FutureProvider.autoDispose
    .family<Document?, String>(
      (ref, id) => ref.watch(documentRepositoryProvider).documentById(id),
    );
