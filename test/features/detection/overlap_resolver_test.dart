import 'package:documink/features/detection/overlap_resolver.dart';
import 'package:documink/features/detection/pii_span.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const resolver = OverlapResolver();

  DetectedSpan span(
    int start,
    int end, {
    double score = 1.0,
    int priority = 0,
    String label = 'X',
  }) => DetectedSpan(
    start: start,
    end: end,
    label: label,
    text: 'x' * (end - start),
    detector: 'test',
    score: score,
    priority: priority,
  );

  test('keeps non-overlapping spans, sorted by start', () {
    final out = resolver.resolve([span(10, 15), span(0, 5)]);
    expect(out.map((s) => s.start), [0, 10]);
  });

  test('touching spans both survive (half-open)', () {
    final out = resolver.resolve([span(0, 5), span(5, 10)]);
    expect(out.length, 2);
  });

  test('on overlap, highest score wins', () {
    final out = resolver.resolve([
      span(0, 5, score: 0.6),
      span(2, 8, score: 0.9),
    ]);
    expect(out.length, 1);
    expect(out.single.start, 2);
    expect(out.single.score, 0.9);
  });

  test('equal score → longer span wins', () {
    final out = resolver.resolve([
      span(0, 4, score: 0.8),
      span(0, 7, score: 0.8),
    ]);
    expect(out.single.length, 7);
  });

  test('equal score and length → higher priority wins', () {
    final out = resolver.resolve([
      span(0, 5, score: 0.8, priority: 1),
      span(0, 5, score: 0.8, priority: 3),
    ]);
    expect(out.single.priority, 3);
  });

  test(
    'nested span is dropped in favor of the higher-confidence container',
    () {
      final out = resolver.resolve([
        span(0, 20, score: 0.9),
        span(5, 10, score: 0.5),
      ]);
      expect(out.single, span(0, 20, score: 0.9));
    },
  );

  test('empty input yields empty output', () {
    expect(resolver.resolve(const []), isEmpty);
  });

  test(
    'a winner does not transitively suppress a non-overlapping neighbor',
    () {
      // [0,5) loses to [2,8); [8,12) overlaps neither winner and must survive.
      final out = resolver.resolve([
        span(0, 5, score: 0.6),
        span(2, 8, score: 0.9),
        span(8, 12, score: 0.4),
      ]);
      expect(out.map((s) => s.start), [2, 8]);
    },
  );
}
