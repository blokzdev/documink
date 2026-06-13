import 'package:unorm_dart/unorm_dart.dart' as unorm;

/// Normalizes input before detection (blueprint §4.1, "Normalize" stage) so
/// recognizers see a single canonical form. All detection offsets are relative
/// to this normalized output, not the original input.
///
/// Steps:
///   1. **Unicode NFC** — canonical composition, so visually identical text has
///      one byte form (e.g. decomposed `e` + combining acute → `é`), keeping
///      regex matching and span offsets consistent.
///   2. **Line-join** — rejoin words hyphen-split across a line break
///      (`"co-\noperate"` → `"cooperate"`), common in PDF/OCR extraction. Only
///      hyphenated breaks are joined; other newlines (paragraph structure) are
///      preserved.
///   3. **Strip zero-width** characters that would otherwise split a match.
class TextNormalizer {
  const TextNormalizer();

  /// ZWSP, ZWNJ, ZWJ, word-joiner, BOM/ZWNBSP.
  static const List<int> zeroWidthCodeUnits = [
    0x200B,
    0x200C,
    0x200D,
    0x2060,
    0xFEFF,
  ];

  static final RegExp _hyphenLineBreak = RegExp(r'-\r?\n');
  static final RegExp _zeroWidth = RegExp(
    '[${String.fromCharCodes(zeroWidthCodeUnits)}]',
  );

  String normalize(String input) {
    final composed = unorm.nfc(input);
    final joined = composed.replaceAll(_hyphenLineBreak, '');
    return joined.replaceAll(_zeroWidth, '');
  }
}
