import 'dart:math';
import 'dart:typed_data';

import 'package:documink/data/tokens_dao.dart';
import 'package:documink/features/anonymization/reversible_operators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Uint8List bytes(int fill) => Uint8List.fromList(List.filled(32, fill));

  final crypto = TokenCrypto(dek: bytes(0x11), fingerprintHmacKey: bytes(0x22));
  // Seeded RNG → deterministic surrogates across runs/platforms.
  ReversibleOperators ops() => ReversibleOperators(crypto, random: Random(7));

  final surrogateShape = RegExp(r'^<PERSON_[0-9A-Za-z]{6}>$');

  group('Token-Random', () {
    test(
      'mints a well-formed surrogate and round-trips the plaintext',
      () async {
        final r = ops();
        final record = await r.tokenize('Alice Smith', 'PERSON');
        expect(record.surrogate, matches(surrogateShape));
        expect(record.fingerprint, await crypto.fingerprint('Alice Smith'));
        expect(await r.revealToken(record), 'Alice Smith');
      },
    );

    test('mints distinct surrogates per call, both reversible', () async {
      final r = ops();
      final a = await r.tokenize('Bob', 'PERSON');
      final b = await r.tokenize('Bob', 'PERSON');
      expect(a.surrogate, isNot(b.surrogate));
      expect(await r.revealToken(a), 'Bob');
      expect(await r.revealToken(b), 'Bob');
    });
  });

  group('Encrypt (inline, stateless)', () {
    test('wraps and round-trips with no vault row', () async {
      final r = ops();
      final wrapper = await r.encryptInline('secret@example.com');
      expect(r.isInline(wrapper), isTrue);
      expect(wrapper, startsWith('<ENC:'));
      expect(await r.revealInline(wrapper), 'secret@example.com');
    });

    test('rejects a non-wrapper / malformed input', () async {
      final r = ops();
      expect(r.isInline('plain text'), isFalse);
      expect(() => r.revealInline('plain text'), throwsFormatException);
    });
  });
}
