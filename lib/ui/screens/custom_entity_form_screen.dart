import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/id_generator.dart';
import '../../features/anonymization/operator.dart';
import '../../features/custom_entities/custom_entity_definition.dart';
import '../../features/custom_entities/custom_entity_providers.dart';
import '../../features/custom_entities/regex_sandbox.dart';
import '../../features/documents/document_repository.dart';
import '../theme/app_typography.dart';
import '../theme/tokens.dart';

/// Operators offered for a custom entity's default (no FPE — see editor note).
const List<Operator> _operators = [
  Operator.redact,
  Operator.mask,
  Operator.replace,
  Operator.tokenRandom,
  Operator.encrypt,
];

String _opLabel(Operator op) => switch (op) {
  Operator.redact => 'Redact',
  Operator.mask => 'Mask',
  Operator.replace => 'Replace',
  Operator.tokenRandom => 'Token',
  Operator.encrypt => 'Encrypt',
  Operator.fpe => 'FPE',
};

/// Add / edit a custom entity type with a ReDoS-safe live preview (roadmap §6).
class CustomEntityFormScreen extends ConsumerStatefulWidget {
  const CustomEntityFormScreen({super.key, this.initial});

  final CustomEntityDefinition? initial;

  @override
  ConsumerState<CustomEntityFormScreen> createState() =>
      _CustomEntityFormScreenState();
}

class _CustomEntityFormScreenState
    extends ConsumerState<CustomEntityFormScreen> {
  late final TextEditingController _label = TextEditingController(
    text: widget.initial?.label ?? '',
  );
  late final TextEditingController _regex = TextEditingController(
    text: widget.initial?.regexPattern ?? '',
  );
  final TextEditingController _sample = TextEditingController();

  late CustomValidator _validator =
      widget.initial?.validator ?? CustomValidator.none;
  late Operator _operator = widget.initial?.defaultOperator ?? Operator.redact;

  String? _error;
  RegexPreviewResult? _preview;
  bool _previewing = false;

  @override
  void dispose() {
    _label.dispose();
    _regex.dispose();
    _sample.dispose();
    super.dispose();
  }

  Future<void> _runPreview() async {
    setState(() => _previewing = true);
    final result = await ref
        .read(regexSandboxProvider)
        .preview(_regex.text, _sample.text);
    if (!mounted) return;
    setState(() {
      _previewing = false;
      _preview = result;
    });
  }

  Future<void> _save() async {
    final errors = ref
        .read(customEntityValidatorProvider)
        .validate(
          label: _label.text,
          regexPattern: _regex.text,
          validator: _validator.id,
          defaultOperator: _operator.policyName,
        );
    if (errors.isNotEmpty) {
      setState(() => _error = errors.first.message);
      return;
    }
    // The custom_entity_types row FKs the workspace; ensure it exists first
    // (single-tenant V1 default).
    await ref.read(documentRepositoryProvider).ensureDefaultWorkspace();
    final initial = widget.initial;
    final def = CustomEntityDefinition(
      id: initial?.id ?? defaultIdGenerator(),
      workspaceId: DocumentRepository.defaultWorkspaceId,
      label: _label.text.trim(),
      regexPattern: _regex.text,
      validator: _validator,
      defaultOperator: _operator,
      createdAtEpochMs:
          initial?.createdAtEpochMs ?? DateTime.now().millisecondsSinceEpoch,
    );
    await ref.read(customEntityRepositoryProvider).save(def);
    ref.invalidate(customEntitiesProvider);
    if (!mounted) return;
    await Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final editing = widget.initial != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(editing ? 'Edit custom entity' : 'Add custom entity'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppTokens.maxContentWidth,
            ),
            child: ListView(
              padding: const EdgeInsets.all(AppTokens.spacingMd),
              children: [
                TextField(
                  key: const Key('cet-label'),
                  controller: _label,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Label',
                    hintText: 'e.g. EMPLOYEE_ID',
                  ),
                ),
                const SizedBox(height: AppTokens.spacingMd),
                TextField(
                  key: const Key('cet-regex'),
                  controller: _regex,
                  style: AppTypography.mono(context),
                  decoration: const InputDecoration(
                    labelText: 'Regex pattern',
                    hintText: r'e.g. EMP-\d{6}',
                  ),
                ),
                const SizedBox(height: AppTokens.spacingMd),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<Operator>(
                        initialValue: _operator,
                        decoration: const InputDecoration(
                          labelText: 'Operator',
                        ),
                        items: [
                          for (final op in _operators)
                            DropdownMenuItem(
                              value: op,
                              child: Text(_opLabel(op)),
                            ),
                        ],
                        onChanged: (op) =>
                            setState(() => _operator = op ?? _operator),
                      ),
                    ),
                    const SizedBox(width: AppTokens.spacingMd),
                    Expanded(
                      child: DropdownButtonFormField<CustomValidator>(
                        initialValue: _validator,
                        decoration: const InputDecoration(
                          labelText: 'Validator',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: CustomValidator.none,
                            child: Text('None'),
                          ),
                          DropdownMenuItem(
                            value: CustomValidator.luhn,
                            child: Text('Luhn'),
                          ),
                        ],
                        onChanged: (v) =>
                            setState(() => _validator = v ?? _validator),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTokens.spacingLg),
                Text('Live preview', style: theme.textTheme.titleMedium),
                const SizedBox(height: AppTokens.spacingSm),
                TextField(
                  key: const Key('cet-sample'),
                  controller: _sample,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Sample text',
                    hintText: 'Paste sample text to test your pattern…',
                  ),
                ),
                const SizedBox(height: AppTokens.spacingSm),
                OutlinedButton.icon(
                  onPressed: _previewing ? null : _runPreview,
                  icon: const Icon(Icons.play_arrow_outlined),
                  label: const Text('Test pattern'),
                ),
                if (_preview != null) ...[
                  const SizedBox(height: AppTokens.spacingSm),
                  Text(_previewSummary(_preview!)),
                ],
                if (_error != null) ...[
                  const SizedBox(height: AppTokens.spacingMd),
                  Text(
                    _error!,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ],
                const SizedBox(height: AppTokens.spacingLg),
                FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _previewSummary(RegexPreviewResult result) => switch (result.status) {
    RegexPreviewStatus.ok =>
      '${result.matches.length} match${result.matches.length == 1 ? "" : "es"}',
    RegexPreviewStatus.error => 'Invalid pattern: ${result.errorMessage}',
    RegexPreviewStatus.timedOut =>
      'Pattern too slow — possible catastrophic backtracking (ReDoS).',
  };
}
