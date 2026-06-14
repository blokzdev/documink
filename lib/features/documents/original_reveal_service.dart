import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/id_generator.dart';
import '../../services/authenticator.dart';
import '../../services/vault_providers.dart';
import '../audit/audit_log_repository.dart';
import 'document_repository.dart';
import 'originals_repository.dart';

/// A decrypted original, returned for transient display only — never persisted.
class RevealedOriginal {
  const RevealedOriginal({required this.bytes, required this.mime});

  final Uint8List bytes;
  final String mime;
}

/// Reveals a document's retained **original file** (Phase 4c) behind a biometric
/// gate, mirroring [RevealService] for tokens. Every attempt is audit-logged
/// (`document_original_revealed`); the decrypted bytes are returned for transient
/// display and never persisted or logged.
class OriginalRevealService {
  OriginalRevealService({
    required OriginalsRepository originals,
    required AuditLogRepository audit,
    required Authenticator authenticator,
    IdGenerator? idGenerator,
    DateTime Function()? clock,
  }) : _originals = originals,
       _audit = audit,
       _authenticator = authenticator,
       _newId = idGenerator ?? defaultIdGenerator,
       _clock = clock ?? DateTime.now;

  final OriginalsRepository _originals;
  final AuditLogRepository _audit;
  final Authenticator _authenticator;
  final IdGenerator _newId;
  final DateTime Function() _clock;

  /// Returns the decrypted original of [documentId] on successful auth, or null
  /// if there is no original or auth was denied. No biometric prompt is shown
  /// when there is nothing to reveal.
  Future<RevealedOriginal?> reveal(String documentId) async {
    final original = await _originals.originalFor(documentId);
    if (original == null) return null;

    final ok = await _authenticator.authenticate(
      reason: 'View the original document',
    );

    await _audit.record(
      id: _newId(),
      workspaceId: DocumentRepository.defaultWorkspaceId,
      eventType: 'document_original_revealed',
      documentId: documentId,
      success: ok,
      biometricResult: ok ? 'success' : 'failed',
      metadata: {'mime': original.mime, 'sizeBytes': original.sizeBytes},
      nowEpochMs: _clock().millisecondsSinceEpoch,
    );

    if (!ok) return null;

    final bytes = await _originals.decryptOriginal(original);
    return RevealedOriginal(bytes: bytes, mime: original.mime);
  }
}

/// Original-reveal service bound to the unlocked vault.
final originalRevealServiceProvider = Provider<OriginalRevealService>((ref) {
  ref.watch(vaultServiceProvider);
  final db = ref.read(vaultServiceProvider.notifier).database;
  return OriginalRevealService(
    originals: ref.read(originalsRepositoryProvider),
    audit: AuditLogRepository(db),
    authenticator: ref.read(authenticatorProvider),
  );
});
