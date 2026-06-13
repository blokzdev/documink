import 'dart:async';

import 'overlap_resolver.dart';
import 'pii_recognizer.dart';
import 'pii_span.dart';
import 'text_normalizer.dart';

/// The output of a detection run: the normalized text the offsets index into,
/// plus the resolved, non-overlapping spans.
class DetectionResult {
  const DetectionResult({required this.normalizedText, required this.spans});

  final String normalizedText;
  final List<DetectedSpan> spans;
}

/// Orchestrates the detection pipeline (blueprint §4.1): normalize → run every
/// registered [PiiRecognizer] over the normalized text → resolve overlaps.
///
/// 2a ships the orchestrator with the normalizer and overlap resolver; the
/// Tier 1–3 recognizers register into [piiRecognizersProvider] in 2b–2d. With
/// no recognizers it simply returns an empty span list for normalized input.
class DetectionPipeline {
  const DetectionPipeline(
    this._recognizers, {
    TextNormalizer normalizer = const TextNormalizer(),
    OverlapResolver resolver = const OverlapResolver(),
  }) : _normalizer = normalizer,
       _resolver = resolver;

  final List<PiiRecognizer> _recognizers;
  final TextNormalizer _normalizer;
  final OverlapResolver _resolver;

  Future<DetectionResult> detect(String input) async {
    final text = _normalizer.normalize(input);
    final results = await Future.wait([
      for (final recognizer in _recognizers)
        Future.sync(() => recognizer.recognize(text)),
    ]);
    final all = [for (final spans in results) ...spans];
    return DetectionResult(normalizedText: text, spans: _resolver.resolve(all));
  }
}
