import '../pii_span.dart';
import 'regex_recognizer.dart';

/// Detects IBANs (blueprint §4.2): 2-letter country + 2 check digits + up to 30
/// alphanumerics, validated by the **ISO 7064 mod-97-10** checksum.
class IbanRecognizer extends RegexRecognizer {
  @override
  String get name => 'iban';

  @override
  String get label => PiiLabels.iban;

  @override
  RegExp get pattern => _pattern;

  static final RegExp _pattern = RegExp(r'\b[A-Z]{2}\d{2}[A-Z0-9]{11,30}\b');

  @override
  bool isValid(RegExpMatch match) => _mod97(match.group(0)!) == 1;

  @override
  double scoreFor(RegExpMatch match) => 0.99;

  /// Rearrange (first 4 chars to the end), map A–Z → 10–35, take mod 97.
  static int _mod97(String iban) {
    final rearranged = iban.substring(4) + iban.substring(0, 4);
    var remainder = 0;
    for (final unit in rearranged.codeUnits) {
      final int value;
      if (unit >= 0x41 && unit <= 0x5A) {
        value = unit - 0x41 + 10; // A=10 … Z=35
      } else {
        value = unit - 0x30; // '0'..'9'
      }
      // Fold digit-by-digit to avoid big-int overflow.
      remainder = (remainder * (value >= 10 ? 100 : 10) + value) % 97;
    }
    return remainder;
  }
}
