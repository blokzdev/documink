/// A detected span of potentially-sensitive text (blueprint §4).
///
/// Offsets are **half-open** `[start, end)` into the *normalized* text the
/// pipeline produced (see `TextNormalizer`) — not the original input. Two spans
/// "overlap" when their ranges intersect; spans that merely touch
/// (`a.end == b.start`) do not.
class DetectedSpan {
  const DetectedSpan({
    required this.start,
    required this.end,
    required this.label,
    required this.text,
    required this.detector,
    this.score = 1.0,
    this.priority = 0,
  }) : assert(start >= 0, 'start must be non-negative'),
       assert(end > start, 'end must be greater than start'),
       assert(score >= 0 && score <= 1, 'score must be in [0, 1]');

  /// Inclusive start offset into the normalized text.
  final int start;

  /// Exclusive end offset into the normalized text.
  final int end;

  /// Entity type, e.g. `PiiLabels.email`. Open string to allow custom types
  /// (`custom_entity_types`), so not a closed enum.
  final String label;

  /// The matched substring (from the normalized text).
  final String text;

  /// Detector that produced this span (for audit + priority tiebreak).
  final String detector;

  /// Confidence in `[0, 1]`. Deterministic Tier 1 recognizers use `1.0`.
  final double score;

  /// Detector priority for overlap tiebreaks (higher wins). Typically the tier
  /// or a configured rank.
  final int priority;

  int get length => end - start;

  /// Whether this span's range intersects [other]'s (half-open).
  bool overlaps(DetectedSpan other) => start < other.end && other.start < end;

  @override
  bool operator ==(Object other) =>
      other is DetectedSpan &&
      other.start == start &&
      other.end == end &&
      other.label == label &&
      other.text == text &&
      other.detector == detector &&
      other.score == score &&
      other.priority == priority;

  @override
  int get hashCode =>
      Object.hash(start, end, label, text, detector, score, priority);

  @override
  String toString() =>
      'DetectedSpan($label [$start,$end) "$text" by $detector @${score.toStringAsFixed(2)})';
}

/// Canonical built-in entity-type labels. They double as the keys of the policy
/// engine (blueprint §4.6), so the strings are stable and uppercase. Custom
/// entity types contribute their own labels at runtime.
abstract final class PiiLabels {
  static const String person = 'PERSON';
  static const String email = 'EMAIL';
  static const String phone = 'PHONE';
  static const String ssn = 'SSN';
  static const String creditCard = 'CREDIT_CARD';
  static const String iban = 'IBAN';
  static const String url = 'URL';
  static const String ipAddress = 'IP_ADDRESS';
  static const String date = 'DATE';
  static const String dateOfBirth = 'DATE_OF_BIRTH';
  static const String mrn = 'MRN';
  static const String passport = 'PASSPORT';
  static const String location = 'LOCATION';
}
