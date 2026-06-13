import '../pii_span.dart';
import 'regex_recognizer.dart';

/// Detects web URLs (blueprint §4.2): `http(s)://…` and bare `www.…` hosts.
/// The final character class drops trailing sentence punctuation so
/// `"see http://x.com."` does not capture the period.
class UrlRecognizer extends RegexRecognizer {
  @override
  String get name => 'url';

  @override
  String get label => PiiLabels.url;

  @override
  RegExp get pattern => _pattern;

  static final RegExp _pattern = RegExp(
    r'(?:https?://|www\.)[^\s<>"]*[^\s<>".,;:!?)\]}]',
    caseSensitive: false,
  );
}
