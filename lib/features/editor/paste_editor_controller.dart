import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../anonymization/anonymization_policy.dart';
import '../anonymization/anonymization_providers.dart';
import '../anonymization/anonymization_service.dart';
import '../anonymization/operator.dart';
import '../custom_entities/custom_entity_providers.dart';
import '../custom_entities/custom_entity_recognizer.dart';
import '../detection/detection_pipeline.dart';
import '../detection/detection_providers.dart';
import '../detection/pii_span.dart';
import '../documents/document_repository.dart';

/// Operators offered in the paste editor. Irreversible transforms plus the
/// vault-backed reversible ones (Token-Random, Encrypt) — available because the
/// editor is reached only behind the vault-unlock gate (Phase 5e).
///
/// FPE is intentionally excluded here: FF1 needs a minimum numeric domain and
/// throws on arbitrary text, so it belongs with per-type applicability (numeric
/// labels only) in a later chunk.
const List<Operator> editorOperators = [
  Operator.redact,
  Operator.mask,
  Operator.replace,
  Operator.tokenRandom,
  Operator.encrypt,
];

enum EditorStatus { idle, detecting, ready }

/// Immutable state of the paste-and-redact editor.
class PasteEditorState {
  const PasteEditorState({
    this.input = '',
    this.status = EditorStatus.idle,
    this.detection,
    this.operators = const {},
    this.previewText = '',
    this.error,
  });

  final String input;
  final EditorStatus status;
  final DetectionResult? detection;

  /// Chosen operator per detected label (entity type). Defaults to redact.
  final Map<String, Operator> operators;

  /// Redacted preview of the normalized text under the current operators.
  final String previewText;

  /// Non-null when the last anonymization attempt failed (preview unchanged).
  final String? error;

  List<DetectedSpan> get spans => detection?.spans ?? const [];

  int get entityCount => spans.length;

  /// Distinct detected labels in first-occurrence order.
  List<String> get labels {
    final seen = <String>{};
    final out = <String>[];
    for (final s in spans) {
      if (seen.add(s.label)) out.add(s.label);
    }
    return out;
  }
}

final pasteEditorControllerProvider =
    NotifierProvider<PasteEditorController, PasteEditorState>(
      PasteEditorController.new,
    );

class PasteEditorController extends Notifier<PasteEditorState> {
  /// The outcome behind the current preview — persisted verbatim on save so the
  /// stored tokens match the previewed surrogates.
  AnonymizationOutcome? _lastOutcome;

  @override
  PasteEditorState build() => const PasteEditorState();

  /// Updates the input text and clears any prior detection.
  void setInput(String input) {
    _lastOutcome = null;
    state = PasteEditorState(input: input);
  }

  /// Runs the detection pipeline (Tier 1, headless) over the current input and
  /// initializes a redact-by-default operator per detected label, then computes
  /// the preview.
  Future<void> detect() async {
    final input = state.input;
    if (input.trim().isEmpty) {
      state = PasteEditorState(input: input);
      return;
    }
    state = PasteEditorState(input: input, status: EditorStatus.detecting);
    // Tier-1 recognizers + the user's custom entity types (roadmap §6).
    final recognizers = [
      ...ref.read(piiRecognizersProvider),
      if (await ref.read(customEntitiesProvider.future) case final defs
          when defs.isNotEmpty)
        CustomEntityRecognizer(defs),
    ];
    final result = await DetectionPipeline(recognizers).detect(input);
    final operators = <String, Operator>{
      for (final span in result.spans) span.label: Operator.redact,
    };
    state = PasteEditorState(
      input: input,
      status: EditorStatus.ready,
      detection: result,
      operators: operators,
      previewText: await _preview(result, operators),
    );
  }

  /// Changes the operator applied to all spans of [label] and recomputes the
  /// preview. Reversible operators (Token-Random/Encrypt) use the unlocked
  /// vault; a failure keeps the previous preview and sets [PasteEditorState.error].
  Future<void> setOperator(String label, Operator op) async {
    final detection = state.detection;
    if (detection == null || !state.operators.containsKey(label)) return;
    final operators = {...state.operators, label: op};
    try {
      state = PasteEditorState(
        input: state.input,
        status: EditorStatus.ready,
        detection: detection,
        operators: operators,
        previewText: await _preview(detection, operators),
      );
    } catch (_) {
      state = PasteEditorState(
        input: state.input,
        status: EditorStatus.ready,
        detection: detection,
        operators: operators,
        previewText: state.previewText,
        error: 'Could not apply that operator to this text.',
      );
    }
  }

  /// Persists the current redacted document (Document + Entities + Tokens) to
  /// the unlocked vault. Returns the new document id, or null if there's nothing
  /// to save. The persisted tokens match the previewed surrogates.
  Future<String?> save({String? name}) async {
    final detection = state.detection;
    final outcome = _lastOutcome;
    if (detection == null || outcome == null || state.entityCount == 0) {
      return null;
    }
    return ref
        .read(documentRepositoryProvider)
        .saveAnonymizedText(
          name: name ?? 'Pasted text',
          originalText: state.input,
          detection: detection,
          operators: state.operators,
          outcome: outcome,
        );
  }

  /// Computes the redacted preview via the vault-backed [AnonymizationService]
  /// and retains the outcome for [save].
  Future<String> _preview(
    DetectionResult detection,
    Map<String, Operator> operators,
  ) async {
    final policy = AnonymizationPolicy(operators, fallback: Operator.redact);
    final outcome = await ref
        .read(anonymizationServiceProvider)
        .anonymize(detection.normalizedText, detection.spans, policy);
    _lastOutcome = outcome;
    return outcome.result.text;
  }
}
