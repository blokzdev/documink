import '../anonymization/operator.dart';
import 'proactive_suggester.dart';
import 'suggestion.dart';

/// Layer 1 of the proactive-suggestion engine (blueprint §5.5): a pure-Dart,
/// **all-tiers** rules engine that needs no model — so suggestions work on every
/// device, including below-floor / Minimum, with zero latency and no prompt for
/// PII to leak into. Today it carries the flagship rule (tokenize a recurring
/// entity consistently); the catalog is extensible.
class DeterministicSuggestionRules {
  const DeterministicSuggestionRules();

  /// Minimum occurrences before the "tokenize them all consistently" nudge makes
  /// sense — a single instance isn't worth a "do them all" suggestion.
  static const int minRecurringCount = 2;

  /// Returns a deterministic suggestion for [signal], or null when no rule fires.
  Suggestion? evaluate(SuggestionSignal signal) {
    switch (signal.trigger) {
      case SuggestionTrigger.scanCompleted:
      case SuggestionTrigger.detectionCompleted:
        return _tokenizeRecurring(signal);
      case SuggestionTrigger.redactionApplied:
        // No deterministic post-redaction rule in V1; the LLM layer may enrich.
        return null;
    }
  }

  /// The PRD flagship: pick the highest-count entity type that still uses the
  /// default `redact` operator and recurs at least [minRecurringCount] times, and
  /// propose tokenizing it consistently with Token-Random — reversible **and**
  /// consistent (same value → same surrogate), true to the reversible philosophy.
  Suggestion? _tokenizeRecurring(SuggestionSignal signal) {
    String? best;
    var bestCount = 0;
    for (final entry in signal.labelCounts.entries) {
      if (entry.value < minRecurringCount) continue;
      final current = signal.currentOperators[entry.key] ?? Operator.redact;
      if (current != Operator.redact) continue;
      if (entry.value > bestCount) {
        best = entry.key;
        bestCount = entry.value;
      }
    }
    if (best == null) return null;

    return Suggestion(
      trigger: signal.trigger,
      title: 'Tokenize all $bestCount consistently?',
      body:
          'This text has $bestCount instances of $best. Want to replace them '
          'with consistent, reversible tokens (the same value always becomes the '
          'same token)?',
      action: SuggestionAction(
        kind: SuggestionActionKind.tokenizeLabelConsistently,
        label: best,
        operator: Operator.tokenRandom,
      ),
    );
  }
}

/// Adapts [DeterministicSuggestionRules] to the [SuggestionSource] interface so
/// the orchestrator can compose it (Layer 1) ahead of the optional LLM source.
class DeterministicSuggestionSource implements SuggestionSource {
  const DeterministicSuggestionSource([
    this._rules = const DeterministicSuggestionRules(),
  ]);

  final DeterministicSuggestionRules _rules;

  @override
  Future<Suggestion?> propose(SuggestionSignal signal) async =>
      _rules.evaluate(signal);
}
