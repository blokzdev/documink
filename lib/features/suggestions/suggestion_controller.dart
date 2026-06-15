import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../documents/document_repository.dart';
import '../editor/paste_editor_controller.dart';
import '../llm/device_capability_profiler.dart' show noTier;
import '../llm/llm_providers.dart';
import '../projects/active_project_provider.dart';
import 'proactive_suggestions_setting.dart';
import 'suggestion.dart';
import 'suggestion_providers.dart';

enum SuggestionStatus { idle, loading, ready }

/// Transient state for the in-context suggestion card, separate from the editor's
/// own state so generating a suggestion never blocks detect/redact.
class SuggestionState {
  const SuggestionState({
    this.status = SuggestionStatus.idle,
    this.suggestion,
    this.lastTriggerKey,
  });

  final SuggestionStatus status;
  final Suggestion? suggestion;

  /// Dedupe key of the last signal we offered for — so editing text that yields
  /// the same per-type counts (or re-detecting) won't re-nudge.
  final String? lastTriggerKey;
}

final suggestionControllerProvider =
    NotifierProvider<SuggestionController, SuggestionState>(
      SuggestionController.new,
    );

/// Drives proactive suggestions in the paste-and-redact editor (blueprint §5.5).
/// The screen calls [maybeOffer] **after** an awaited `detect()`/`save()`, so the
/// (potentially slow, in 13d) generation never sits on the editor's critical path;
/// the card appears later when [SuggestionState.status] flips to `ready`.
class SuggestionController extends Notifier<SuggestionState> {
  /// The PII-safe signal behind the current offer, kept for the actioned/dismissed
  /// audit (carries scope + type counts only).
  SuggestionSignal? _lastSignal;

  @override
  SuggestionState build() => const SuggestionState();

  /// Builds a PII-safe signal from the current detection and asks the suggester
  /// for a follow-up. Gated by the user's toggle and a non-empty detection; reads
  /// scope/tier from the resolved Mink context (never gates on LLM availability —
  /// the deterministic layer works on every tier).
  Future<void> maybeOffer(SuggestionTrigger trigger) async {
    if (!ref.read(proactiveSuggestionsProvider)) return;

    final editor = ref.read(pasteEditorControllerProvider);
    if (editor.entityCount == 0) return;

    final labelCounts = <String, int>{};
    for (final span in editor.spans) {
      labelCounts.update(span.label, (n) => n + 1, ifAbsent: () => 1);
    }

    final key = '${trigger.name}:${_countsKey(labelCounts)}';
    if (key == state.lastTriggerKey) return;

    // Scope from the active project; tier read non-blocking (the deterministic
    // layer ignores it — it's carried for the LLM layer). Deliberately avoids the
    // heavyweight async Mink-turn context so the card never waits on the profiler.
    final signal = SuggestionSignal(
      trigger: trigger,
      labelCounts: labelCounts,
      workspaceId: DocumentRepository.defaultWorkspaceId,
      projectId: ref.read(activeProjectProvider),
      tier: ref.read(profilerStateProvider).valueOrNull?.tier ?? noTier,
      currentOperators: editor.operators,
    );

    state = SuggestionState(
      status: SuggestionStatus.loading,
      lastTriggerKey: key,
    );

    final suggestion = await ref
        .read(proactiveSuggesterProvider)
        .suggest(signal, enabled: true);

    // Bail if a newer offer superseded this one while we awaited.
    if (state.lastTriggerKey != key) return;
    _lastSignal = signal;
    state = SuggestionState(
      status: suggestion == null
          ? SuggestionStatus.idle
          : SuggestionStatus.ready,
      suggestion: suggestion,
      lastTriggerKey: key,
    );
  }

  /// Applies the one-tap action (the bounded editor mutation), audits
  /// `suggestion_actioned`, marks the disclosure seen, and clears the card.
  Future<void> accept() async {
    final suggestion = state.suggestion;
    final signal = _lastSignal;
    if (suggestion == null || signal == null) return;

    await ref
        .read(pasteEditorControllerProvider.notifier)
        .setOperator(suggestion.action.label, suggestion.action.operator);
    ref.read(proactiveSuggestionsDisclosureSeenProvider.notifier).markSeen();
    await ref
        .read(proactiveSuggesterProvider)
        .recordActioned(suggestion, signal);
    _clear();
  }

  /// Audits `suggestion_dismissed`, marks the disclosure seen, and clears the card.
  Future<void> dismiss() async {
    final suggestion = state.suggestion;
    final signal = _lastSignal;
    if (suggestion == null || signal == null) return;

    ref.read(proactiveSuggestionsDisclosureSeenProvider.notifier).markSeen();
    await ref
        .read(proactiveSuggesterProvider)
        .recordDismissed(suggestion, signal);
    _clear();
  }

  void _clear() {
    _lastSignal = null;
    state = SuggestionState(lastTriggerKey: state.lastTriggerKey);
  }

  static String _countsKey(Map<String, int> counts) {
    final keys = counts.keys.toList()..sort();
    return [for (final k in keys) '$k=${counts[k]}'].join(',');
  }
}
