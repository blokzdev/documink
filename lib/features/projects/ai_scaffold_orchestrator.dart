import '../input/ingested_text.dart';
import 'domain_inference_service.dart';

/// Picks and ingests an uploaded document, returning its extracted text (or null
/// if the user cancels the picker). Bound to `InputIngestionService.importPdf` at
/// the provider; a narrow seam so the orchestrator stays headless-testable.
typedef PdfUploadPicker = Future<IngestedText?> Function();

/// The classification of an uploaded document against the Verified-templates
/// catalog (blueprint §6.2 Path B). Drives which review UI the upload screen
/// shows next.
sealed class UploadOutcome {
  const UploadOutcome();
}

/// One confident Verified-template match (≥0.75, single candidate): pre-select it
/// and let the user confirm. The created Project keeps the **verified**
/// `template_id` — the AI only pre-selected it.
class StrongMatch extends UploadOutcome {
  const StrongMatch(this.templateId);
  final String templateId;
}

/// A few plausible Verified-template candidates (ambiguous match): offer them and
/// let the user pick. The created Project keeps the chosen verified `template_id`.
class WeakMatch extends UploadOutcome {
  const WeakMatch(this.templateIds);
  final List<String> templateIds;
}

/// No usable Verified-template match: offer an **AI-scaffolded** Project (badged,
/// never Verified — §15 #22) seeded from the inferred [domain], for the user to
/// review before creating.
class ScaffoldSuggested extends UploadOutcome {
  const ScaffoldSuggested(this.domain);
  final String? domain;
}

/// The on-device LLM is unavailable (no Tier-4 runtime / below the model floor)
/// or its output couldn't be parsed: fall back to the template picker / blank
/// wizard with an explanation (§4.7/§6.2 graceful degradation).
class InferenceUnavailable extends UploadOutcome {
  const InferenceUnavailable();
}

/// An ingested upload plus its classification — the upload screen holds this to
/// drive the review step, then reuses [UploadAnalysis.ingested] to hand the
/// document into the redaction editor once a Project is created.
class UploadAnalysis {
  const UploadAnalysis({required this.ingested, required this.outcome});

  final IngestedText ingested;
  final UploadOutcome outcome;
}

/// Orchestrates creation Path B (blueprint §6.2): pick + ingest an uploaded
/// document, classify it with the on-device LLM, and map the result to an
/// [UploadOutcome]. Pure-Dart and seam-injected, so the branching is fully
/// unit-testable; the native pick/extract and the Tier-4 model live behind the
/// [PdfUploadPicker] / [DomainInferenceService] seams.
///
/// It deliberately does **not** create the Project or save the document: Project
/// creation reuses the existing create+activate pattern, and the document is
/// imported through the normal redaction-review editor (no silent storage of
/// un-reviewed text).
class AiScaffoldOrchestrator {
  AiScaffoldOrchestrator({
    required PdfUploadPicker pickDocument,
    required DomainInferenceService inference,
    int snippetChars = _defaultSnippetChars,
  }) : _pick = pickDocument,
       _inference = inference,
       _snippetChars = snippetChars;

  final PdfUploadPicker _pick;
  final DomainInferenceService _inference;
  final int _snippetChars;

  /// The first ~1–2 pages are enough to classify a document; cap the snippet so a
  /// large upload doesn't blow the model's context.
  static const int _defaultSnippetChars = 4000;

  /// Picks + ingests a document and classifies it. Returns null when the user
  /// cancels the picker (no document chosen); otherwise an [UploadAnalysis].
  Future<UploadAnalysis?> analyzeUpload() async {
    final ingested = await _pick();
    if (ingested == null) return null;
    return UploadAnalysis(
      ingested: ingested,
      outcome: await _classify(ingested.text),
    );
  }

  Future<UploadOutcome> _classify(String text) async {
    final suggestion = await _inference.infer(_snippet(text));
    if (suggestion == null) return const InferenceUnavailable();
    return switch (suggestion.strength) {
      SuggestionStrength.strong => StrongMatch(
        suggestion.candidateTemplateIds.first,
      ),
      SuggestionStrength.weak => WeakMatch(suggestion.candidateTemplateIds),
      SuggestionStrength.none => ScaffoldSuggested(
        suggestion.domain.trim().isEmpty ? null : suggestion.domain.trim(),
      ),
    };
  }

  String _snippet(String text) =>
      text.length <= _snippetChars ? text : text.substring(0, _snippetChars);
}
