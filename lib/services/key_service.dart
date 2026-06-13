import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:argon2/argon2.dart';
import 'package:cryptography/cryptography.dart';

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
/// nothing key-secret is persisted to the secure store — only the salt.
class KeyService {
  KeyService(this._store);

  final SecureKeyStore _store;

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

  /// Secure-store key under which the Argon2id salt is persisted.
  static const String saltStorageKey = 'documink.vault.argon2_salt';

  // AES-GCM wrap geometry (cryptography defaults: 96-bit nonce, 128-bit tag).
  static const int _gcmNonceLength = 12;
  static const int _gcmMacLength = 16;

  final Random _random = Random.secure();

  // --- Salt management ---------------------------------------------------

  /// Whether a vault has been initialized (i.e. a salt exists).
  Future<bool> vaultExists() => _store.containsKey(saltStorageKey);

  /// Reads the persisted Argon2id salt, or `null` if no vault exists yet.
  Future<Uint8List?> readSalt() async {
    final encoded = await _store.read(saltStorageKey);
    if (encoded == null) return null;
    return Uint8List.fromList(base64Decode(encoded));
  }

  /// Returns the existing salt, or generates and persists a fresh random one on
  /// first run. The salt is not secret, but it must survive across launches and
  /// be readable before the vault opens.
  Future<Uint8List> loadOrCreateSalt() async {
    final existing = await readSalt();
    if (existing != null) return existing;
    final salt = _randomBytes(saltLength);
    await _store.write(saltStorageKey, base64Encode(salt));
    return salt;
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
