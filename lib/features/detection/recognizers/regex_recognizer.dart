import '../pii_recognizer.dart';
import '../pii_span.dart';

/// Base for Tier 1 regex/checksum recognizers (blueprint §4.2). Subclasses
/// supply a [pattern] and [label]; optional [isValid]/[scoreFor] hooks add
/// checksum/structure validation and per-match confidence.
///
/// Tier 1 detectors share a low [priority] so that later, more contextual tiers
/// win overlap ties on equal confidence (§4.5).
abstract class RegexRecognizer extends PiiRecognizer {
  /// Default Tier 1 overlap priority.
  static const int tier1Priority = 10;

  RegExp get pattern;
  String get label;

  @override
  int get priority => tier1Priority;

  /// Structural/checksum validation beyond the regex (default: accept).
  bool isValid(RegExpMatch match) => true;

  /// Per-match confidence (default: high but below checksum-verified detectors).
  double scoreFor(RegExpMatch match) => 0.95;

  @override
  List<DetectedSpan> recognize(String text) {
    final spans = <DetectedSpan>[];
    for (final match in pattern.allMatches(text)) {
      if (!isValid(match)) continue;
      spans.add(
        DetectedSpan(
          start: match.start,
          end: match.end,
          label: label,
          text: match.group(0)!,
          detector: name,
          score: scoreFor(match),
          priority: priority,
        ),
      );
    }
    return spans;
  }
}
