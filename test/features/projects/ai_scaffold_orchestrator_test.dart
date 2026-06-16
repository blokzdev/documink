import 'package:documink/features/input/ingested_text.dart';
import 'package:documink/features/llm/llm_backend.dart';
import 'package:documink/features/projects/ai_scaffold_orchestrator.dart';
import 'package:documink/features/projects/domain_inference_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// A canned LLM that returns a fixed completion (or reports unavailable), so the
/// orchestrator's branching is tested deterministically without a real model.
class _FakeLlm implements LlmBackend {
  _FakeLlm({this.available = true, this.reply = ''});

  final bool available;
  final String reply;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<String> generate(String prompt, {int maxOutputTokens = 512}) async {
    if (!available) throw const LlmUnavailableException();
    return reply;
  }
}

IngestedText _pdf([
  String text = 'A medical discharge summary for the patient',
]) => IngestedText(text: text, source: InputSourceKind.pdfImport);

AiScaffoldOrchestrator _orchestrator({
  required IngestedText? Function() pick,
  required LlmBackend llm,
}) => AiScaffoldOrchestrator(
  pickDocument: () async => pick(),
  inference: DomainInferenceService(llm),
);

void main() {
  group('AiScaffoldOrchestrator.analyzeUpload', () {
    test('returns null when the user cancels the picker', () async {
      final orchestrator = _orchestrator(
        pick: () => null,
        llm: _FakeLlm(reply: '{}'),
      );
      expect(await orchestrator.analyzeUpload(), isNull);
    });

    test('strong single match → StrongMatch with the verified id', () async {
      final orchestrator = _orchestrator(
        pick: _pdf,
        llm: _FakeLlm(
          reply:
              '{"domain":"healthcare","confidence":0.9,'
              '"candidates":["medical"]}',
        ),
      );

      final analysis = await orchestrator.analyzeUpload();
      expect(analysis, isNotNull);
      expect(analysis!.outcome, isA<StrongMatch>());
      expect((analysis.outcome as StrongMatch).templateId, 'medical');
      expect(analysis.ingested.source, InputSourceKind.pdfImport);
    });

    test('ambiguous multi-candidate → WeakMatch with the candidates', () async {
      final orchestrator = _orchestrator(
        pick: _pdf,
        llm: _FakeLlm(
          reply:
              '{"domain":"legal","confidence":0.6,'
              '"candidates":["legal","tax"]}',
        ),
      );

      final outcome = (await orchestrator.analyzeUpload())!.outcome;
      expect(outcome, isA<WeakMatch>());
      expect((outcome as WeakMatch).templateIds, ['legal', 'tax']);
    });

    test('low-confidence match → ScaffoldSuggested with the domain', () async {
      final orchestrator = _orchestrator(
        pick: _pdf,
        llm: _FakeLlm(
          reply:
              '{"domain":"veterinary","confidence":0.3,'
              '"candidates":["personal"]}',
        ),
      );

      final outcome = (await orchestrator.analyzeUpload())!.outcome;
      expect(outcome, isA<ScaffoldSuggested>());
      expect((outcome as ScaffoldSuggested).domain, 'veterinary');
    });

    test('unparseable / no-candidate output → InferenceUnavailable', () async {
      final orchestrator = _orchestrator(
        pick: _pdf,
        llm: _FakeLlm(reply: 'I could not classify this document.'),
      );
      expect(
        (await orchestrator.analyzeUpload())!.outcome,
        isA<InferenceUnavailable>(),
      );
    });

    test(
      'no model available → InferenceUnavailable (graceful fallback)',
      () async {
        final orchestrator = _orchestrator(
          pick: _pdf,
          llm: _FakeLlm(available: false),
        );
        expect(
          (await orchestrator.analyzeUpload())!.outcome,
          isA<InferenceUnavailable>(),
        );
      },
    );

    test('classifies on a snippet, not the whole document', () async {
      var capturedPromptLength = 0;
      final llm = _CapturingLlm(
        (prompt) => capturedPromptLength = prompt.length,
      );
      final orchestrator = AiScaffoldOrchestrator(
        pickDocument: () async => _pdf('x' * 20000),
        inference: DomainInferenceService(llm),
        snippetChars: 4000,
      );

      await orchestrator.analyzeUpload();
      // The prompt wraps a capped snippet, so it is far smaller than the doc.
      expect(capturedPromptLength, lessThan(6000));
    });
  });
}

class _CapturingLlm implements LlmBackend {
  _CapturingLlm(this.onPrompt);
  final void Function(String) onPrompt;

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<String> generate(String prompt, {int maxOutputTokens = 512}) async {
    onPrompt(prompt);
    return '{"domain":"x","confidence":0.9,"candidates":["personal"]}';
  }
}
