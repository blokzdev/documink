import 'package:documink/features/anonymization/operator.dart';
import 'package:documink/features/custom_entities/custom_entity_definition.dart';
import 'package:documink/features/custom_entities/custom_entity_recognizer.dart';
import 'package:flutter_test/flutter_test.dart';

CustomEntityDefinition _def({
  required String label,
  required String pattern,
  CustomValidator validator = CustomValidator.none,
}) => CustomEntityDefinition(
  id: 'id-$label',
  workspaceId: 'ws',
  label: label,
  regexPattern: pattern,
  validator: validator,
  defaultOperator: Operator.redact,
  createdAtEpochMs: 0,
);

void main() {
  test('emits spans for matches, labelled with the entity label', () {
    final r = CustomEntityRecognizer([
      _def(label: 'PROVIDER_NPI', pattern: r'\d{10}'),
    ]);
    final spans = r.recognize('NPI 1234567890 on file');
    expect(spans, hasLength(1));
    expect(spans.single.label, 'PROVIDER_NPI');
    expect(spans.single.text, '1234567890');
    expect(spans.single.detector, 'custom');
  });

  test('luhn validator filters non-checksum-valid matches', () {
    final r = CustomEntityRecognizer([
      _def(label: 'CARD', pattern: r'\d{16}', validator: CustomValidator.luhn),
    ]);
    // 4111111111111111 passes Luhn; 4111111111111112 fails.
    final spans = r.recognize('a 4111111111111111 b 4111111111111112 c');
    expect(spans, hasLength(1));
    expect(spans.single.text, '4111111111111111');
  });

  test('runs multiple definitions over the same text', () {
    final r = CustomEntityRecognizer([
      _def(label: 'CODE', pattern: r'[A-Z]{3}-\d{2}'),
      _def(label: 'TAG', pattern: r'#\w+'),
    ]);
    final spans = r.recognize('ref ABC-12 and #urgent');
    expect(spans.map((s) => s.label).toSet(), {'CODE', 'TAG'});
  });
}
