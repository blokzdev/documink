import '../pii_span.dart';
import 'regex_recognizer.dart';

/// Detects passport numbers (blueprint §4.2). Passport-number formats vary by
/// country and overlap heavily with ordinary alphanumerics, so this is
/// keyword-anchored: it requires a `passport`-style prefix, then captures the
/// 6–9 char alphanumeric identifier (lookbehind keeps the span on the number).
///
/// This favors precision over recall; un-prefixed passport numbers are left to
/// Tier 3 (GLiNER) context detection.
class PassportRecognizer extends RegexRecognizer {
  @override
  String get name => 'passport';

  @override
  String get label => PiiLabels.passport;

  @override
  RegExp get pattern => _pattern;

  // Require at least one digit so letter-only words after "passport"
  // (e.g. "passport details") are not mistaken for a number.
  static final RegExp _pattern = RegExp(
    r'(?<=\bpassport(?: number| no\.?| #)?[\s:#]{0,3})'
    r'(?=[A-Z0-9]*\d)[A-Z0-9]{6,9}\b',
    caseSensitive: false,
  );

  @override
  double scoreFor(RegExpMatch match) => 0.85;
}
