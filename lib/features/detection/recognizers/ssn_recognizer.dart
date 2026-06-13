import '../pii_span.dart';
import 'regex_recognizer.dart';

/// Detects US Social Security Numbers (blueprint §4.2) with SSA structural
/// validity: area ≠ 000/666/900–999, group ≠ 00, serial ≠ 0000. Accepts `-` or
/// space separators (bare 9-digit runs are intentionally not matched, to avoid
/// false positives against arbitrary numbers).
class SsnRecognizer extends RegexRecognizer {
  @override
  String get name => 'ssn';

  @override
  String get label => PiiLabels.ssn;

  @override
  RegExp get pattern => _pattern;

  static final RegExp _pattern = RegExp(r'\b(\d{3})[- ](\d{2})[- ](\d{4})\b');

  @override
  bool isValid(RegExpMatch match) {
    final area = int.parse(match.group(1)!);
    final group = int.parse(match.group(2)!);
    final serial = int.parse(match.group(3)!);
    if (area == 0 || area == 666 || area >= 900) return false;
    if (group == 0) return false;
    if (serial == 0) return false;
    return true;
  }

  @override
  double scoreFor(RegExpMatch match) => 0.95;
}
