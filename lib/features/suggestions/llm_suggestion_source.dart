import 'dart:convert';

import '../anonymization/operator.dart';
import '../llm/llm_backend.dart';
import 'proactive_suggester.dart';
import 'suggestion.dart';

/// Layer 2 of the proactive-suggestion engine (blueprint §5.5): an **optional**
/// on-device LLM source that may add a context-aware suggestion when a model is
/// loaded (Tier 2+). It is consulted only after the deterministic rules return
/// nothing, and every proposal still passes the orchestrator's closed whitelist.
///
/// Privacy: the prompt is built **only** from the PII-safe signal (entity type →
/// count) — never any span text. Best-effort: any error (including
/// [LlmUnavailableException]) silently yields no suggestion, so a slow or absent
/// model never blocks or surfaces an error.
class LlmSuggestionSource implements SuggestionSource {
  const LlmSuggestionSource(this._llm);

  final LlmBackend _llm;

  @override
  Future<Suggestion?> propose(SuggestionSignal signal) async {
    try {
      if (!await _llm.isAvailable()) return null;
      final completion = await _llm.generate(
        _buildPrompt(signal),
        maxOutputTokens: 256,
      );
      return parseSuggestion(completion, signal.trigger);
    } on Object {
      // Enrichment is a best-effort nicety — never surface a failure.
      return null;
    }
  }

  /// A brief, targeted prompt carrying only the trigger and per-type counts.
  static String _buildPrompt(SuggestionSignal signal) {
    final counts =
        (signal.labelCounts.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value)))
            .map((e) => '${e.key}×${e.value}')
            .join(', ');
    return '''
You are Mink, a private on-device redaction assistant. The user just completed an
action (${signal.trigger.name}). The detected entity types and counts are: $counts.
These are TYPES and COUNTS only — you have no access to the underlying values.

If one clearly-valuable follow-up would help, reply with EXACTLY one JSON object:
{"suggest": true, "action": "tokenize_label_consistently", "label": "<TYPE>",
 "title": "<short question>", "body": "<one sentence>"}
- "action" must be "tokenize_label_consistently" (reversible consistent tokens) or
  "apply_operator_to_label" (then also "operator": one of redact|mask|replace|token_random|encrypt).
- "label" must be one of the detected TYPES above.
Otherwise reply with exactly: {"suggest": false}
Reply with the JSON object and nothing else.''';
  }
}

/// Extracts a [Suggestion] from a raw LLM completion, mirroring the tolerant
/// first-`{`…last-`}` JSON extraction used elsewhere (`parseToolInvocation`).
/// Returns null when the model declines (`{"suggest": false}`), the JSON is
/// malformed, or the action/operator is outside the closed vocabulary — so a
/// hallucinated action can never reach the UI. Label/no-op validity is enforced
/// by [ProactiveSuggester] against the actual detection.
Suggestion? parseSuggestion(String raw, SuggestionTrigger trigger) {
  final start = raw.indexOf('{');
  final end = raw.lastIndexOf('}');
  if (start < 0 || end <= start) return null;

  Object? decoded;
  try {
    decoded = jsonDecode(raw.substring(start, end + 1));
  } on FormatException {
    return null;
  }
  if (decoded is! Map) return null;
  if (decoded['suggest'] != true) return null;

  final label = decoded['label'];
  if (label is! String || label.isEmpty) return null;

  final actionName = decoded['action'];
  final SuggestionActionKind kind;
  final Operator operator;
  switch (actionName) {
    case 'tokenize_label_consistently':
      kind = SuggestionActionKind.tokenizeLabelConsistently;
      operator = Operator.tokenRandom;
    case 'apply_operator_to_label':
      kind = SuggestionActionKind.applyOperatorToLabel;
      final opName = decoded['operator'];
      if (opName is! String) return null;
      try {
        operator = Operator.fromPolicyName(opName);
      } on FormatException {
        return null;
      }
    default:
      return null;
  }

  final title = decoded['title'];
  final body = decoded['body'];
  return Suggestion(
    trigger: trigger,
    title: title is String && title.trim().isNotEmpty
        ? title.trim()
        : 'Suggested follow-up',
    body: body is String && body.trim().isNotEmpty ? body.trim() : '',
    action: SuggestionAction(kind: kind, label: label, operator: operator),
  );
}
