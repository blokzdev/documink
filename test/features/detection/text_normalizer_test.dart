import 'package:documink/features/detection/text_normalizer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const normalizer = TextNormalizer();

  test('NFC composes decomposed sequences', () {
    // 'e' + combining acute accent (U+0301) → 'é' (U+00E9).
    final decomposed = String.fromCharCodes([0x65, 0x0301]);
    final result = normalizer.normalize(decomposed);
    expect(result.runes.length, 1);
    expect(result, 'é');
  });

  test('strips zero-width characters', () {
    final input = String.fromCharCodes([
      0x61, // a
      0x200B, // ZWSP
      0x62, // b
      0x200D, // ZWJ
      0xFEFF, // BOM/ZWNBSP
      0x63, // c
    ]);
    expect(normalizer.normalize(input), 'abc');
  });

  test('rejoins words hyphen-split across a line break', () {
    expect(normalizer.normalize('co-\noperate'), 'cooperate');
    expect(normalizer.normalize('co-\r\noperate'), 'cooperate');
  });

  test('preserves ordinary newlines (paragraph structure)', () {
    expect(normalizer.normalize('line one\nline two'), 'line one\nline two');
  });

  test('leaves already-normalized ASCII unchanged', () {
    const input = 'alice@example.com called +1 555 0100';
    expect(normalizer.normalize(input), input);
  });
}
