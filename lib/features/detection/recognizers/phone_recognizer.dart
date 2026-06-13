import 'package:phone_numbers_parser/phone_numbers_parser.dart';

import '../pii_recognizer.dart';
import '../pii_span.dart';
import 'regex_recognizer.dart';

/// Detects phone numbers (blueprint §4.2) using `phone_numbers_parser` (a
/// pure-Dart libphonenumber port) for validation.
///
/// A permissive regex finds phone-shaped candidates (so we keep their offsets),
/// then each candidate is parsed and **validity-checked** by the library —
/// pattern + length, not just shape — which rejects look-alikes (SSNs, dates,
/// order numbers). Numbers written with a `+` country code validate
/// internationally; bare national numbers are interpreted in [defaultRegion].
class PhoneRecognizer extends PiiRecognizer {
  PhoneRecognizer({this.defaultRegion = IsoCode.US});

  /// Region used to interpret national-format numbers without a `+` prefix.
  final IsoCode defaultRegion;

  @override
  String get name => 'phone';

  @override
  int get priority => RegexRecognizer.tier1Priority;

  // Phone-shaped candidate: optional +/(, a leading digit, then ≥6 more
  // digits/separators, ending on a digit; not glued to surrounding word chars.
  static final RegExp _candidate = RegExp(
    r'(?<![\w+])\+?\(?\d[\d\s().\-]{5,}\d(?![\w])',
  );

  @override
  List<DetectedSpan> recognize(String text) {
    final spans = <DetectedSpan>[];
    for (final match in _candidate.allMatches(text)) {
      final raw = match.group(0)!;
      final PhoneNumber parsed;
      try {
        parsed = PhoneNumber.parse(raw, callerCountry: defaultRegion);
      } catch (_) {
        continue; // not parseable as a phone number
      }
      if (!parsed.isValid()) continue;
      spans.add(
        DetectedSpan(
          start: match.start,
          end: match.end,
          label: PiiLabels.phone,
          text: raw,
          detector: name,
          score: 0.9,
          priority: priority,
        ),
      );
    }
    return spans;
  }
}
