import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/anonymization/operator.dart';
import '../../features/editor/paste_editor_controller.dart';
import '../theme/tokens.dart';

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
              icon: const Icon(Icons.search),
              label: const Text('Detect'),
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
              for (final label in state.labels)
                _EntityRow(
                  label: label,
                  count: state.spans.where((s) => s.label == label).length,
                  selected: state.operators[label] ?? Operator.redact,
                  onChanged: (op) => controller.setOperator(label, op),
                ),
              if (state.entityCount > 0) ...[
                const SizedBox(height: AppTokens.spacingMd),
                Text('Preview', style: theme.textTheme.titleMedium),
                const SizedBox(height: AppTokens.spacingSm),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppTokens.spacingMd),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    state.previewText,
                    key: const Key('redacted-preview'),
                  ),
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
            Text(
              '$label  ·  $count',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppTokens.spacingSm),
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
