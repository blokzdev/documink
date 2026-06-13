import '../pii_recognizer.dart';
import '../pii_span.dart';
import 'regex_recognizer.dart';

/// Detects dates (blueprint §4.2): ISO 8601, common numeric slash/dot forms
/// (deliberately accepting ambiguous DD/MM vs MM/DD), and textual month-name
/// forms. Labelled generically as `DATE`; distinguishing `DATE_OF_BIRTH`
/// requires context and is left to Tier 3/4.
///
/// Scored conservatively (dates are common and often non-sensitive); the policy
/// engine decides what to do with them.
class DateRecognizer extends PiiRecognizer {
  @override
  String get name => 'date';

  @override
  int get priority => RegexRecognizer.tier1Priority;

  static const String _month =
      r'(?:Jan(?:uary)?|Feb(?:ruary)?|Mar(?:ch)?|Apr(?:il)?|May|Jun(?:e)?|'
      r'Jul(?:y)?|Aug(?:ust)?|Sep(?:t(?:ember)?)?|Oct(?:ober)?|Nov(?:ember)?|'
      r'Dec(?:ember)?)';

  static final List<RegExp> _patterns = [
    // ISO 8601: 2020-01-31
    RegExp(r'\b\d{4}-(?:0[1-9]|1[0-2])-(?:0[1-9]|[12]\d|3[01])\b'),
    // Numeric slash/dot: 1/31/2020, 31.01.2020, 01/31/20
    RegExp(
      r'\b(?:0?[1-9]|[12]\d|3[01])[/.](?:0?[1-9]|1[0-2])[/.](?:\d{4}|\d{2})\b'
      r'|\b(?:0?[1-9]|1[0-2])[/.](?:0?[1-9]|[12]\d|3[01])[/.](?:\d{4}|\d{2})\b',
    ),
    // Textual: January 5, 2020  /  Jan 5 2020
    RegExp(
      '\\b$_month\\.?\\s+\\d{1,2}(?:st|nd|rd|th)?,?\\s+\\d{4}\\b',
      caseSensitive: false,
    ),
    // Textual: 5 January 2020  /  5th Jan 2020
    RegExp(
      '\\b\\d{1,2}(?:st|nd|rd|th)?\\s+$_month\\.?,?\\s+\\d{4}\\b',
      caseSensitive: false,
    ),
  ];

  @override
  List<DetectedSpan> recognize(String text) {
    final byRange = <int, DetectedSpan>{};
    for (final pattern in _patterns) {
      for (final match in pattern.allMatches(text)) {
        // Dedup overlapping matches from multiple patterns; keep the longest
        // for a given start offset.
        final existing = byRange[match.start];
        if (existing != null && existing.end >= match.end) continue;
        byRange[match.start] = DetectedSpan(
          start: match.start,
          end: match.end,
          label: PiiLabels.date,
          text: match.group(0)!,
          detector: name,
          score: 0.8,
          priority: priority,
        );
      }
    }
    return byRange.values.toList();
  }
}
