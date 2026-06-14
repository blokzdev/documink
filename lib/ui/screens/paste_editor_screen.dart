import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/anonymization/operator.dart';
import '../../features/editor/paste_editor_controller.dart';
import '../theme/app_typography.dart';
import '../theme/tokens.dart';
import '../widgets/entity_chip.dart';

/// Paste-and-redact editor (Phase 5b): paste text → detect (Tier 1) → choose an
/// operator per entity type → preview the redacted text.
class PasteEditorScreen extends ConsumerStatefulWidget {
  const PasteEditorScreen({super.key});

  @override
  ConsumerState<PasteEditorScreen> createState() => _PasteEditorScreenState();
}

class _PasteEditorScreenState extends ConsumerState<PasteEditorScreen> {
  final _textController = TextEditingController();

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

    return Scaffold(
      appBar: AppBar(title: const Text('Paste text')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppTokens.spacingMd),
          children: [
            TextField(
              controller: _textController,
              onChanged: controller.setInput,
              minLines: 4,
              maxLines: 10,
              decoration: const InputDecoration(
                labelText: 'Text to redact',
                hintText:
                    'Paste or type text containing sensitive information…',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppTokens.spacingMd),
            FilledButton.icon(
              onPressed: state.status == EditorStatus.detecting
                  ? null
                  : controller.detect,
              icon: state.status == EditorStatus.detecting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.search),
              label: Text(
                state.status == EditorStatus.detecting
                    ? 'Detecting…'
                    : 'Detect',
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
                    ? 'No sensitive entities detected.'
                    : '${state.entityCount} ${state.entityCount == 1 ? "entity" : "entities"} detected',
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
                        'Redacted preview',
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy_outlined),
                      tooltip: 'Copy',
                      onPressed: () async {
                        await Clipboard.setData(
                          ClipboardData(text: state.previewText),
                        );
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(const SnackBar(content: Text('Copied')));
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
                FilledButton.tonalIcon(
                  onPressed: () async {
                    final id = await controller.save();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          id != null ? 'Saved to vault' : 'Nothing to save',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Save to vault'),
                ),
              ],
            ],
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
                    label: Text(_opLabel(op)),
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

  static String _opLabel(Operator op) => switch (op) {
    Operator.redact => 'Redact',
    Operator.mask => 'Mask',
    Operator.replace => 'Replace',
    Operator.tokenRandom => 'Token',
    Operator.encrypt => 'Encrypt',
    Operator.fpe => 'FPE',
  };
}
