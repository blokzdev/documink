import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/routes.dart';
import '../../features/projects/active_project_provider.dart';
import '../../features/projects/project_providers.dart';
import '../../features/projects/template_manifest.dart';
import '../../l10n/gen/app_localizations.dart';
import '../theme/tokens.dart';
import '../widgets/app_error_state.dart';
import '../widgets/section_header.dart';

/// Project creation — Path A (blueprint §6.2): pick a Verified template, preview
/// what it sets up, name the Project, and create it. The template catalog is the
/// Ed25519-verified bundled manifest (14b-1); creation seeds the template's
/// custom entities (14a).
class TemplatePickerScreen extends ConsumerWidget {
  const TemplatePickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final templatesAsync = ref.watch(verifiedTemplatesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.templatePickerTitle)),
      body: SafeArea(
        child: templatesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => AppErrorState(
            title: l10n.templatePickerLoadError,
            onRetry: () => ref.invalidate(verifiedTemplatesProvider),
          ),
          data: (templates) => Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppTokens.maxContentWidth,
              ),
              child: ListView(
                padding: const EdgeInsets.all(AppTokens.spacingMd),
                children: [
                  Text(
                    l10n.templatePickerSubtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppTokens.spacingMd),
                  for (final t in templates) ...[
                    _TemplateCard(t),
                    const SizedBox(height: AppTokens.spacingSm),
                  ],
                  const SizedBox(height: AppTokens.spacingSm),
                  OutlinedButton.icon(
                    key: const Key('build-from-scratch'),
                    onPressed: () => context.push(Routes.newProjectWizard),
                    icon: const Icon(Icons.tune),
                    label: Text(l10n.wizardBuildFromScratch),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  const _TemplateCard(this.template);

  final TemplateDefinition template;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: ListTile(
        key: Key('template-${template.templateId}'),
        leading: const Icon(Icons.folder_special_outlined),
        title: Text(template.name, style: theme.textTheme.titleMedium),
        subtitle: Text(
          template.description,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right),
        isThreeLine: true,
        onTap: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          showDragHandle: true,
          builder: (_) => _TemplatePreviewSheet(template),
        ),
      ),
    );
  }
}

/// Preview of what a template sets up, with the project-name field and the
/// create action.
class _TemplatePreviewSheet extends ConsumerStatefulWidget {
  const _TemplatePreviewSheet(this.template);

  final TemplateDefinition template;

  @override
  ConsumerState<_TemplatePreviewSheet> createState() =>
      _TemplatePreviewSheetState();
}

class _TemplatePreviewSheetState extends ConsumerState<_TemplatePreviewSheet> {
  late final TextEditingController _name = TextEditingController(
    text: widget.template.name,
  );
  bool _creating = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final name = _name.text.trim();
    if (name.isEmpty || _creating) return;
    setState(() => _creating = true);

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final l10n = AppLocalizations.of(context);
    final template = widget.template;

    final id = await ref
        .read(projectRepositoryProvider)
        .create(
          name: name,
          templateId: template.templateId,
          manifestJson: template.buildProjectManifestJson(projectName: name),
        );
    ref.read(activeProjectProvider.notifier).set(id);
    ref.invalidate(projectsListProvider);

    if (!mounted) return;
    navigator.pop(); // close the sheet
    navigator.maybePop(); // leave the picker
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.templateProjectCreated)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final t = widget.template;
    final policy = t.defaultPolicy;

    return Padding(
      padding: EdgeInsets.only(
        left: AppTokens.spacingMd,
        right: AppTokens.spacingMd,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppTokens.spacingMd,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.name, style: theme.textTheme.headlineSmall),
            const SizedBox(height: AppTokens.spacingSm),
            Text(t.description, style: theme.textTheme.bodyMedium),

            SectionHeader(l10n.templatePreviewDefaults),
            if (policy.isEmpty)
              Text(
                l10n.templatePreviewNoDefaults,
                style: theme.textTheme.bodySmall,
              )
            else
              Wrap(
                spacing: AppTokens.spacingSm,
                runSpacing: AppTokens.spacingXs,
                children: [
                  for (final e in policy.entries)
                    Chip(label: Text('${e.key} → ${e.value}')),
                ],
              ),

            if (t.customEntityLabels.isNotEmpty) ...[
              SectionHeader(l10n.templatePreviewCustomEntities),
              Wrap(
                spacing: AppTokens.spacingSm,
                runSpacing: AppTokens.spacingXs,
                children: [
                  for (final label in t.customEntityLabels)
                    Chip(label: Text(label)),
                ],
              ),
            ],

            if (t.minkPersona != null) ...[
              SectionHeader(l10n.templatePreviewPersona),
              Text(t.minkPersona!, style: theme.textTheme.bodySmall),
            ],

            const SizedBox(height: AppTokens.spacingLg),
            TextField(
              key: const Key('project-name-field'),
              controller: _name,
              decoration: InputDecoration(
                labelText: l10n.templateProjectNameLabel,
              ),
            ),
            const SizedBox(height: AppTokens.spacingMd),
            FilledButton.icon(
              key: const Key('create-project-button'),
              onPressed: _creating ? null : _create,
              icon: const Icon(Icons.check),
              label: Text(l10n.templateCreateProject),
            ),
          ],
        ),
      ),
    );
  }
}
