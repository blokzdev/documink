import 'dart:convert';
import 'dart:typed_data';

import 'package:argon2/argon2.dart';
import 'package:cryptography/cryptography.dart';
import 'package:documink/services/key_service.dart';
import 'package:documink/services/salt_store.dart';
import 'package:documink/services/secure_key_store.dart';
import 'package:flutter_test/flutter_test.dart';

/// Key-hierarchy tests for V1 Phase 1b (blueprint §8.1). These are pure-Dart and
/// need no platform channels: the [SecureKeyStore] is faked in memory.
///
/// Algorithm correctness is anchored to published known-answer tests
/// (RFC 9106 Argon2id, RFC 5869 HKDF-SHA256); the DocuMink-specific wiring
/// (domain-separation strings, subkey set, DEK wrapping) is pinned with
/// regression vectors and behavioural checks.
void main() {
  /// In-memory salt store + legacy secure-store fake (the latter only exercises
  /// the one-way migration read-fallback).
  late _InMemorySaltStore saltStore;
  late _FakeSecureKeyStore legacy;
  late KeyService keyService;

  setUp(() {
    saltStore = _InMemorySaltStore();
    legacy = _FakeSecureKeyStore();
    keyService = KeyService(saltStore, legacyStore: legacy);
  });

  Uint8List bytes(int length, int fill) =>
      Uint8List.fromList(List.filled(length, fill));

  String hex(List<int> b) =>
      b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();

  group('Argon2id master-key derivation', () {
    test('matches the RFC 9106 §5.3 Argon2id known-answer vector', () {
      // Anchors that our pinned version (0x13) and Argon2id type produce the
      // canonical output. This vector uses the optional secret + associated
      // data that KeyService does not expose, so it is exercised at the
      // library level rather than through KeyService.
      final params = Argon2Parameters(
        Argon2Parameters.ARGON2_id,
        bytes(16, 0x02),
        secret: bytes(8, 0x03),
        additional: bytes(12, 0x04),
        version: Argon2Parameters.ARGON2_VERSION_13,
        iterations: 3,
        memory: 32,
        lanes: 4,
      );
      final generator = Argon2BytesGenerator()..init(params);
      final out = Uint8List(32);
      generator.generateBytes(bytes(32, 0x01), out);
      expect(
        hex(out),
        '0d640df58d78766c08c037a34a8b53c9d01ef0452d75b65eb52520e96b01e659',
      );
    });

    test('production parameters are pinned to blueprint §8.1', () {
      expect(KeyService.argonMemoryKib, 65536); // 64 MiB
      expect(KeyService.argonIterations, 3);
      expect(KeyService.argonLanes, 4);
      expect(KeyService.argonVersion, Argon2Parameters.ARGON2_VERSION_13);
      expect(KeyService.masterKeyLength, 32);
    });

    test('deriveMasterKey is deterministic and salt/passphrase sensitive', () {
      final saltA = bytes(KeyService.saltLength, 0x11);
      final saltB = bytes(KeyService.saltLength, 0x22);

      final mk1 = keyService.deriveMasterKey('correct horse', saltA);
      final mk2 = keyService.deriveMasterKey('correct horse', saltA);
      final mkOtherSalt = keyService.deriveMasterKey('correct horse', saltB);
      final mkOtherPass = keyService.deriveMasterKey('battery staple', saltA);

      expect(mk1.length, 32);
      expect(mk1, mk2, reason: 'same inputs must reproduce the master key');
      expect(mk1, isNot(mkOtherSalt), reason: 'salt must change the key');
      expect(mk1, isNot(mkOtherPass), reason: 'passphrase must change the key');
    });
  });

  group('HKDF-SHA256 subkey derivation', () {
    test('matches the RFC 5869 Test Case 1 known-answer vector', () async {
      final hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: 42);
      final okm = await hkdf.deriveKey(
        secretKey: SecretKey(List.filled(22, 0x0b)),
        nonce: List.generate(13, (i) => i),
        info: List.generate(10, (i) => 0xf0 + i),
      );
      expect(
        hex(await okm.extractBytes()),
        '3cb25f25faacd57a90434f64d0362f2a2d2d0a90cf1a5a4c5db02d56ecc4c5bf'
        '34007208d5b887185865',
      );
    });

    test('subkeys match pinned regression vectors (MK = 0x2a * 32)', () async {
      final keys = await keyService.deriveSubkeys(bytes(32, 0x2a));
      expect(
        hex(keys.databaseKey),
        'd5949256bde7e9090f167088382173cff7a9ffbc54050d4f89ca0c16e87076f2',
      );
      expect(
        hex(keys.keyEncryptionKey),
        'be2fe3fede3b6eed544ce4b355f2980d0e9e714a638ab0be7318443255c720b9',
      );
      expect(
        hex(keys.fingerprintHmacKey),
        '518bb290d88e8c47b0f5003469ff96aa117873ea27d447507a2f5891460697c5',
      );
      expect(
        hex(keys.syncKey),
        'b86bca7af3b47e3d358e94dc6ace544d243eeaa8bf08072258f878882e8ae2d4',
      );
    });

    test('the four subkeys are 32 bytes and mutually distinct', () async {
      final keys = await keyService.deriveSubkeys(bytes(32, 0x07));
      final all = [
        keys.databaseKey,
        keys.keyEncryptionKey,
        keys.fingerprintHmacKey,
        keys.syncKey,
      ];
      for (final k in all) {
        expect(k.length, 32);
      }
      final distinct = all.map(hex).toSet();
      expect(distinct.length, 4, reason: 'domain separation must hold');
    });

    test('deriveSubkeys is deterministic for the same master key', () async {
      final mk = bytes(32, 0x5c);
      final a = await keyService.deriveSubkeys(mk);
      final b = await keyService.deriveSubkeys(mk);
      expect(hex(a.databaseKey), hex(b.databaseKey));
      expect(hex(a.keyEncryptionKey), hex(b.keyEncryptionKey));
    });

    test('destroy() zeroes every subkey buffer (best effort)', () async {
      final keys = await keyService.deriveSubkeys(bytes(32, 0x5c));
      keys.destroy();
      expect(keys.databaseKey.every((b) => b == 0), isTrue);
      expect(keys.keyEncryptionKey.every((b) => b == 0), isTrue);
      expect(keys.fingerprintHmacKey.every((b) => b == 0), isTrue);
      expect(keys.syncKey.every((b) => b == 0), isTrue);
    });
  });

  group('DEK wrap / unwrap (AES-256-GCM under the KEK)', () {
    test('round-trips the DEK', () async {
      final kek = bytes(32, 0x33);
      final dek = keyService.generateDek();
      final wrapped = await keyService.wrapDek(dek, kek);
      final unwrapped = await keyService.unwrapDek(wrapped, kek);
      expect(unwrapped, dek);
      expect(dek.length, KeyService.dekLength);
    });

    test('rejects the wrong KEK', () async {
      final dek = keyService.generateDek();
      final wrapped = await keyService.wrapDek(dek, bytes(32, 0x33));
      expect(
        () => keyService.unwrapDek(wrapped, bytes(32, 0x44)),
        throwsA(isA<SecretBoxAuthenticationError>()),
      );
    });

    test(
      'uses a fresh nonce so the same DEK wraps to different bytes',
      () async {
        final kek = bytes(32, 0x33);
        final dek = keyService.generateDek();
        final w1 = await keyService.wrapDek(dek, kek);
        final w2 = await keyService.wrapDek(dek, kek);
        expect(w1, isNot(w2), reason: 'nonce reuse would be catastrophic');
        expect(await keyService.unwrapDek(w1, kek), dek);
        expect(await keyService.unwrapDek(w2, kek), dek);
      },
    );
  });

  group('Argon2id salt persistence (plaintext salt store)', () {
    test('loadOrCreateSalt generates, persists, and is stable', () async {
      expect(await keyService.hasSalt(), isFalse);

      final salt = await keyService.loadOrCreateSalt();
      expect(salt.length, KeyService.saltLength);
      expect(await keyService.hasSalt(), isTrue);

      final again = await keyService.loadOrCreateSalt();
      expect(again, salt, reason: 'the salt must survive across unlocks');
      expect(await keyService.readSalt(), salt);
    });

    test('readSalt is null before the vault is initialized', () async {
      expect(await keyService.readSalt(), isNull);
    });

    test('deleteSalt clears the salt', () async {
      await keyService.loadOrCreateSalt();
      await keyService.deleteSalt();
      expect(await keyService.hasSalt(), isFalse);
      expect(await keyService.readSalt(), isNull);
    });

    test(
      'migrates a legacy flutter_secure_storage salt into the file',
      () async {
        // Older install: salt only in the legacy secure store, none in the file.
        final legacySalt = Uint8List.fromList(List.generate(16, (i) => i));
        await legacy.write(KeyService.saltStorageKey, base64Encode(legacySalt));
        expect(await saltStore.exists(), isFalse);

        // readSalt returns it AND migrates it into the file store.
        expect(await keyService.readSalt(), legacySalt);
        expect(await saltStore.read(), legacySalt);
        expect(await keyService.hasSalt(), isTrue);
      },
    );

    test('a broken legacy store is treated as no salt (no throw)', () async {
      keyService = KeyService(
        saltStore,
        legacyStore: _ThrowingSecureKeyStore(),
      );
      expect(await keyService.hasSalt(), isFalse);
      expect(await keyService.readSalt(), isNull);
    });
  });
}

class _InMemorySaltStore implements SaltStore {
  Uint8List? _salt;
  @override
  Future<Uint8List?> read() async => _salt;
  @override
  Future<void> write(Uint8List salt) async => _salt = Uint8List.fromList(salt);
  @override
  Future<bool> exists() async => _salt != null;
  @override
  Future<void> delete() async => _salt = null;
}

class _ThrowingSecureKeyStore implements SecureKeyStore {
  @override
  Future<bool> containsKey(String key) async => throw Exception('keystore');
  @override
  Future<void> delete(String key) async => throw Exception('keystore');
  @override
  Future<String?> read(String key) async => throw Exception('keystore');
  @override
  Future<void> write(String key, String value) async =>
      throw Exception('keystore');
}

class _FakeSecureKeyStore implements SecureKeyStore {
  final Map<String, String> _data = {};

  @override
  Future<bool> containsKey(String key) async => _data.containsKey(key);

  @override
  Future<void> delete(String key) async => _data.remove(key);

  @override
  Future<String?> read(String key) async => _data[key];

  @override
  Future<void> write(String key, String value) async => _data[key] = value;
}
