import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/anonymization/operator.dart';
import '../../features/documents/keep_original_setting.dart';
import '../../features/documents/pending_original.dart';
import '../../features/editor/paste_editor_controller.dart';
import '../../features/suggestions/proactive_suggestions_setting.dart';
import '../../features/suggestions/suggestion.dart';
import '../../features/suggestions/suggestion_controller.dart';
import '../../l10n/gen/app_localizations.dart';
import '../theme/app_typography.dart';
import '../theme/tokens.dart';
import '../widgets/entity_chip.dart';

/// Paste-and-redact editor (Phase 5b): paste text → detect (Tier 1) → choose an
/// operator per entity type → preview the redacted text.
///
/// [initialText] seeds the editor when the screen is reached from an input
/// source (Phase 4 — camera scan / image import): the text is pre-filled and
/// detection runs automatically.
class PasteEditorScreen extends ConsumerStatefulWidget {
  const PasteEditorScreen({super.key, this.initialText});

  final String? initialText;

  @override
  ConsumerState<PasteEditorScreen> createState() => _PasteEditorScreenState();
}

class _PasteEditorScreenState extends ConsumerState<PasteEditorScreen> {
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final seed = widget.initialText;
    if (seed != null && seed.trim().isNotEmpty) {
      // Seeded from a capture/import — keep the pending original it set.
      _textController.text = seed;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        final controller = ref.read(pasteEditorControllerProvider.notifier);
        controller.setInput(seed);
        await controller.detect();
        if (!mounted) return;
        // Post-scan completion is a proactive-suggestion trigger (blueprint §5.5).
        await ref
            .read(suggestionControllerProvider.notifier)
            .maybeOffer(SuggestionTrigger.scanCompleted);
      });
    } else {
      // Manual paste — no source file; drop any stale pending original so it
      // can't attach to this unrelated text (ref isn't usable in dispose).
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(pendingOriginalProvider.notifier).state = null;
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pasteEditorControllerProvider);
    final controller = ref.read(pasteEditorControllerProvider.notifier);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    // One-time contextual nudge to keep the source file encrypted (Phase 4c),
    // shown only when a source original is in hand and the user hasn't decided.
    final showKeepOriginalHint =
        ref.watch(pendingOriginalProvider) != null &&
        !ref.watch(keepOriginalProvider) &&
        !ref.watch(keepOriginalHintSeenProvider);
    // Proactive suggestion (blueprint §5.5): the card shows when a suggestion is
    // ready; the disclosure preface shows once, before the first one is acted on.
    final suggestionState = ref.watch(suggestionControllerProvider);
    final suggestion = suggestionState.status == SuggestionStatus.ready
        ? suggestionState.suggestion
        : null;
    final showSuggestionDisclosure = !ref.watch(
      proactiveSuggestionsDisclosureSeenProvider,
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.pasteTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppTokens.spacingMd),
          children: [
            TextField(
              controller: _textController,
              onChanged: controller.setInput,
              minLines: 4,
              maxLines: 10,
              decoration: InputDecoration(
                labelText: l10n.pasteFieldLabel,
                hintText: l10n.pasteFieldHint,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppTokens.spacingMd),
            FilledButton.icon(
              onPressed: state.status == EditorStatus.detecting
                  ? null
                  : () async {
                      await controller.detect();
                      // Post-detection completion trigger (blueprint §5.5).
                      await ref
                          .read(suggestionControllerProvider.notifier)
                          .maybeOffer(SuggestionTrigger.detectionCompleted);
                    },
              icon: state.status == EditorStatus.detecting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.search),
              label: Text(
                state.status == EditorStatus.detecting
                    ? l10n.pasteDetecting
                    : l10n.pasteDetect,
              ),
            ),
            const SizedBox(height: AppTokens.spacingMd),
            if (state.error != null) ...[
              Text(
                state.error!,
                style: TextStyle(color: theme.colorScheme.error),
              ),
              const SizedBox(height: AppTokens.spacingSm),
            ],
            if (state.status == EditorStatus.ready) ...[
              Text(
                state.entityCount == 0
                    ? l10n.pasteNoEntities
                    : l10n.pasteEntitiesDetected(state.entityCount),
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: AppTokens.spacingSm),
              for (final label in state.labels) ...[
                _EntityRow(
                  label: label,
                  count: state.spans.where((s) => s.label == label).length,
                  selected: state.operators[label] ?? Operator.redact,
                  onChanged: (op) => controller.setOperator(label, op),
                ),
                const SizedBox(height: AppTokens.spacingSm),
              ],
              if (state.entityCount > 0) ...[
                const SizedBox(height: AppTokens.spacingSm),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.pasteRedactedPreview,
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy_outlined),
                      tooltip: l10n.pasteCopy,
                      onPressed: () async {
                        await Clipboard.setData(
                          ClipboardData(text: state.previewText),
                        );
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.pasteCopied)),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: AppTokens.spacingSm),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppTokens.spacingMd),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(AppTokens.radiusMd),
                    ),
                  ),
                  child: SelectableText(
                    state.previewText,
                    key: const Key('redacted-preview'),
                    style: AppTypography.mono(context),
                  ),
                ),
                const SizedBox(height: AppTokens.spacingMd),
                if (showKeepOriginalHint) ...[
                  Card(
                    key: const Key('keep-original-hint'),
                    color: theme.colorScheme.secondaryContainer.withValues(
                      alpha: 0.4,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppTokens.spacingMd),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.pasteKeepOriginalTitle,
                            style: theme.textTheme.titleSmall,
                          ),
                          const SizedBox(height: AppTokens.spacingXs),
                          Text(
                            l10n.pasteKeepOriginalBody,
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: AppTokens.spacingSm),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => ref
                                    .read(keepOriginalHintSeenProvider.notifier)
                                    .markSeen(),
                                child: Text(l10n.pasteKeepOriginalNotNow),
                              ),
                              const SizedBox(width: AppTokens.spacingSm),
                              FilledButton(
                                onPressed: () {
                                  ref
                                      .read(keepOriginalProvider.notifier)
                                      .set(true);
                                  ref
                                      .read(
                                        keepOriginalHintSeenProvider.notifier,
                                      )
                                      .markSeen();
                                },
                                child: Text(l10n.pasteKeepOriginalKeep),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTokens.spacingMd),
                ],
                if (suggestion != null) ...[
                  _SuggestionCard(
                    suggestion: suggestion,
                    showDisclosure: showSuggestionDisclosure,
                    onApply: () => ref
                        .read(suggestionControllerProvider.notifier)
                        .accept(),
                    onDismiss: () => ref
                        .read(suggestionControllerProvider.notifier)
                        .dismiss(),
                  ),
                  const SizedBox(height: AppTokens.spacingMd),
                ],
                FilledButton.tonalIcon(
                  onPressed: () async {
                    final id = await controller.save();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            id != null
                                ? l10n.pasteSavedToVault
                                : l10n.pasteNothingToSave,
                          ),
                        ),
                      );
                    }
                    // Post-redaction-application trigger (blueprint §5.5).
                    await ref
                        .read(suggestionControllerProvider.notifier)
                        .maybeOffer(SuggestionTrigger.redactionApplied);
                  },
                  icon: const Icon(Icons.save_outlined),
                  label: Text(l10n.pasteSaveToVault),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

