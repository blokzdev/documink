import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/app_database.dart';
import '../../data/id_generator.dart';
import '../../data/tokens_dao.dart';
import '../../services/vault_providers.dart';
import '../../services/vault_service.dart';

/// Stores the **encrypted original** of a document (Phase 4c, opt-in): the raw
/// source bytes (image/PDF) sealed with AES-256-GCM under the vault DEK, AAD =
/// document id, in the `document_originals` table (one row per document). The DB
/// is SQLCipher-encrypted on top. The plaintext bytes are never persisted in the
/// clear and are only materialized transiently behind the biometric gate
/// (`OriginalRevealService`).
class OriginalsRepository {
  OriginalsRepository(
    this._db,
    this._crypto, {
    IdGenerator? idGenerator,
    DateTime Function()? clock,
    this.keyVersion = VaultService.currentDekVersion,
  }) : _newId = idGenerator ?? defaultIdGenerator,
       _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final TokenCrypto _crypto;
  final IdGenerator _newId;
  final DateTime Function() _clock;
  final int keyVersion;

  /// Encrypts [bytes] (AAD = [documentId]) and stores them as the document's
  /// original. Replaces any existing original for that document.
  Future<void> saveOriginal({
    required String documentId,
    required Uint8List bytes,
    required String mime,
  }) async {
    final ciphertext = await _crypto.encryptBytes(bytes, aad: documentId);
    await _db.transaction(() async {
      await (_db.delete(
        _db.documentOriginals,
      )..where((o) => o.documentId.equals(documentId))).go();
      await _db
          .into(_db.documentOriginals)
          .insert(
            DocumentOriginalsCompanion.insert(
              id: _newId(),
              documentId: documentId,
              mime: mime,
              sizeBytes: bytes.length,
              ciphertext: ciphertext,
              keyVersion: keyVersion,
              createdAt: _clock().millisecondsSinceEpoch,
            ),
          );
    });
  }

  /// The stored original row for [documentId] (incl. ciphertext), or null.
  Future<DocumentOriginal?> originalFor(String documentId) => (_db.select(
    _db.documentOriginals,
  )..where((o) => o.documentId.equals(documentId))).getSingleOrNull();

  /// Whether [documentId] has a retained original (cheap existence check).
  Future<bool> hasOriginal(String documentId) async =>
      await originalFor(documentId) != null;

  /// Decrypts a stored [original]'s ciphertext back to the raw bytes.
  Future<Uint8List> decryptOriginal(DocumentOriginal original) =>
      _crypto.decryptBytes(original.ciphertext, aad: original.documentId);
}

/// Originals persistence bound to the unlocked vault (uses its `TokenCrypto`).
/// Reading it while locked throws (matching the other vault-backed providers).
final originalsRepositoryProvider = Provider<OriginalsRepository>((ref) {
  ref.watch(vaultServiceProvider);
  final notifier = ref.read(vaultServiceProvider.notifier);
  return OriginalsRepository(notifier.database, notifier.tokenCrypto);
});
