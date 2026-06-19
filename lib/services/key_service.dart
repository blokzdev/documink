import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:argon2/argon2.dart';
import 'package:cryptography/cryptography.dart';

import 'salt_store.dart';
import 'secure_key_store.dart';

/// The four subkeys derived from the Master Key (blueprint §8.1).
///
/// All keys are 32-byte (256-bit) [Uint8List]s. Hold them only as long as the
/// vault is unlocked, then call [destroy] to overwrite them. Zeroization is
/// **best-effort** on managed Dart — the GC may have copied/relocated the bytes
/// and there is no way to scrub those copies (blueprint §8.1, deviation noted in
/// V1 P1b). The contract here is "do not leave key material lying around in
/// live, reachable buffers", not "guarantee erasure".
class DerivedKeys {
  DerivedKeys({
    required this.databaseKey,
    required this.keyEncryptionKey,
    required this.fingerprintHmacKey,
    required this.syncKey,
  });

  /// Opens the SQLCipher vault (passed to `openSqlCipherExecutor` in 1c).
  final Uint8List databaseKey;

  /// Wraps/unwraps the Data Encryption Key (see [KeyService.wrapDek]).
  final Uint8List keyEncryptionKey;

  /// Keys the HMAC used to index token fingerprints (consumed in 1c).
  final Uint8List fingerprintHmacKey;

  /// Reserved for the sync transport layer (not used yet).
  final Uint8List syncKey;

  /// Best-effort overwrite of every subkey buffer.
  void destroy() {
    databaseKey.fillRange(0, databaseKey.length, 0);
    keyEncryptionKey.fillRange(0, keyEncryptionKey.length, 0);
    fingerprintHmacKey.fillRange(0, fingerprintHmacKey.length, 0);
    syncKey.fillRange(0, syncKey.length, 0);
  }
}

/// Derives and manages the DocuMink vault key hierarchy (blueprint §8.1):
///
/// ```
/// passphrase + salt --Argon2id--> Master Key (RAM only)
///   --HKDF-SHA256, domain-separated info-->
///     databaseKey · keyEncryptionKey · fingerprintHmacKey · syncKey
/// DEK (random) --AES-256-GCM wrap under KEK--> stored in vault_meta (1c)
/// ```
///
/// This service is intentionally database-free: it produces key material and
/// wraps/unwraps the DEK as pure functions. `VaultService` (1c) owns the DB
/// handle and persists the wrapped DEK to `vault_meta`. The only state this
/// service touches is the pre-unlock [SecureKeyStore] that holds the salt.
///
/// **Scope (V1 P1b):** passphrase-only. The biometric fast-path (KEK wrapped by
/// a Keystore biometric-gated key, blueprint §8.3) is deferred to Phase 5; in
/// passphrase mode the KEK is re-derived from the Master Key on every unlock, so
/// nothing key-secret is persisted at all — only the (non-secret) salt.
///
/// The salt lives in a plaintext [SaltStore] (a file), **not** the platform
/// Keystore: it is not secret, and a vanished Keystore key must never be able to
/// brick the vault (see [SaltStore] / `docs/DECISIONS.md`). An optional
/// [SecureKeyStore] is accepted only as a one-way **read-fallback**, to migrate
/// the salt out of `flutter_secure_storage` for installs created before this
/// change; all legacy reads are best-effort and tolerate a broken Keystore.
class KeyService {
  KeyService(this._saltStore, {SecureKeyStore? legacyStore})
    : _legacy = legacyStore;

  final SaltStore _saltStore;
  final SecureKeyStore? _legacy;

  // --- Argon2id parameters (blueprint §8.1: 64 MiB, t=3, p=4) -------------
  /// Memory cost in KiB. 65536 KiB = 64 MiB.
  static const int argonMemoryKib = 65536;
  static const int argonIterations = 3;
  static const int argonLanes = 4;

  /// Argon2 version 0x13 (1.3) — pinned so derivations match RFC 9106 vectors
  /// and never silently change with a dependency update.
  static const int argonVersion = Argon2Parameters.ARGON2_VERSION_13;

  /// Byte lengths across the hierarchy.
  static const int saltLength = 16;
  static const int masterKeyLength = 32;
  static const int subkeyLength = 32;
  static const int dekLength = 32;

  // --- HKDF domain separation (blueprint §8.1) ---------------------------
  static const String _infoDatabaseKey = 'documink:sqlcipher:v1';
  static const String _infoKek = 'documink:kek:v1';
  static const String _infoFpHmac = 'documink:fp-hmac:v1';
  static const String _infoSync = 'documink:sync:v1';

  /// Legacy `flutter_secure_storage` key under which older builds persisted the
  /// salt (base64). Retained only for the one-way migration read.
  static const String saltStorageKey = 'documink.vault.argon2_salt';

  // AES-GCM wrap geometry (cryptography defaults: 96-bit nonce, 128-bit tag).
  static const int _gcmNonceLength = 12;
  static const int _gcmMacLength = 16;

  final Random _random = Random.secure();

  // --- Salt management ---------------------------------------------------

  /// Whether a salt has been persisted (one half of "a vault exists" — the
  /// other half, the DB file, is checked by `VaultService`).
  Future<bool> hasSalt() async {
    if (await _saltStore.exists()) return true;
    return await _readLegacySalt() != null;
  }

