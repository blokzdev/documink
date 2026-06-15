import 'package:documink/features/llm/llm_backend.dart';
import 'package:documink/features/projects/domain_inference_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// A scriptable [LlmBackend] for the inference tests.
class _FakeLlm implements LlmBackend {
  _FakeLlm({
    this.available = true,
    this.reply = '',
    this.throwOnGenerate = false,
  });
  final bool available;
  final String reply;
  final bool throwOnGenerate;
  String? lastPrompt;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<String> generate(String prompt, {int maxOutputTokens = 512}) async {
    lastPrompt = prompt;
    if (throwOnGenerate) throw const LlmUnavailableException();
    return reply;
  }
}

void main() {
  test(
    'returns null when the model is unavailable (fall back to picker)',
    () async {
      final svc = DomainInferenceService(_FakeLlm(available: false));
      expect(await svc.infer('some medical note'), isNull);
    },
  );

  test('returns null for empty input without calling the model', () async {
    final llm = _FakeLlm(reply: '{}');
    expect(await DomainInferenceService(llm).infer('   '), isNull);
    expect(llm.lastPrompt, isNull); // never invoked
  });

  test('parses a strong single-candidate suggestion', () async {
    final svc = DomainInferenceService(
      _FakeLlm(
        reply:
            'Sure! {"domain":"healthcare","confidence":0.92,"candidates":["medical"]}',
      ),
    );
    final s = await svc.infer('Patient MRN 12345, diagnosis ...');
    expect(s, isNotNull);
    expect(s!.domain, 'healthcare');
    expect(s.candidateTemplateIds, ['medical']);
    expect(s.strength, SuggestionStrength.strong);
  });

  test('weak match when multiple candidates / mid confidence', () async {
    final svc = DomainInferenceService(
      _FakeLlm(
        reply: '{"domain":"x","confidence":0.6,"candidates":["legal","tax"]}',
      ),
    );
    final s = await svc.infer('an agreement about taxes');
    expect(s!.strength, SuggestionStrength.weak);
  });

  test('drops unknown candidate ids; null when none remain', () async {
    final svc = DomainInferenceService(
      _FakeLlm(
        reply:
            '{"domain":"x","confidence":0.9,"candidates":["nope","also_no"]}',
      ),
    );
    expect(await svc.infer('whatever'), isNull);
  });

  test('null on malformed (non-JSON) output', () async {
    final svc = DomainInferenceService(
      _FakeLlm(reply: 'I cannot help with that'),
    );
    expect(await svc.infer('whatever'), isNull);
  });

  test('a generate failure degrades to null, never throws', () async {
    final svc = DomainInferenceService(_FakeLlm(throwOnGenerate: true));
    expect(await svc.infer('whatever'), isNull);
  });

  test(
    'UnavailableLlmBackend reports unavailable and throws on generate',
    () async {
      const backend = UnavailableLlmBackend();
      expect(await backend.isAvailable(), isFalse);
      expect(backend.generate('x'), throwsA(isA<LlmUnavailableException>()));
    },
  );
}
