import '../pii_span.dart';
import 'regex_recognizer.dart';

/// Detects email addresses (blueprint §4.2). Pragmatic RFC-5322 subset — the
/// common `local@domain.tld` shape, not the full grammar.
class EmailRecognizer extends RegexRecognizer {
  @override
  String get name => 'email';

  @override
  String get label => PiiLabels.email;

  @override
  RegExp get pattern => _pattern;

  static final RegExp _pattern = RegExp(
    r"[A-Za-z0-9._%+\-]+@[A-Za-z0-9](?:[A-Za-z0-9\-]*[A-Za-z0-9])?"
    r"(?:\.[A-Za-z0-9](?:[A-Za-z0-9\-]*[A-Za-z0-9])?)*\.[A-Za-z]{2,}",
  );

  @override
  double scoreFor(RegExpMatch match) => 0.98;
}
