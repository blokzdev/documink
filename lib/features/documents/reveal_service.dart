import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/id_generator.dart';
import '../../services/authenticator.dart';
import '../../services/vault_providers.dart';
import '../audit/audit_log_repository.dart';
import 'document_repository.dart';

/// Reveals the original plaintext behind a document's reversible tokens, gated by
/// device auth (§5 `decode`, biometric). Every attempt — success or denial — is
/// audit-logged (privacy invariant #7). Plaintext is returned to the caller for
/// transient display only; it is never persisted or logged.
class RevealService {
  RevealService({
    required DocumentRepository documents,
    required AuditLogRepository audit,
    required Authenticator authenticator,
    required Future<String> Function(List<int> ciphertext, String tokenValue)
    decryptToken,
    IdGenerator? idGenerator,
    DateTime Function()? clock,
  }) : _documents = documents,
       _audit = audit,
       _authenticator = authenticator,
       _decrypt = decryptToken,
       _newId = idGenerator ?? defaultIdGenerator,
       _clock = clock ?? DateTime.now;

  final DocumentRepository _documents;
  final AuditLogRepository _audit;
  final Authenticator _authenticator;
  final Future<String> Function(List<int> ciphertext, String tokenValue)
  _decrypt;
  final IdGenerator _newId;
  final DateTime Function() _clock;

  /// Authenticates, then decrypts each reversible token of [documentId].
  /// Returns surrogate → plaintext on success, or null if auth was denied.
  Future<Map<String, String>?> reveal(String documentId) async {
    final tokens = await _documents.tokensForDocument(documentId);
    final ok = await _authenticator.authenticate(
      reason: 'Reveal the original values in this document',
    );

    await _audit.record(
      id: _newId(),
      workspaceId: DocumentRepository.defaultWorkspaceId,
      eventType: 'document_reveal',
      documentId: documentId,
      success: ok,
      biometricResult: ok ? 'success' : 'failed',
      metadata: {'tokenCount': tokens.length},
      nowEpochMs: _clock().millisecondsSinceEpoch,
    );

    if (!ok) return null;

    final revealed = <String, String>{};
    for (final token in tokens) {
      revealed[token.tokenValue] = await _decrypt(
        token.ciphertext,
        token.tokenValue,
      );
    }
    return revealed;
  }
}

/// Reveal service bound to the unlocked vault (uses its `TokenCrypto`).
final revealServiceProvider = Provider<RevealService>((ref) {
  ref.watch(vaultServiceProvider);
  final crypto = ref.read(vaultServiceProvider.notifier).tokenCrypto;
  final db = ref.read(vaultServiceProvider.notifier).database;
  return RevealService(
    documents: ref.read(documentRepositoryProvider),
    audit: AuditLogRepository(db),
    authenticator: ref.read(authenticatorProvider),
    decryptToken: (ciphertext, tokenValue) =>
        crypto.decrypt(Uint8List.fromList(ciphertext), tokenValue: tokenValue),
  );
});
