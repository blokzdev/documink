import 'dart:io';

import 'package:documink/features/anonymization/anonymization_policy.dart';
import 'package:documink/features/anonymization/anonymizer.dart';
import 'package:documink/features/anonymization/operator.dart';
import 'package:documink/features/detection/pii_span.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  DetectedSpan span(int start, int end, String label, String text) =>
      DetectedSpan(
        start: start,
        end: end,
        label: label,
        text: text,
        detector: 'test',
      );

  group('Operator', () {
    test('parses policy names and rejects unknown', () {
      expect(Operator.fromPolicyName('token_random'), Operator.tokenRandom);
      expect(Operator.fromPolicyName('fpe'), Operator.fpe);
      expect(() => Operator.fromPolicyName('nope'), throwsFormatException);
    });

    test('flags reversible operators', () {
      expect(Operator.tokenRandom.isReversible, isTrue);
      expect(Operator.fpe.isReversible, isTrue);
      expect(Operator.encrypt.isReversible, isTrue);
      expect(Operator.redact.isReversible, isFalse);
      expect(Operator.mask.isReversible, isFalse);
      expect(Operator.replace.isReversible, isFalse);
    });
  });

  group('AnonymizationPolicy', () {
    const yaml = '''
DEFAULT: redact
PERSON: token_random
EMAIL: mask
CREDIT_CARD: fpe
''';

    test('parses mappings and DEFAULT fallback', () {
      final policy = AnonymizationPolicy.fromYaml(yaml);
      expect(policy.operatorFor('PERSON'), Operator.tokenRandom);
      expect(policy.operatorFor('EMAIL'), Operator.mask);
      expect(policy.operatorFor('CREDIT_CARD'), Operator.fpe);
      expect(policy.operatorFor('UNMAPPED'), Operator.redact); // fallback
    });

    test('rejects an unknown operator', () {
      expect(
        () => AnonymizationPolicy.fromYaml('EMAIL: obfuscate'),
        throwsFormatException,
      );
    });

    test('override layers on top', () {
      final base = AnonymizationPolicy.fromYaml(yaml);
      final overridden = base.override({'EMAIL': Operator.redact});
      expect(overridden.operatorFor('EMAIL'), Operator.redact);
      expect(overridden.operatorFor('PERSON'), Operator.tokenRandom); // kept
    });

    test('the shipped default policy asset parses and matches §4.6', () {
      final source = File(
        'assets/policy/default_policy.yaml',
      ).readAsStringSync();
      final policy = AnonymizationPolicy.fromYaml(source);
      expect(policy.operatorFor('PERSON'), Operator.tokenRandom);
      expect(policy.operatorFor('EMAIL'), Operator.mask);
      expect(policy.operatorFor('PHONE'), Operator.mask);
      expect(policy.operatorFor('SSN'), Operator.redact);
      expect(policy.operatorFor('CREDIT_CARD'), Operator.fpe);
      expect(policy.operatorFor('MRN'), Operator.fpe);
      expect(policy.operatorFor('LOCATION'), Operator.tokenRandom);
      expect(policy.operatorFor('DATE_OF_BIRTH'), Operator.redact);
    });
  });

  group('Anonymizer (irreversible operators)', () {
    const anonymizer = Anonymizer();

    test('applies redact/mask/replace with correct offsets', () {
      const text = 'To a@b.co re SSN 123-45-6789 ok';
      expect(text.substring(3, 9), 'a@b.co'); // offsets sanity
      expect(text.substring(17, 28), '123-45-6789');
      final policy = AnonymizationPolicy.fromYaml('''
EMAIL: replace
SSN: redact
''');
      final result = anonymizer.apply(text, [
        span(3, 9, PiiLabels.email, 'a@b.co'),
        span(17, 28, PiiLabels.ssn, '123-45-6789'),
      ], policy);
      expect(result.text, 'To <EMAIL> re SSN [REDACTED] ok');
      // Applied list is in document order.
      expect(result.applied.map((a) => a.operator).toList(), [
        Operator.replace,
        Operator.redact,
      ]);
    });

    test('mask preserves length with the mask char', () {
      const text = 'pw hunter2!';
      final policy = AnonymizationPolicy.fromYaml('PASSWORD: mask');
      final result = anonymizer.apply(text, [
        span(3, 11, 'PASSWORD', 'hunter2!'),
      ], policy);
      expect(result.text, 'pw ••••••••');
    });

    test('reversible operator without a resolver throws', () {
      final policy = AnonymizationPolicy.fromYaml('PERSON: token_random');
      expect(
        () => anonymizer.apply('hi Alice', [
          span(3, 8, PiiLabels.person, 'Alice'),
        ], policy),
        throwsStateError,
      );
    });

    test('reversible operator uses the injected surrogate resolver', () {
      final policy = AnonymizationPolicy.fromYaml('PERSON: token_random');
      final result = anonymizer.apply(
        'hi Alice',
        [span(3, 8, PiiLabels.person, 'Alice')],
        policy,
        reversible: (s, op) => '<PERSON_abc123>',
      );
      expect(result.text, 'hi <PERSON_abc123>');
      expect(result.applied.single.operator, Operator.tokenRandom);
    });
  });
}
