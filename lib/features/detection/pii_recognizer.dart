import 'dart:async';

import 'pii_span.dart';

/// A single PII detector (blueprint §4.2/§4.3). Tier 1 recognizers are pure
/// Dart and return synchronously; Tier 3 (GLiNER ONNX) is async — hence the
/// [FutureOr] return so the pipeline can await both uniformly.
///
/// Implementations receive the already-**normalized** text and must return
/// spans whose offsets index into that same string.
abstract class PiiRecognizer {
  /// Stable identifier recorded on each span (audit + overlap tiebreak).
  String get name;

  /// Overlap-resolution priority (higher wins ties). Conventionally the tier:
  /// later, more contextual tiers outrank earlier ones on equal confidence.
  int get priority;

  /// Detects spans in [text]. Must not mutate [text]; offsets index into it.
  FutureOr<List<DetectedSpan>> recognize(String text);
}
