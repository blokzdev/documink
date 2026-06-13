import '../pii_span.dart';
import 'regex_recognizer.dart';

/// Detects Medical Record Numbers (blueprint §4.2). Keyword-anchored: requires
/// an `MRN`/`Medical Record No.`-style prefix, then captures only the 6–10 digit
/// identifier (via lookbehind, so the span is the number, not the label). This
/// anchoring avoids matching arbitrary numbers as MRNs.
class MrnRecognizer extends RegexRecognizer {
  @override
  String get name => 'mrn';

  @override
  String get label => PiiLabels.mrn;

  @override
  RegExp get pattern => _pattern;

  static final RegExp _pattern = RegExp(
    r'(?<=\b(?:MRN|medical record(?: number| no\.?| #)?)[\s:#]{0,3})\d{6,10}\b',
    caseSensitive: false,
  );

  @override
  double scoreFor(RegExpMatch match) => 0.9;
}