  /// Reads the persisted Argon2id salt, or `null` if none exists yet. If only a
  /// legacy `flutter_secure_storage` salt is present (pre-migration install), it
  /// is read and migrated into the [SaltStore] so future reads never touch the
  /// Keystore again.
  Future<Uint8List?> readSalt() async {
    final fromFile = await _saltStore.read();
    if (fromFile != null) return fromFile;
    final legacy = await _readLegacySalt();
    if (legacy != null) {
      try {
        await _saltStore.write(legacy); // one-way migration off the Keystore
      } catch (_) {
        // If the file write fails we still return the salt; migration retries.
      }
      return legacy;
    }
    return null;
  }

  /// Returns the existing salt, or generates and persists a fresh random one on
  /// first run. The salt is not secret, but it must survive across launches and
  /// be readable before the vault opens.
  Future<Uint8List> loadOrCreateSalt() async {
    final existing = await readSalt();
    if (existing != null) return existing;
    final salt = _randomBytes(saltLength);
    await _saltStore.write(salt);
    return salt;
  }

  /// Removes the persisted salt (file + best-effort legacy Keystore entry). Used
  /// by the vault reset / failed-create rollback.
  Future<void> deleteSalt() async {
    await _saltStore.delete();
    final legacy = _legacy;
    if (legacy != null) {
      try {
        await legacy.delete(saltStorageKey);
      } catch (_) {
        // Best-effort: a broken/absent Keystore entry is fine to ignore.
      }
    }
  }

  /// Best-effort read of the legacy Keystore-stored salt. Tolerates a broken
  /// Keystore (the exact failure that motivated moving the salt to a file): any
  /// error is treated as "no legacy salt".
  Future<Uint8List?> _readLegacySalt() async {
    final legacy = _legacy;
    if (legacy == null) return null;
    try {
      final encoded = await legacy.read(saltStorageKey);
      if (encoded == null) return null;
      return Uint8List.fromList(base64Decode(encoded));
    } catch (_) {
      return null;
    }
  }

  // --- Master Key (Argon2id) ---------------------------------------------

  /// Derives the 32-byte Master Key from [passphrase] and [salt].
  ///
  /// Synchronous and CPU/memory-heavy by design (64 MiB). Callers on the UI
  /// path should run it off the main isolate; that orchestration lives in
  /// `VaultService` (1c)/UI (Phase 5), not here.
  Uint8List deriveMasterKey(String passphrase, Uint8List salt) {
    final params = Argon2Parameters(
      Argon2Parameters.ARGON2_id,
      salt,
      version: argonVersion,
      iterations: argonIterations,
      memory: argonMemoryKib,
      lanes: argonLanes,
    );
    final generator = Argon2BytesGenerator()..init(params);
    final out = Uint8List(masterKeyLength);
    generator.generateBytesFromString(passphrase, out);
    return out;
  }

  // --- Subkey derivation (HKDF-SHA256) -----------------------------------

  /// Derives the four domain-separated subkeys from [masterKey].
  Future<DerivedKeys> deriveSubkeys(Uint8List masterKey) async {
    final mk = SecretKey(masterKey);
    final databaseKey = await _hkdf(mk, _infoDatabaseKey);
    final kek = await _hkdf(mk, _infoKek);
    final fpHmac = await _hkdf(mk, _infoFpHmac);
    final sync = await _hkdf(mk, _infoSync);
    return DerivedKeys(
      databaseKey: databaseKey,
      keyEncryptionKey: kek,
      fingerprintHmacKey: fpHmac,
      syncKey: sync,
    );
  }

  Future<Uint8List> _hkdf(SecretKey masterKey, String info) async {
    final hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: subkeyLength);
    final derived = await hkdf.deriveKey(
      secretKey: masterKey,
      info: utf8.encode(info),
    );
    final bytes = await derived.extractBytes();
    return Uint8List.fromList(bytes);
  }

  // --- Data Encryption Key (DEK) -----------------------------------------

  /// Generates a fresh random 32-byte DEK.
  Uint8List generateDek() => _randomBytes(dekLength);

  /// Wraps [dek] under the KEK with AES-256-GCM, returning `nonce‖ct‖tag`.
  ///
  /// The result is what `VaultService` (1c) persists to `vault_meta`. Each call
  /// uses a fresh random nonce, so the same DEK wraps to different bytes.
  Future<Uint8List> wrapDek(Uint8List dek, Uint8List keyEncryptionKey) async {
    final box = await AesGcm.with256bits().encrypt(
      dek,
      secretKey: SecretKey(keyEncryptionKey),
    );
    return box.concatenation();
  }

  /// Reverses [wrapDek]. Throws [SecretBoxAuthenticationError] if [wrapped] was
  /// tampered with or the wrong KEK is supplied.
  Future<Uint8List> unwrapDek(
    Uint8List wrapped,
    Uint8List keyEncryptionKey,
  ) async {
    final box = SecretBox.fromConcatenation(
      wrapped,
      nonceLength: _gcmNonceLength,
      macLength: _gcmMacLength,
    );
    final dek = await AesGcm.with256bits().decrypt(
      box,
      secretKey: SecretKey(keyEncryptionKey),
    );
    return Uint8List.fromList(dek);
  }

  Uint8List _randomBytes(int length) {
    final bytes = Uint8List(length);
    for (var i = 0; i < length; i++) {
      bytes[i] = _random.nextInt(256);
    }
    return bytes;
  }
}
