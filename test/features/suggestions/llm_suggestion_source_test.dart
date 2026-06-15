import 'package:documink/features/anonymization/operator.dart';
import 'package:documink/features/detection/pii_span.dart';
import 'package:documink/features/llm/llm_backend.dart';
import 'package:documink/features/suggestions/llm_suggestion_source.dart';
import 'package:documink/features/suggestions/suggestion.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeLlm implements LlmBackend {
  FakeLlm({
    this.available = true,
    this.response = '{"suggest": false}',
    this.throwOnGenerate = false,
  });

  final bool available;
  final String response;
  final bool throwOnGenerate;
  String? lastPrompt;
  int generateCalls = 0;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<String> generate(String prompt, {int maxOutputTokens = 512}) async {
    generateCalls++;
    lastPrompt = prompt;
    if (throwOnGenerate) throw const LlmUnavailableException();
    return response;
  }
}

SuggestionSignal signal([Map<String, int>? counts]) => SuggestionSignal(
  trigger: SuggestionTrigger.detectionCompleted,
  labelCounts: counts ?? const {PiiLabels.person: 47, PiiLabels.email: 3},
  workspaceId: 'ws',
  tier: 'standard',
);

void main() {
  group('parseSuggestion', () {
    const trigger = SuggestionTrigger.detectionCompleted;

    test('parses a tokenize suggestion', () {
      final s = parseSuggestion(
        '{"suggest": true, "action": "tokenize_label_consistently", '
        '"label": "PERSON", "title": "Tokenize?", "body": "Do it."}',
        trigger,
      );
      expect(s, isNotNull);
      expect(s!.action.kind, SuggestionActionKind.tokenizeLabelConsistently);
      expect(s.action.label, PiiLabels.person);
      expect(s.action.operator, Operator.tokenRandom);
      expect(s.title, 'Tokenize?');
      expect(s.trigger, trigger);
    });

    test('parses an apply-operator suggestion with its operator', () {
      final s = parseSuggestion(
        '{"suggest": true, "action": "apply_operator_to_label", '
        '"label": "EMAIL", "operator": "mask"}',
        trigger,
      );
      expect(s!.action.kind, SuggestionActionKind.applyOperatorToLabel);
      expect(s.action.operator, Operator.mask);
      expect(s.body, isEmpty); // missing body → empty fallback
    });

    test('tolerates surrounding prose (first { … last })', () {
      final s = parseSuggestion(
        'Sure! {"suggest": true, "action": "tokenize_label_consistently", '
        '"label": "PERSON"} — hope that helps',
        trigger,
      );
      expect(s, isNotNull);
      expect(s!.title, 'Suggested follow-up'); // missing title → fallback
    });

    test('returns null when the model declines', () {
      expect(parseSuggestion('{"suggest": false}', trigger), isNull);
    });

    test('returns null on malformed JSON or pure prose', () {
      expect(parseSuggestion('{not json', trigger), isNull);
      expect(parseSuggestion('no json here', trigger), isNull);
    });

    test('rejects an unknown action (hallucination guard)', () {
      expect(
        parseSuggestion(
          '{"suggest": true, "action": "delete_everything", "label": "PERSON"}',
          trigger,
        ),
        isNull,
      );
    });

    test('rejects apply-operator with a missing or unknown operator', () {
      expect(
        parseSuggestion(
          '{"suggest": true, "action": "apply_operator_to_label", "label": "EMAIL"}',
          trigger,
        ),
        isNull,
      );
      expect(
        parseSuggestion(
          '{"suggest": true, "action": "apply_operator_to_label", '
          '"label": "EMAIL", "operator": "nonsense"}',
          trigger,
        ),
        isNull,
      );
    });

    test('rejects a missing label', () {
      expect(
        parseSuggestion(
          '{"suggest": true, "action": "tokenize_label_consistently"}',
          trigger,
        ),
        isNull,
      );
    });
  });

  group('LlmSuggestionSource', () {
    test('does not call the model when it is unavailable', () async {
      final llm = FakeLlm(available: false);
      final out = await LlmSuggestionSource(llm).propose(signal());
      expect(out, isNull);
      expect(llm.generateCalls, 0);
    });

    test('returns the parsed suggestion when available', () async {
      final llm = FakeLlm(
        response:
            '{"suggest": true, "action": "tokenize_label_consistently", '
            '"label": "PERSON", "title": "t", "body": "b"}',
      );
      final out = await LlmSuggestionSource(llm).propose(signal());
      expect(out!.action.label, PiiLabels.person);
      expect(llm.generateCalls, 1);
    });

    test('swallows generation errors (best-effort)', () async {
      final llm = FakeLlm(throwOnGenerate: true);
      expect(await LlmSuggestionSource(llm).propose(signal()), isNull);
    });

    test('prompt carries the types and counts, and only those', () async {
      final llm = FakeLlm();
      await LlmSuggestionSource(llm).propose(signal());
      expect(llm.lastPrompt, contains('PERSON×47'));
      expect(llm.lastPrompt, contains('EMAIL×3'));
      // No raw values can appear — the signal carries none.
      expect(llm.lastPrompt, contains('TYPES and COUNTS only'));
    });
  });
}
