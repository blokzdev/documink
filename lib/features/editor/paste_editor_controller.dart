import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../anonymization/anonymization_policy.dart';
import '../anonymization/anonymization_providers.dart';
import '../anonymization/operator.dart';
import '../detection/detection_pipeline.dart';
import '../detection/detection_providers.dart';
import '../detection/pii_span.dart';

/// Operators offered in the paste editor (Phase 5b). Restricted to the
/// **irreversible** transforms, which need no unlocked vault — the reversible
/// operators (Token-Random / FPE / Encrypt) arrive with the vault-unlock UX in a
/// later chunk.
const List<Operator> editorOperators = [
  Operator.redact,
  Operator.mask,
  Operator.replace,
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
  });

  final String input;
  final EditorStatus status;
  final DetectionResult? detection;

  /// Chosen operator per detected label (entity type). Defaults to redact.
  final Map<String, Operator> operators;

  /// Redacted preview of the normalized text under the current operators.
  final String previewText;

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
  @override
  PasteEditorState build() => const PasteEditorState();

  /// Updates the input text and clears any prior detection.
  void setInput(String input) {
    state = PasteEditorState(input: input);
  }

  /// Runs the detection pipeline (Tier 1, headless) over the current input and
  /// initializes a redact-by-default operator per detected label.
  Future<void> detect() async {
    final input = state.input;
    if (input.trim().isEmpty) {
      state = PasteEditorState(input: input);
      return;
    }
    state = PasteEditorState(input: input, status: EditorStatus.detecting);
    final result = await ref.read(detectionPipelineProvider).detect(input);
    final operators = <String, Operator>{
      for (final span in result.spans) span.label: Operator.redact,
    };
    state = PasteEditorState(
      input: input,
      status: EditorStatus.ready,
      detection: result,
      operators: operators,
      previewText: _preview(result, operators),
    );
  }

  /// Changes the operator applied to all spans of [label] and recomputes the
  /// preview.
  void setOperator(String label, Operator op) {
    if (!state.operators.containsKey(label)) return;
    final operators = {...state.operators, label: op};
    final detection = state.detection;
    state = PasteEditorState(
      input: state.input,
      status: state.status,
      detection: detection,
      operators: operators,
      previewText: detection == null ? '' : _preview(detection, operators),
    );
  }

  String _preview(DetectionResult detection, Map<String, Operator> operators) {
    final policy = AnonymizationPolicy(operators, fallback: Operator.redact);
    return ref
        .read(anonymizerProvider)
        .apply(detection.normalizedText, detection.spans, policy)
        .text;
  }
}
