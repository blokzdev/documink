import 'dart:async';

import 'package:documink/features/detection/detection_pipeline.dart';
import 'package:documink/features/detection/pii_recognizer.dart';
import 'package:documink/features/detection/pii_span.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('with no recognizers, returns normalized text and no spans', () async {
    const pipeline = DetectionPipeline([]);
    final result = await pipeline.detect('co-\noperate');
    expect(result.normalizedText, 'cooperate');
    expect(result.spans, isEmpty);
  });

  test('recognizers receive the normalized text', () async {
    final recognizer = _CapturingRecognizer();
    final pipeline = DetectionPipeline([recognizer]);
    await pipeline.detect('co-\noperate');
    expect(recognizer.lastInput, 'cooperate');
  });

  test('merges recognizers and resolves overlaps across them', () async {
    final weak = _FixedRecognizer('weak', priority: 1, [
      const DetectedSpan(
        start: 0,
        end: 5,
        label: 'A',
        text: 'aaaaa',
        detector: 'weak',
        score: 0.5,
      ),
    ]);
    final strong = _FixedRecognizer('strong', priority: 2, [
      const DetectedSpan(
        start: 2,
        end: 9,
        label: 'B',
        text: 'bbbbbbb',
        detector: 'strong',
        score: 0.9,
      ),
    ]);
    final pipeline = DetectionPipeline([weak, strong]);

    final result = await pipeline.detect('abcdefghij');
    expect(result.spans.length, 1);
    expect(result.spans.single.detector, 'strong');
  });
}

class _CapturingRecognizer implements PiiRecognizer {
  String? lastInput;

  @override
  String get name => 'capturing';

  @override
  int get priority => 0;

  @override
  FutureOr<List<DetectedSpan>> recognize(String text) {
    lastInput = text;
    return const [];
  }
}

class _FixedRecognizer implements PiiRecognizer {
  _FixedRecognizer(this.name, this._spans, {required this.priority});

  @override
  final String name;

  @override
  final int priority;

  final List<DetectedSpan> _spans;

  @override
  FutureOr<List<DetectedSpan>> recognize(String text) => _spans;
}
