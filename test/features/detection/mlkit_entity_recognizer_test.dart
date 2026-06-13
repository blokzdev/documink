import 'package:documink/features/detection/pii_span.dart';
import 'package:documink/features/detection/recognizers/mlkit_entity_recognizer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  MlKitEntityRecognizer withAnnotations(List<TextAnnotation> annotations) =>
      MlKitEntityRecognizer((_) async => annotations);

  test('maps ML Kit entity types to DocuMink labels', () async {
    final r = withAnnotations(const [
      TextAnnotation(start: 0, end: 5, text: 'a@b.c', types: ['email']),
      TextAnnotation(start: 6, end: 16, text: '4155552671', types: ['phone']),
      TextAnnotation(start: 17, end: 20, text: 'ibn', types: ['iban']),
      TextAnnotation(start: 21, end: 25, text: 'card', types: ['paymentCard']),
      TextAnnotation(start: 26, end: 30, text: 'site', types: ['url']),
      TextAnnotation(start: 31, end: 39, text: '1 Main St', types: ['address']),
      TextAnnotation(start: 40, end: 50, text: 'tomorrow', types: ['dateTime']),
    ]);
    final spans = await r.recognize('ignored');
    expect(spans.map((s) => s.label).toList(), [
      PiiLabels.email,
      PiiLabels.phone,
      PiiLabels.iban,
      PiiLabels.creditCard,
      PiiLabels.url,
      PiiLabels.location,
      PiiLabels.date,
    ]);
  });

  test('drops entity types with no PII meaning', () async {
    final r = withAnnotations(const [
      TextAnnotation(start: 0, end: 3, text: 'isb', types: ['isbn']),
      TextAnnotation(start: 4, end: 7, text: 'usd', types: ['money']),
      TextAnnotation(start: 8, end: 11, text: '???', types: ['unknown']),
    ]);
    expect(await r.recognize('ignored'), isEmpty);
  });

  test('first mappable type wins when several are reported', () async {
    final r = withAnnotations(const [
      TextAnnotation(start: 0, end: 5, text: 'x', types: ['money', 'email']),
    ]);
    final span = (await r.recognize('ignored')).single;
    expect(span.label, PiiLabels.email);
  });

  test('carries offsets/text and Tier 2 priority above Tier 1', () async {
    final r = withAnnotations(const [
      TextAnnotation(start: 2, end: 7, text: 'a@b.c', types: ['email']),
    ]);
    final span = (await r.recognize('ignored')).single;
    expect([span.start, span.end, span.text], [2, 7, 'a@b.c']);
    expect(span.detector, 'mlkit');
    expect(span.priority, MlKitEntityRecognizer.tier2Priority);
    expect(span.priority, greaterThan(10)); // above Tier 1
  });

  test('empty annotations yield no spans', () async {
    expect(await withAnnotations(const []).recognize('x'), isEmpty);
  });
}
