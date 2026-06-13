import 'pii_span.dart';

/// Resolves overlapping detections into a non-overlapping set (blueprint §4.5,
/// Presidio-style): when spans overlap, keep the highest-confidence one;
/// tiebreak by longer span, then by higher detector priority.
///
/// Implemented as a greedy pass over spans sorted best-first: a span is kept
/// unless it overlaps one already kept. Touching spans (`a.end == b.start`)
/// do not overlap and so both survive. The result is returned sorted by start.
class OverlapResolver {
  const OverlapResolver();

  List<DetectedSpan> resolve(List<DetectedSpan> spans) {
    final ordered = [...spans]..sort(_bestFirst);
    final kept = <DetectedSpan>[];
    for (final span in ordered) {
      if (kept.any((k) => k.overlaps(span))) continue;
      kept.add(span);
    }
    kept.sort((a, b) => a.start.compareTo(b.start));
    return kept;
  }

  /// Higher score → longer span → higher priority → earlier start (for a stable,
  /// deterministic order on full ties).
  int _bestFirst(DetectedSpan a, DetectedSpan b) {
    final byScore = b.score.compareTo(a.score);
    if (byScore != 0) return byScore;
    final byLength = b.length.compareTo(a.length);
    if (byLength != 0) return byLength;
    final byPriority = b.priority.compareTo(a.priority);
    if (byPriority != 0) return byPriority;
    return a.start.compareTo(b.start);
  }
}
