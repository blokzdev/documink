import 'dart:typed_data';

import 'package:documink/features/anonymization/ff1.dart';
import 'package:documink/features/anonymization/fpe_operator.dart';
import 'package:flutter_test/flutter_test.dart';

Uint8List _hex(String s) {
  final out = Uint8List(s.length ~/ 2);
  for (var i = 0; i < out.length; i++) {
    out[i] = int.parse(s.substring(i * 2, i * 2 + 2), radix: 16);
  }
  return out;
}

void main() {
  // NIST SP 800-38G FF1 sample vectors (AES-128).
  final key128 = _hex('2B7E151628AED2A6ABF7158809CF4F3C');
  final plain = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];

  group('FF1 NIST known-answer vectors (AES-128, radix 10)', () {
    final ff1 = Ff1(key: key128, radix: 10);

    test('sample 1 — empty tweak', () {
      final ct = ff1.encrypt(plain, tweak: Uint8List(0));
      expect(ct.join(), '2433477484');
      expect(ff1.decrypt(ct, tweak: Uint8List(0)), plain);
    });

    test('sample 2 — non-empty tweak', () {
      final tweak = _hex('39383736353433323130');
      final ct = ff1.encrypt(plain, tweak: tweak);
      expect(ct.join(), '6124200773');
      expect(ff1.decrypt(ct, tweak: tweak), plain);
    });

    test('radix 36 round-trips (exercises the radix>10 path)', () {
      final ff36 = Ff1(key: key128, radix: 36);
      final tweak = _hex('3737373770717273373737');
      final x = [
        for (final c in '0123456789abcdefghi'.codeUnits)
          c <= 0x39 ? c - 0x30 : c - 0x61 + 10,
      ];
      final ct = ff36.encrypt(x, tweak: tweak);
      expect(ct, isNot(x));
      expect(ff36.decrypt(ct, tweak: tweak), x);
    });

    test('rejects fewer than 2 numerals', () {
      expect(() => ff1.encrypt([5], tweak: Uint8List(0)), throwsArgumentError);
    });
  });

  group('FpeOperator (digit strings)', () {
    final key = _hex('2B7E151628AED2A6ABF7158809CF4F3C');
    final fpe = FpeOperator(key);
    final tweak = FpeOperator.tweakFor('CREDIT_CARD', 'ws1');

    test('preserves format and separators, and round-trips', () {
      const card = '4111 1111 1111 1111';
      final enc = fpe.encryptDigits(card, tweak: tweak);
      expect(enc, isNot(card));
      expect(enc, matches(RegExp(r'^\d{4} \d{4} \d{4} \d{4}$')));
      expect(fpe.decryptDigits(enc, tweak: tweak), card);
    });

    test('keepClear leaves the last N digits untouched', () {
      const card = '4111 1111 1111 1234';
      final enc = fpe.encryptDigits(card, tweak: tweak, keepClear: 4);
      expect(enc.endsWith('1234'), isTrue);
      expect(fpe.decryptDigits(enc, tweak: tweak, keepClear: 4), card);
    });

    test('tweak depends on (entity_type, workspace_id)', () {
      const card = '4111 1111 1111 1111';
      final a = fpe.encryptDigits(
        card,
        tweak: FpeOperator.tweakFor('MRN', 'ws1'),
      );
      final b = fpe.encryptDigits(
        card,
        tweak: FpeOperator.tweakFor('MRN', 'ws2'),
      );
      expect(a, isNot(b)); // different workspace → different ciphertext
    });

    test('throws when too few digits to encrypt', () {
      expect(
        () => fpe.encryptDigits('id 7', tweak: tweak),
        throwsArgumentError,
      );
    });
  });
}
