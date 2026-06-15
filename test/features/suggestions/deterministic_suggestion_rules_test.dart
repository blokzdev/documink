import 'package:documink/features/anonymization/operator.dart';
import 'package:documink/features/detection/pii_span.dart';
import 'package:documink/features/suggestions/deterministic_suggestion_rules.dart';
import 'package:documink/features/suggestions/suggestion.dart';
import 'package:flutter_test/flutter_test.dart';

SuggestionSignal signal(
  Map<String, int> counts, {
  SuggestionTrigger trigger = SuggestionTrigger.detectionCompleted,
  Map<String, Operator> operators = const {},
}) => SuggestionSignal(
  trigger: trigger,
  labelCounts: counts,
  workspaceId: 'ws',
  tier: 'standard',
  currentOperators: operators,
);

void main() {
  const rules = DeterministicSuggestionRules();

  test(
    'flagship rule proposes consistent tokenization of the recurring type',
    () {
      final s = rules.evaluate(
        signal({PiiLabels.person: 47, PiiLabels.email: 1}),
      );
      expect(s, isNotNull);
      expect(s!.action.kind, SuggestionActionKind.tokenizeLabelConsistently);
      expect(s.action.label, PiiLabels.person);
      expect(s.action.operator, Operator.tokenRandom);
      expect(s.title, contains('47'));
      expect(s.body, contains(PiiLabels.person));
    },
  );

  test('picks the highest-count eligible label', () {
    final s = rules.evaluate(signal({PiiLabels.person: 3, PiiLabels.email: 9}));
    expect(s!.action.label, PiiLabels.email);
    expect(s.title, contains('9'));
  });

  test('does not fire below the recurrence threshold', () {
    expect(rules.evaluate(signal({PiiLabels.person: 1})), isNull);
  });

  test('skips a label already on a non-default operator (no-op avoidance)', () {
    final s = rules.evaluate(
      signal(
        {PiiLabels.person: 5},
        operators: {PiiLabels.person: Operator.tokenRandom},
      ),
    );
    expect(s, isNull);
  });

  test('no rule for the redaction-applied trigger in V1', () {
    final s = rules.evaluate(
      signal({
        PiiLabels.person: 9,
      }, trigger: SuggestionTrigger.redactionApplied),
    );
    expect(s, isNull);
  });

  test('empty detection yields no suggestion', () {
    expect(rules.evaluate(signal(const {})), isNull);
  });

  test('the body references the type and count, never a raw value', () {
    final s = rules.evaluate(signal({PiiLabels.email: 12}))!;
    // Type + count only — there is no plaintext value to leak (the signal has none).
    expect(s.body, contains('12'));
    expect(s.body, contains(PiiLabels.email));
  });
}
