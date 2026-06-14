import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/routes.dart';
import '../../features/anonymization/operator.dart';
import '../../features/detection/pii_span.dart';
import '../../features/projects/active_project_provider.dart';
import '../../features/projects/project_providers.dart';
import '../../l10n/gen/app_localizations.dart';
import '../theme/tokens.dart';

/// Domains offered by the guided wizard (blueprint §6.2 Path C). Plain values
/// stored in the manifest's `domain`.
const _domains = <String>[
  'general',
  'personal',
  'healthcare',
  'legal',
  'finance',
  'research',
  'creative',
  'engineering',
];

/// Common PII labels the wizard offers to pre-populate the default policy.
const _dataLabels = <String>[
  PiiLabels.person,
  PiiLabels.email,
  PiiLabels.phone,
  PiiLabels.ssn,
  PiiLabels.creditCard,
  PiiLabels.dateOfBirth,
  PiiLabels.location,
  PiiLabels.mrn,
];

/// Composes a §6.1 blank-Project manifest JSON from the wizard's answers
/// (template_id `blank`). Pure for testability.
String composeBlankManifest({
  required String name,
  required String domain,
  required Set<String> labels,
  required Operator defaultOperator,
  required bool rewrite,
  required bool expand,
  required bool export,
  required bool decodeBiometric,
}) => jsonEncode({
  'manifest_schema_version': 1,
  'template_id': 'blank',
  'name': name,
  'domain': domain,
  'permissions': {
    'read_documents': true,
    'detect_pii': true,
    'anonymize': true,
    'decode': decodeBiometric ? 'requires_biometric' : true,
    'export': export,
    'modify_project_settings': true,
    if (rewrite) 'rewrite_content': true,
    if (expand) 'expand_content': true,
  },
  'default_policy': {for (final l in labels) l: defaultOperator.policyName},
  'custom_entity_types': <dynamic>[],
});

/// Project creation — Path C (blueprint §6.2): a guided wizard that composes a
/// blank Project's manifest from a few answers, then creates it.
class BlankWizardScreen extends ConsumerStatefulWidget {
  const BlankWizardScreen({super.key});

  @override
  ConsumerState<BlankWizardScreen> createState() => _BlankWizardScreenState();
}

class _BlankWizardScreenState extends ConsumerState<BlankWizardScreen> {
  int _step = 0;
  final _name = TextEditingController();
  String _domain = _domains.first;
  final Set<String> _labels = {};
  Operator _operator = Operator.tokenRandom;
  bool _rewrite = false;
  bool _expand = false;
  bool _export = true;
  bool _decodeBiometric = true;
  bool _creating = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  static const _lastStep = 3;

  Future<void> _create() async {
    final name = _name.text.trim();
    if (name.isEmpty || _creating) return;
    setState(() => _creating = true);

    final id = await ref
        .read(projectRepositoryProvider)
        .create(
          name: name,
          templateId: 'blank',
          manifestJson: composeBlankManifest(
            name: name,
            domain: _domain,
            labels: _labels,
            defaultOperator: _operator,
            rewrite: _rewrite,
            expand: _expand,
            export: _export,
            decodeBiometric: _decodeBiometric,
          ),
        );
    ref.read(activeProjectProvider.notifier).set(id);
    ref.invalidate(projectsListProvider);
    if (!mounted) return;
    // Replace the wizard with the new project's detail.
    context.go(Routes.projectDetail(id));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.wizardTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppTokens.maxContentWidth,
            ),
            child: Stepper(
              currentStep: _step,
              onStepContinue: () {
                if (_step < _lastStep) setState(() => _step++);
              },
              onStepCancel: () {
                if (_step > 0) setState(() => _step--);
              },
              controlsBuilder: (context, details) {
                // The vertical Stepper builds controls for every step; only show
                // them for the active one (keeps the action keys unique).
                if (details.stepIndex != _step) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: AppTokens.spacingMd),
                  child: Row(
                    children: [
                      if (_step < _lastStep)
                        FilledButton(
                          key: const Key('wizard-next'),
                          onPressed: details.onStepContinue,
                          child: Text(l10n.wizardNext),
                        )
                      else
                        FilledButton(
                          key: const Key('wizard-create'),
                          onPressed: _creating ? null : _create,
                          child: Text(l10n.wizardCreate),
                        ),
                      if (_step > 0)
                        TextButton(
                          onPressed: details.onStepCancel,
                          child: Text(l10n.wizardBack),
                        ),
                    ],
                  ),
                );
              },
              steps: [
                Step(
                  title: Text(l10n.wizardStepBasics),
                  isActive: _step >= 0,
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        key: const Key('wizard-name'),
                        controller: _name,
                        decoration: InputDecoration(labelText: l10n.wizardName),
                      ),
                      const SizedBox(height: AppTokens.spacingMd),
                      DropdownButtonFormField<String>(
                        initialValue: _domain,
                        decoration: InputDecoration(
                          labelText: l10n.wizardDomain,
                        ),
                        items: [
                          for (final d in _domains)
                            DropdownMenuItem(value: d, child: Text(d)),
                        ],
                        onChanged: (d) =>
                            setState(() => _domain = d ?? _domain),
                      ),
                    ],
                  ),
                ),
                Step(
                  title: Text(l10n.wizardStepData),
                  isActive: _step >= 1,
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.wizardDataPrompt),
                      for (final label in _dataLabels)
                        CheckboxListTile(
                          key: Key('wizard-label-$label'),
                          contentPadding: EdgeInsets.zero,
                          title: Text(label),
                          value: _labels.contains(label),
                          onChanged: (v) => setState(() {
                            if (v ?? false) {
                              _labels.add(label);
                            } else {
                              _labels.remove(label);
                            }
                          }),
                        ),
                      const SizedBox(height: AppTokens.spacingSm),
                      DropdownButtonFormField<Operator>(
                        initialValue: _operator,
                        decoration: InputDecoration(
                          labelText: l10n.wizardDefaultAction,
                        ),
                        items: [
                          for (final op in Operator.values)
                            DropdownMenuItem(
                              value: op,
                              child: Text(_opLabel(l10n, op)),
                            ),
                        ],
                        onChanged: (op) =>
                            setState(() => _operator = op ?? _operator),
                      ),
                    ],
                  ),
                ),
                Step(
                  title: Text(l10n.wizardStepPermissions),
                  isActive: _step >= 2,
                  content: Column(
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.wizardPermExport),
                        value: _export,
                        onChanged: (v) => setState(() => _export = v),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.wizardPermDecodeBiometric),
                        value: _decodeBiometric,
                        onChanged: (v) => setState(() => _decodeBiometric = v),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.wizardPermRewrite),
                        value: _rewrite,
                        onChanged: (v) => setState(() => _rewrite = v),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.wizardPermExpand),
                        value: _expand,
                        onChanged: (v) => setState(() => _expand = v),
                      ),
                    ],
                  ),
                ),
                Step(
                  title: Text(l10n.wizardStepReview),
                  isActive: _step >= 3,
                  content: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l10n.wizardReviewSummary(
                        _name.text.trim().isEmpty ? '—' : _name.text.trim(),
                        _labels.length,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _opLabel(AppLocalizations l10n, Operator op) => switch (op) {
    Operator.redact => l10n.operatorRedact,
    Operator.mask => l10n.operatorMask,
    Operator.replace => l10n.operatorReplace,
    Operator.tokenRandom => l10n.operatorToken,
    Operator.fpe => l10n.operatorFpe,
    Operator.encrypt => l10n.operatorEncrypt,
  };
}
