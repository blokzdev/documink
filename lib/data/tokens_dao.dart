import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:drift/drift.dart';

import 'app_database.dart';

/// Encrypts token plaintext at rest and derives its lookup fingerprint
/// (blueprint §3.1 `tokens` / §8.1).
///
/// Two independent keys, both derived from the Master Key via HKDF (see
/// `KeyService`):
///   * the **DEK** encrypts `ciphertext` with AES-256-GCM, binding the
///     ciphertext to its `token_value` via **AAD** — a token's ciphertext can
///     only ever be decrypted in the context of the same surface token, so a
///     swapped/relabelled token fails authentication; and
///   * the **fingerprint-HMAC key** produces a deterministic HMAC-SHA256 of the
///     plaintext for equality lookup/dedup without storing the plaintext.
///
/// The plaintext PII is never persisted and never logged — only `ciphertext`
/// and the keyed fingerprint are (privacy-invariants.md).
class TokenCrypto {
  TokenCrypto({required this.dek, required this.fingerprintHmacKey});

  /// Data Encryption Key (32 bytes). Held only while the vault is unlocked.
  final Uint8List dek;

  /// HMAC-SHA256 key for fingerprints (32 bytes).
  final Uint8List fingerprintHmacKey;

  // AES-GCM geometry (cryptography defaults: 96-bit nonce, 128-bit tag).
  static const int _nonceLength = 12;
  static const int _macLength = 16;

  /// Encrypts [plaintext], binding it to [tokenValue] as AAD. Returns
  /// `nonce‖cipherText‖mac` for storage in `tokens.ciphertext`.
  Future<Uint8List> encrypt(
    String plaintext, {
    required String tokenValue,
  }) async {
    final box = await AesGcm.with256bits().encrypt(
      utf8.encode(plaintext),
      secretKey: SecretKey(dek),
      aad: utf8.encode(tokenValue),
    );
    return box.concatenation();
  }

  /// Reverses [encrypt]. Throws [SecretBoxAuthenticationError] if the blob was
  /// tampered with, the DEK is wrong, or [tokenValue] does not match the AAD
  /// the ciphertext was bound to.
  Future<String> decrypt(Uint8List blob, {required String tokenValue}) async {
    final box = SecretBox.fromConcatenation(
      blob,
      nonceLength: _nonceLength,
      macLength: _macLength,
    );
    final clear = await AesGcm.with256bits().decrypt(
      box,
      secretKey: SecretKey(dek),
      aad: utf8.encode(tokenValue),
    );
    return utf8.decode(clear);
  }

  /// Deterministic HMAC-SHA256 fingerprint of [plaintext] for the
  /// `(workspace_id, plaintext_fingerprint)` lookup index.
  Future<Uint8List> fingerprint(String plaintext) async {
    final mac = await Hmac.sha256().calculateMac(
      utf8.encode(plaintext),
      secretKey: SecretKey(fingerprintHmacKey),
    );
    return Uint8List.fromList(mac.bytes);
  }

  /// Encrypts arbitrary [bytes] (e.g. an original document file) with AES-256-GCM
  /// under the DEK, binding the ciphertext to [aad] (use the owning document id).
  /// Returns `nonce‖cipherText‖mac`. A fresh random 96-bit nonce is used per
  /// call (handled by `package:cryptography`). Suitable for the document-sized
  /// blobs we retain (≤ ~25 MB held in memory; no streaming needed).
  Future<Uint8List> encryptBytes(Uint8List bytes, {required String aad}) async {
    final box = await AesGcm.with256bits().encrypt(
      bytes,
      secretKey: SecretKey(dek),
      aad: utf8.encode(aad),
    );
    return box.concatenation();
  }

  /// Reverses [encryptBytes]. Throws [SecretBoxAuthenticationError] if the blob
  /// was tampered with, the DEK is wrong, or [aad] does not match.
  Future<Uint8List> decryptBytes(Uint8List blob, {required String aad}) async {
    final box = SecretBox.fromConcatenation(
      blob,
      nonceLength: _nonceLength,
      macLength: _macLength,
    );
    final clear = await AesGcm.with256bits().decrypt(
      box,
      secretKey: SecretKey(dek),
      aad: utf8.encode(aad),
    );
    return Uint8List.fromList(clear);
  }
}

/// Thin persistence layer over the `tokens` table that stores encrypted tokens
/// and looks them up by keyed fingerprint. The detection/redaction pipeline
/// (later phases) is what populates entities and drives this; 1c provides the
/// store/lookup/reveal primitives and proves the encrypted round-trip.
class TokensRepository {
  TokensRepository(this._db, this._crypto, {this.keyVersion = 1});

  final AppDatabase _db;
  final TokenCrypto _crypto;

  /// DEK version stamped on stored rows (`tokens.key_version`); rotation is
  /// deferred, so this is fixed at the current version for now.
  final int keyVersion;

  /// Encrypts [plaintext] and inserts a token row.
  Future<void> store({
    required String id,
    required String workspaceId,
    required String entityId,
    required String tokenValue,
    required String plaintext,
    required int createdAt,
  }) async {
    final ciphertext = await _crypto.encrypt(plaintext, tokenValue: tokenValue);
    final fingerprint = await _crypto.fingerprint(plaintext);
    await _db
        .into(_db.tokens)
        .insert(
          TokensCompanion.insert(
            id: id,
            workspaceId: workspaceId,
            entityId: entityId,
            tokenValue: tokenValue,
            plaintextFingerprint: fingerprint,
            ciphertext: ciphertext,
            keyVersion: keyVersion,
            createdAt: createdAt,
          ),
        );
  }

  /// Looks up a token by its keyed [fingerprint] within [workspaceId] (uses
  /// `idx_tokens_fingerprint`). Returns `null` if absent.
  Future<Token?> findByFingerprint(String workspaceId, Uint8List fingerprint) {
    return (_db.select(_db.tokens)..where(
          (t) =>
              t.workspaceId.equals(workspaceId) &
              t.plaintextFingerprint.equals(fingerprint),
        ))
        .getSingleOrNull();
  }

  /// Decrypts a stored [token]'s ciphertext back to plaintext.
  Future<String> revealPlaintext(Token token) =>
      _crypto.decrypt(token.ciphertext, tokenValue: token.tokenValue);
}
