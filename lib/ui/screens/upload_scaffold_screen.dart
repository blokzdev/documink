import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/routes.dart';
import '../../data/id_generator.dart';
import '../../features/documents/pending_original.dart';
import '../../features/projects/active_project_provider.dart';
import '../../features/projects/ai_scaffold_orchestrator.dart';
import '../../features/projects/personal_template.dart';
import '../../features/projects/project_providers.dart';
import '../../features/projects/scaffolded_manifest.dart';
import '../../features/projects/template_manifest.dart';
import '../../l10n/gen/app_localizations.dart';
import '../theme/tokens.dart';
import '../widgets/section_header.dart';

/// Project creation — Path B (blueprint §6.2): upload a document, let the
/// on-device LLM classify it, and branch on the result — pre-select a Verified
/// template (strong), offer a few (weak), scaffold a conservative AI project
/// (no match), or fall back to the picker/wizard when AI is unavailable. The
/// uploaded document is then imported through the normal redaction editor, scoped
/// to the new (now active) Project.
///
/// The native pick/extract + Tier-4 model live behind the
/// [aiScaffoldOrchestratorProvider] seam, so the screen is widget-tested with
/// fakes (the on-device branching itself is device-verified — VERIFICATION.md).
class UploadScaffoldScreen extends ConsumerStatefulWidget {
  const UploadScaffoldScreen({super.key});

  @override
  ConsumerState<UploadScaffoldScreen> createState() =>
      _UploadScaffoldScreenState();
}

enum _Phase { idle, analyzing, ready }

class _UploadScaffoldScreenState extends ConsumerState<UploadScaffoldScreen> {
  _Phase _phase = _Phase.idle;
  UploadAnalysis? _analysis;
  final _name = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _choose() async {
    setState(() => _phase = _Phase.analyzing);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    UploadAnalysis? analysis;
    try {
      analysis = await ref.read(aiScaffoldOrchestratorProvider).analyzeUpload();
    } catch (_) {
      if (!mounted) return;
      setState(() => _phase = _Phase.idle);
      messenger.showSnackBar(SnackBar(content: Text(l10n.uploadScaffoldError)));
      return;
    }
    if (!mounted) return;
    if (analysis == null) {
      // The user cancelled the picker.
      setState(() => _phase = _Phase.idle);
      return;
    }
    _name.text = await _defaultName(analysis.outcome);
    setState(() {
      _analysis = analysis;
      _phase = _Phase.ready;
    });
  }

  Future<String> _defaultName(UploadOutcome outcome) async {
    switch (outcome) {
      case StrongMatch(:final templateId):
        return await _templateName(templateId) ?? '';
      case WeakMatch(:final templateIds):
        return await _templateName(templateIds.first) ?? '';
      case ScaffoldSuggested(:final domain):
        return domain == null ? '' : _titleCase(domain);
      case InferenceUnavailable():
        return '';
    }
  }

  Future<String?> _templateName(String templateId) async {
    final def = await _templateDef(templateId);
    return def?.name;
  }

  Future<TemplateDefinition?> _templateDef(String templateId) async {
    final templates = await ref.read(verifiedTemplatesProvider.future);
    for (final t in templates) {
      if (t.templateId == templateId) return t;
    }
    return null;
  }

