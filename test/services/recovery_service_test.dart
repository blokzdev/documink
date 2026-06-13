import 'dart:typed_data';

import 'package:documink/services/key_service.dart';
import 'package:documink/services/recovery_service.dart';
import 'package:documink/services/secure_key_store.dart';
import 'package:flutter_test/flutter_test.dart';

/// BIP-39 recovery-phrase codec tests for V1 Phase 1d (blueprint §8.4).
///
/// Anchored to the canonical Trezor BIP-39 256-bit known-answer vectors, plus
/// round-trip + subkey-re-derivation and rejection of malformed phrases. The
/// codec uses the entropy path so the exact Master Key bytes survive the trip.
void main() {
  final recovery = RecoveryService();

  Uint8List filled(int value) =>
      Uint8List.fromList(List.filled(RecoveryService.masterKeyLength, value));

  String repeat(String word, int times) => List.filled(times, word).join(' ');

  group('Trezor 256-bit known-answer vectors', () {
    final cases = <Uint8List, String>{
      filled(0x00): '${repeat('abandon', 23)} art',
      filled(0xff): '${repeat('zoo', 23)} vote',
      filled(0x80):
          '${repeat('letter advice cage absurd amount doctor '
          'acoustic avoid', 2)} letter advice cage absurd amount doctor '
          'acoustic bless',
    };

    cases.forEach((entropy, mnemonic) {
      test('encodes ${mnemonic.split(' ').first}… and decodes back', () {
        expect(recovery.encodeMasterKey(entropy), mnemonic);
        expect(recovery.decodeMnemonic(mnemonic), entropy);
      });
    });
  });

  group('round-trip', () {
    test('arbitrary master key survives encode → decode', () {
      final mk = Uint8List.fromList(
        List.generate(32, (i) => (i * 7 + 3) & 0xff),
      );
      final phrase = recovery.encodeMasterKey(mk);
      expect(phrase.split(' ').length, RecoveryService.wordCount);
      expect(recovery.decodeMnemonic(phrase), mk);
    });

    test('decoded key re-derives identical subkeys', () async {
      final keyService = KeyService(_NoopSecureKeyStore());
      final mk = Uint8List.fromList(
        List.generate(32, (i) => (i * 13 + 1) & 0xff),
      );
      final restored = recovery.decodeMnemonic(recovery.encodeMasterKey(mk));

      final a = await keyService.deriveSubkeys(mk);
      final b = await keyService.deriveSubkeys(restored);
      expect(b.databaseKey, a.databaseKey);
      expect(b.keyEncryptionKey, a.keyEncryptionKey);
      expect(b.fingerprintHmacKey, a.fingerprintHmacKey);
      expect(b.syncKey, a.syncKey);
    });
  });

  group('validation & rejection', () {
    test('isValid accepts a real 24-word phrase', () {
      expect(recovery.isValid('${repeat('abandon', 23)} art'), isTrue);
    });

    test('isValid rejects a bad checksum, wrong length, and gibberish', () {
      expect(recovery.isValid(repeat('abandon', 24)), isFalse); // bad checksum
      expect(
        recovery.isValid('${repeat('abandon', 11)} about'),
        isFalse,
      ); // 12 words
      expect(recovery.isValid('not in the wordlist at all'), isFalse);
    });

    test('decodeMnemonic throws on a bad checksum', () {
      expect(
        () => recovery.decodeMnemonic(repeat('abandon', 24)),
        throwsFormatException,
      );
    });

    test('decodeMnemonic throws on a 12-word (128-bit) phrase', () {
      // Valid BIP-39, but not a 256-bit master key.
      expect(
        () => recovery.decodeMnemonic('${repeat('abandon', 11)} about'),
        throwsFormatException,
      );
    });

    test('encodeMasterKey rejects a non-32-byte key', () {
      expect(
        () => recovery.encodeMasterKey(Uint8List(31)),
        throwsArgumentError,
      );
    });

    test('tolerates casing and extra whitespace on re-entry', () {
      final phrase = recovery.encodeMasterKey(filled(0x00));
      final messy = '  ${phrase.toUpperCase().replaceAll(' ', '   ')}  ';
      expect(recovery.decodeMnemonic(messy), filled(0x00));
    });
  });

  group('confirm-by-re-entry', () {
    test('confirms the matching phrase and rejects a different one', () {
      final mk = filled(0x00);
      final phrase = recovery.encodeMasterKey(mk);
      expect(recovery.confirms(phrase, mk), isTrue);

      final otherPhrase = recovery.encodeMasterKey(filled(0xff));
      expect(recovery.confirms(otherPhrase, mk), isFalse);
      expect(recovery.confirms('garbage words', mk), isFalse);
    });
  });
}

/// deriveSubkeys never touches the store, so a no-op suffices here.
class _NoopSecureKeyStore implements SecureKeyStore {
  @override
  Future<bool> containsKey(String key) async => false;

  @override
  Future<void> delete(String key) async {}

  @override
  Future<String?> read(String key) async => null;

  @override
  Future<void> write(String key, String value) async {}
}
