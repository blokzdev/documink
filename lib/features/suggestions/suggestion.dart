import '../anonymization/operator.dart';

/// The user action a proactive suggestion fires after (blueprint §5.5). All three
/// converge in the paste-and-redact editor flow; the UI maps each to a trigger.
enum SuggestionTrigger { scanCompleted, detectionCompleted, redactionApplied }

/// The closed vocabulary of actions a suggestion may carry. A suggestion source
/// (deterministic rules or, later, the LLM layer) can only produce one of these —
/// it can never invent an arbitrary action. This is the safety boundary.
enum SuggestionActionKind { tokenizeLabelConsistently, applyOperatorToLabel }

/// The one-tap action a suggestion offers. [label] is an entity **type**
/// (e.g. `PiiLabels.person`) — never a detected value — so it is PII-safe to log.
class SuggestionAction {
  const SuggestionAction({
    required this.kind,
    required this.label,
    required this.operator,
  });

  final SuggestionActionKind kind;

  /// Entity TYPE the action targets (e.g. `PERSON`). Never a plaintext value.
  final String label;

  /// The operator the action would apply to every span of [label].
  final Operator operator;

  @override
  bool operator ==(Object other) =>
      other is SuggestionAction &&
      other.kind == kind &&
      other.label == label &&
      other.operator == operator;

  @override
  int get hashCode => Object.hash(kind, label, operator);
}

/// A single, in-context follow-up Mink offers after an action: a short title +
/// body and the one-tap [action]. Rendered as a dismissible card (13c).
class Suggestion {
  const Suggestion({
    required this.title,
    required this.body,
    required this.action,
    required this.trigger,
  });

  final String title;
  final String body;
  final SuggestionAction action;
  final SuggestionTrigger trigger;
}

/// The **PII-safe** input to the suggester. It carries entity **type → count**
/// only (e.g. `{PERSON: 47, EMAIL: 3}`) plus scope/tier and the operators already
/// chosen — it structurally cannot hold span text, so no plaintext can ever reach
/// a prompt or an audit row (privacy-invariants #4).
class SuggestionSignal {
  const SuggestionSignal({
    required this.trigger,
    required this.labelCounts,
    required this.workspaceId,
    this.projectId,
    required this.tier,
    this.currentOperators = const {},
  });

  final SuggestionTrigger trigger;

  /// Entity TYPE → number of detected spans of that type. Never plaintext.
  final Map<String, int> labelCounts;

  final String workspaceId;
  final String? projectId;

  /// Device tier (the deterministic layer ignores it; the LLM layer gates on it).
  final String tier;

  /// The operator currently chosen per label, so a suggestion never proposes a
  /// no-op (e.g. "tokenize" when the label is already Token-Random).
  final Map<String, Operator> currentOperators;

  /// Total detected spans across all types.
  int get totalCount => labelCounts.values.fold(0, (sum, n) => sum + n);
}