  static String _titleCase(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  /// Creates a Project from a Verified template (strong/weak branches), keeping
  /// the verified `template_id`, then imports the uploaded document.
  Future<void> _createFromTemplate(String templateId) async {
    final name = _name.text.trim();
    if (name.isEmpty || _busy) return;
    setState(() => _busy = true);
    final def = await _templateDef(templateId);
    if (def == null) {
      if (mounted) setState(() => _busy = false);
      return;
    }
    final id = await ref
        .read(projectRepositoryProvider)
        .create(
          name: name,
          templateId: def.templateId,
          manifestJson: def.buildProjectManifestJson(projectName: name),
        );
    await _activateAndImport(id);
  }

  /// Creates an AI-scaffolded Project (no-match branch) from the conservative
  /// manifest, offers to save it as a personal template, then imports the doc.
  Future<void> _createScaffold(String? domain) async {
    final name = _name.text.trim();
    if (name.isEmpty || _busy) return;
    setState(() => _busy = true);
    final manifestJson = composeScaffoldedManifest(name: name, domain: domain);
    final id = await ref
        .read(projectRepositoryProvider)
        .create(
          name: name,
          templateId: aiScaffoldedTemplateId,
          manifestJson: manifestJson,
        );
    await _maybeSavePersonal(name, manifestJson);
    await _activateAndImport(id);
  }

  Future<void> _maybeSavePersonal(String name, String manifestJson) async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final save = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.uploadScaffoldSavePersonalTitle),
        content: Text(l10n.uploadScaffoldSavePersonalBody),
        actions: [
          TextButton(
            key: const Key('upload-save-personal-no'),
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.uploadScaffoldSavePersonalDismiss),
          ),
          FilledButton(
            key: const Key('upload-save-personal-yes'),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.uploadScaffoldSavePersonalConfirm),
          ),
        ],
      ),
    );
    if (save != true) return;
    await ref
        .read(personalTemplateRepositoryProvider)
        .save(
          PersonalTemplate(
            id: defaultIdGenerator(),
            name: name,
            manifestJson: manifestJson,
            createdAtEpochMs: DateTime.now().millisecondsSinceEpoch,
            origin: PersonalTemplateOrigin.aiScaffolded,
          ),
        );
    ref.invalidate(personalTemplatesProvider);
    if (!mounted) return;
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.uploadScaffoldSavePersonalDone)),
    );
  }

  /// Sets the new Project active and hands the uploaded text to the redaction
  /// editor (the document is saved into the active Project once reviewed).
  Future<void> _activateAndImport(String projectId) async {
    ref.read(activeProjectProvider.notifier).set(projectId);
    ref.invalidate(projectsListProvider);
    final ingested = _analysis!.ingested;
    ref
        .read(pendingOriginalProvider.notifier)
        .state = ingested.originalPath == null
        ? null
        : PendingOriginal(
            path: ingested.originalPath!,
            mime: ingested.mime ?? 'application/octet-stream',
          );
    if (!mounted) return;
    context.go(Routes.paste, extra: ingested.text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.uploadScaffoldTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppTokens.maxContentWidth,
            ),
            child: switch (_phase) {
              _Phase.idle => _IdleView(onChoose: _choose),
              _Phase.analyzing => _AnalyzingView(
                label: l10n.uploadScaffoldAnalyzing,
              ),
              _Phase.ready => _buildReady(context, l10n),
            },
          ),
        ),
      ),
    );
  }

  Widget _buildReady(BuildContext context, AppLocalizations l10n) {
    final outcome = _analysis!.outcome;
    return ListView(
      padding: const EdgeInsets.all(AppTokens.spacingMd),
      children: [
        switch (outcome) {
          StrongMatch(:final templateId) => _StrongView(
            templateId: templateId,
            nameController: _name,
            busy: _busy,
            templateDef: _templateDef,
            onCreate: () => _createFromTemplate(templateId),
          ),
          WeakMatch(:final templateIds) => _WeakView(
            templateIds: templateIds,
            nameController: _name,
            busy: _busy,
            templateDef: _templateDef,
            onCreate: _createFromTemplate,
          ),
          ScaffoldSuggested(:final domain) => _ScaffoldView(
            domain: domain,
            nameController: _name,
            busy: _busy,
            onCreate: () => _createScaffold(domain),
          ),
          InferenceUnavailable() => const _UnavailableView(),
        },
      ],
    );
  }
}

class _IdleView extends StatelessWidget {
  const _IdleView({required this.onChoose});

  final VoidCallback onChoose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_awesome_outlined,
              size: 48,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: AppTokens.spacingMd),
            Text(
              l10n.uploadScaffoldIntro,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: AppTokens.spacingLg),
            FilledButton.icon(
              key: const Key('upload-choose'),
              onPressed: onChoose,
              icon: const Icon(Icons.upload_file_outlined),
              label: Text(l10n.uploadScaffoldChoose),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnalyzingView extends StatelessWidget {
  const _AnalyzingView({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: AppTokens.spacingMd),
          Text(label),
        ],
      ),
    );
  }
}

/// Shared project-name field used by every create branch.
class _NameField extends StatelessWidget {
  const _NameField(this.controller);

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TextField(
      key: const Key('upload-name-field'),
      controller: controller,
      decoration: InputDecoration(labelText: l10n.templateProjectNameLabel),
    );
  }
}

class _StrongView extends StatelessWidget {
  const _StrongView({
    required this.templateId,
    required this.nameController,
    required this.busy,
    required this.templateDef,
    required this.onCreate,
  });

