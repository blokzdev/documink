import '../pii_span.dart';
import 'regex_recognizer.dart';

/// Detects payment card numbers (blueprint §4.2): 13–19 digit runs optionally
/// grouped by single spaces/dashes, validated by the **Luhn** checksum.
class CreditCardRecognizer extends RegexRecognizer {
  @override
  String get name => 'credit_card';

  @override
  String get label => PiiLabels.creditCard;

  @override
  RegExp get pattern => _pattern;

  // First digit, then 12–18 more digits each optionally preceded by one
  // space/dash → 13–19 digits total.
  static final RegExp _pattern = RegExp(r'\b\d(?:[ -]?\d){12,18}\b');

  @override
  bool isValid(RegExpMatch match) {
    final digits = match.group(0)!.replaceAll(RegExp(r'[ -]'), '');
    if (digits.length < 13 || digits.length > 19) return false;
    return _luhnValid(digits);
  }

  @override
  double scoreFor(RegExpMatch match) => 0.99;

  static bool _luhnValid(String digits) {
    var sum = 0;
    var double = false;
    for (var i = digits.length - 1; i >= 0; i--) {
      var d = digits.codeUnitAt(i) - 0x30;
      if (double) {
        d *= 2;
        if (d > 9) d -= 9;
      }
      sum += d;
      double = !double;
    }
    return sum % 10 == 0;
  }
}
