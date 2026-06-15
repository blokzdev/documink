import '../../data/id_generator.dart';
import '../anonymization/operator.dart';
import '../audit/audit_event_type.dart';
import '../audit/audit_log_repository.dart';
import 'suggestion.dart';

/// A source that may propose a follow-up [Suggestion] for a just-completed action.
/// The deterministic rules engine (Layer 1, this phase) and the optional on-device
/// LLM source (Layer 2, a later slice) both implement this, so the orchestrator
/// treats them uniformly. Async so the LLM source can `generate` without changing
/// the contract; the deterministic source resolves synchronously.
abstract interface class SuggestionSource {
  Future<Suggestion?> propose(SuggestionSignal signal);
}

/// Mink's proactive-suggestion orchestrator (blueprint §5.5). It consults its
/// ordered [sources], validates any proposal against a closed whitelist, audits
/// `suggestion_offered`, and returns the first valid suggestion — or null when
/// suggestions are disabled, there's nothing to act on, or no source proposes a
/// valid one. Pure-Dart and fully fake-testable (every dependency is injected).
///
/// PII safety is structural: the only input is a [SuggestionSignal] (entity
/// type → count), and audit metadata records type + count only — never a value.
class ProactiveSuggester {
  ProactiveSuggester({
    required List<SuggestionSource> sources,
    required AuditLogRepository audit,
    IdGenerator? idGenerator,
    DateTime Function()? clock,
  }) : _sources = sources,
       _audit = audit,
       _newId = idGenerator ?? defaultIdGenerator,
       _clock = clock ?? DateTime.now;

  final List<SuggestionSource> _sources;
  final AuditLogRepository _audit;
  final IdGenerator _newId;
  final DateTime Function() _clock;

  /// The operators a suggestion is allowed to apply — the closed whitelist that
  /// bounds what any source (including the LLM) can propose. Mirrors the editor's
  /// operator set (`editorOperators`); FPE is excluded (numeric-only).
  static const Set<Operator> allowedOperators = {
    Operator.redact,
    Operator.mask,
    Operator.replace,
    Operator.tokenRandom,
    Operator.encrypt,
  };

  /// Produces a suggestion for [signal], or null. When [enabled] is false (the
  /// user's Settings toggle) nothing is consulted or audited.
  Future<Suggestion?> suggest(
    SuggestionSignal signal, {
    required bool enabled,
  }) async {
    if (!enabled) return null;
    if (signal.totalCount == 0) return null;

    for (final source in _sources) {
      final proposed = await source.propose(signal);
      if (proposed == null) continue;
      if (!_isValid(proposed, signal)) continue;
      await _auditOffered(proposed, signal);
      return proposed;
    }
    return null;
  }

  /// Rejects anything outside the safe envelope: an operator off the whitelist,
  /// a label we didn't actually detect (guards a hallucinated label from the LLM
  /// layer), or a no-op (the label already uses the proposed operator).
  bool _isValid(Suggestion s, SuggestionSignal signal) {
    final action = s.action;
    if (!allowedOperators.contains(action.operator)) return false;
    final count = signal.labelCounts[action.label];
    if (count == null || count <= 0) return false;
    if (signal.currentOperators[action.label] == action.operator) return false;
    return true;
  }

  Future<void> _auditOffered(Suggestion s, SuggestionSignal signal) {
    return _audit.record(
      id: _newId(),
      workspaceId: signal.workspaceId,
      projectId: signal.projectId,
      eventType: AuditEventType.suggestionOffered,
      success: true,
      metadata: {
        'trigger': s.trigger.name,
        'action': s.action.kind.name,
        'label': s.action.label, // entity TYPE only
        'operator': s.action.operator.policyName,
        'count': signal.labelCounts[s.action.label],
      },
      nowEpochMs: _clock().millisecondsSinceEpoch,
    );
  }
}