  final String templateId;
  final TextEditingController nameController;
  final bool busy;
  final Future<TemplateDefinition?> Function(String) templateDef;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.uploadScaffoldStrongTitle, style: theme.textTheme.titleLarge),
        const SizedBox(height: AppTokens.spacingSm),
        FutureBuilder<TemplateDefinition?>(
          future: templateDef(templateId),
          builder: (context, snap) {
            final def = snap.data;
            return Card(
              child: ListTile(
                key: Key('upload-strong-$templateId'),
                leading: const Icon(Icons.folder_special_outlined),
                title: Text(def?.name ?? templateId),
                subtitle: def == null ? null : Text(def.description),
              ),
            );
          },
        ),
        const SizedBox(height: AppTokens.spacingMd),
        _NameField(nameController),
        const SizedBox(height: AppTokens.spacingMd),
        FilledButton.icon(
          key: const Key('upload-create'),
          onPressed: busy ? null : onCreate,
          icon: const Icon(Icons.check),
          label: Text(l10n.templateCreateProject),
        ),
      ],
    );
  }
}

class _WeakView extends StatelessWidget {
  const _WeakView({
    required this.templateIds,
    required this.nameController,
    required this.busy,
    required this.templateDef,
    required this.onCreate,
  });

  final List<String> templateIds;
  final TextEditingController nameController;
  final bool busy;
  final Future<TemplateDefinition?> Function(String) templateDef;
  final ValueChanged<String> onCreate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.uploadScaffoldWeakTitle, style: theme.textTheme.titleLarge),
        const SizedBox(height: AppTokens.spacingSm),
        Text(l10n.uploadScaffoldWeakBody, style: theme.textTheme.bodyMedium),
        const SizedBox(height: AppTokens.spacingMd),
        _NameField(nameController),
        const SizedBox(height: AppTokens.spacingMd),
        for (final id in templateIds)
          FutureBuilder<TemplateDefinition?>(
            future: templateDef(id),
            builder: (context, snap) {
              final def = snap.data;
              return Card(
                child: ListTile(
                  key: Key('upload-candidate-$id'),
                  leading: const Icon(Icons.folder_outlined),
                  title: Text(def?.name ?? id),
                  subtitle: def == null ? null : Text(def.description),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: busy ? null : () => onCreate(id),
                ),
              );
            },
          ),
      ],
    );
  }
}

class _ScaffoldView extends StatelessWidget {
  const _ScaffoldView({
    required this.domain,
    required this.nameController,
    required this.busy,
    required this.onCreate,
  });

  final String? domain;
  final TextEditingController nameController;
  final bool busy;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.uploadScaffoldScaffoldTitle,
                style: theme.textTheme.titleLarge,
              ),
            ),
            const AiScaffoldedBadge(),
          ],
        ),
        const SizedBox(height: AppTokens.spacingSm),
        Text(
          domain == null
              ? l10n.uploadScaffoldScaffoldBodyNoDomain
              : l10n.uploadScaffoldScaffoldBody(domain!),
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: AppTokens.spacingSm),
        SectionHeader(l10n.uploadScaffoldScaffoldDefaults),
        Text(
          l10n.uploadScaffoldScaffoldDefaultsBody,
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: AppTokens.spacingMd),
        _NameField(nameController),
        const SizedBox(height: AppTokens.spacingMd),
        FilledButton.icon(
          key: const Key('upload-create'),
          onPressed: busy ? null : onCreate,
          icon: const Icon(Icons.check),
          label: Text(l10n.templateCreateProject),
        ),
      ],
    );
  }
}

class _UnavailableView extends StatelessWidget {
  const _UnavailableView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.uploadScaffoldUnavailableTitle,
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: AppTokens.spacingSm),
        Text(
          l10n.uploadScaffoldUnavailableBody,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: AppTokens.spacingLg),
        FilledButton.icon(
          key: const Key('upload-fallback-picker'),
          onPressed: () => context.go(Routes.newProject),
          icon: const Icon(Icons.folder_special_outlined),
          label: Text(l10n.uploadScaffoldUnavailablePicker),
        ),
        const SizedBox(height: AppTokens.spacingSm),
        OutlinedButton.icon(
          key: const Key('upload-fallback-wizard'),
          onPressed: () => context.go(Routes.newProjectWizard),
          icon: const Icon(Icons.tune),
          label: Text(l10n.wizardBuildFromScratch),
        ),
      ],
    );
  }
}

/// "AI-scaffolded" badge — marks a Project (or personal template) created by the
/// upload→scaffold path so it is never mistaken for a Verified template
/// (blueprint §15 #22). Reused on the project detail screen.
class AiScaffoldedBadge extends StatelessWidget {
  const AiScaffoldedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Chip(
      key: const Key('ai-scaffolded-badge'),
      avatar: const Icon(Icons.auto_awesome_outlined, size: 16),
      label: Text(l10n.aiScaffoldedBadge),
      visualDensity: VisualDensity.compact,
    );
  }
}
