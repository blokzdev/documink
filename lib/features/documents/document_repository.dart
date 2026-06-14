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

  /// Saves a redacted text document. Returns the new document id.
  Future<String> saveAnonymizedText({
    required String name,
    required String originalText,
    required DetectionResult detection,
    required Map<String, Operator> operators,
    required AnonymizationOutcome outcome,
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

  /// All documents in the default workspace, newest first.
  Future<List<Document>> listDocuments() async {
    final workspaceId = await ensureDefaultWorkspace();
    return (_db.select(_db.documents)
          ..where((d) => d.workspaceId.equals(workspaceId))
          ..orderBy([(d) => OrderingTerm.desc(d.createdAt)]))
        .get();
  }

  /// A single document by id, or null if absent.
  Future<Document?> documentById(String id) => (_db.select(
    _db.documents,
  )..where((d) => d.id.equals(id))).getSingleOrNull();

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

/// The saved documents in the vault (newest first). Auto-disposes so it refetches
/// each time the vault browser is opened.
final documentsListProvider = FutureProvider.autoDispose<List<Document>>(
  (ref) => ref.watch(documentRepositoryProvider).listDocuments(),
);

/// A single saved document by id.
final documentByIdProvider = FutureProvider.autoDispose
    .family<Document?, String>(
      (ref, id) => ref.watch(documentRepositoryProvider).documentById(id),
    );