/// The in-context proactive-suggestion card (blueprint §5.5): a compact,
/// dismissible card offering the suggestion's one-tap action. Clones the
/// keep-original hint's structure. Never a push notification.
class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({
    required this.suggestion,
    required this.showDisclosure,
    required this.onApply,
    required this.onDismiss,
  });

  final Suggestion suggestion;
  final bool showDisclosure;
  final VoidCallback onApply;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Card(
      key: const Key('proactive-suggestion-card'),
      color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.4),
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 18,
                  color: theme.colorScheme.onTertiaryContainer,
                ),
                const SizedBox(width: AppTokens.spacingSm),
                Expanded(
                  child: Text(
                    suggestion.title,
                    style: theme.textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTokens.spacingXs),
            Text(suggestion.body, style: theme.textTheme.bodyMedium),
            if (showDisclosure) ...[
              const SizedBox(height: AppTokens.spacingSm),
              Text(
                l10n.suggestionDisclosure,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: AppTokens.spacingSm),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onDismiss,
                  child: Text(l10n.suggestionDismiss),
                ),
                const SizedBox(width: AppTokens.spacingSm),
                FilledButton(
                  onPressed: onApply,
                  child: Text(l10n.suggestionApply),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EntityRow extends StatelessWidget {
  const _EntityRow({
    required this.label,
    required this.count,
    required this.selected,
    required this.onChanged,
  });

  final String label;
  final int count;
  final Operator selected;
  final ValueChanged<Operator> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: EntityChip(label: label, count: count),
            ),
            const SizedBox(height: AppTokens.spacingMd),
            Wrap(
              spacing: AppTokens.spacingSm,
              children: [
                for (final op in editorOperators)
                  ChoiceChip(
                    label: Text(_opLabel(l10n, op)),
                    selected: selected == op,
                    onSelected: (_) => onChanged(op),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _opLabel(AppLocalizations l10n, Operator op) => switch (op) {
    Operator.redact => l10n.operatorRedact,
    Operator.mask => l10n.operatorMask,
    Operator.replace => l10n.operatorReplace,
    Operator.tokenRandom => l10n.operatorToken,
    Operator.encrypt => l10n.operatorEncrypt,
    Operator.fpe => l10n.operatorFpe,
  };
}
