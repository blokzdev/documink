import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'detection_pipeline.dart';
import 'pii_recognizer.dart';

/// The registered detectors. Empty in 2a; Tier 1 (2b), Tier 2 (2c), and Tier 3
/// (2d) recognizers are appended via overrides/composition as they land.
final piiRecognizersProvider = Provider<List<PiiRecognizer>>((ref) {
  return const [];
});

/// The assembled detection pipeline (normalize → recognize → resolve).
final detectionPipelineProvider = Provider<DetectionPipeline>((ref) {
  return DetectionPipeline(ref.watch(piiRecognizersProvider));
});
