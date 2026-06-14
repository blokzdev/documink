import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/datetime_format.dart';
import '../../core/routes.dart';
import '../../data/app_database.dart';
import '../../features/projects/active_project_provider.dart';
import '../../features/projects/project_providers.dart';
import '../../l10n/gen/app_localizations.dart';
import '../theme/tokens.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_error_state.dart';
import '../widgets/section_header.dart';

/// Browse and switch between Projects (roadmap Phase 14 — project list). Tapping
/// a Project makes it active (documents + detection scope to it, §6.7) and opens
/// its documents; "All documents" clears the selection (workspace-global view).
/// Detail + settings editors are 14c-2.
class ProjectsListScreen extends ConsumerWidget {
  const ProjectsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final projectsAsync = ref.watch(projectsListProvider);
    final activeId = ref.watch(activeProjectProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.projectsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: l10n.projectsNewTooltip,
            onPressed: () => context.push(Routes.newProject),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppTokens.maxContentWidth,
            ),
            child: projectsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => AppErrorState(
                title: l10n.projectsLoadError,
                onRetry: () => ref.invalidate(projectsListProvider),
              ),
              data: (projects) => ListView(
                padding: const EdgeInsets.all(AppTokens.spacingMd),
                children: [
                  Card(
                    child: ListTile(
                      key: const Key('all-documents'),
                      leading: const Icon(Icons.folder_copy_outlined),
                      title: Text(l10n.projectsAllDocuments),
                      subtitle: Text(l10n.projectsAllDocumentsSubtitle),
                      trailing: activeId == null
                          ? const Icon(Icons.check_circle)
                          : null,
                      onTap: () {
                        ref.read(activeProjectProvider.notifier).clear();
                        context.push(Routes.vault);
                      },
                    ),
                  ),
                  SectionHeader(l10n.projectsSectionYours),
                  if (projects.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: AppTokens.spacingLg),
                      child: AppEmptyState(
                        icon: Icons.create_new_folder_outlined,
                        title: l10n.projectsEmptyTitle,
                        message: l10n.projectsEmptyMessage,
                      ),
                    )
                  else
                    for (final p in projects) ...[
                      _ProjectCard(project: p, active: p.id == activeId),
                      const SizedBox(height: AppTokens.spacingSm),
                    ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProjectCard extends ConsumerWidget {
  const _ProjectCard({required this.project, required this.active});

  final Project project;
  final bool active;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Card(
      child: ListTile(
        key: Key('project-${project.id}'),
        leading: const Icon(Icons.folder_special_outlined),
        title: Text(project.name, style: theme.textTheme.titleMedium),
        subtitle: Text(
          l10n.projectsTemplateLine(
            project.templateId ?? '—',
            formatTimestamp(project.updatedAt),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (active)
              Padding(
                padding: const EdgeInsets.only(right: AppTokens.spacingXs),
                child: Icon(
                  Icons.check_circle,
                  color: theme.colorScheme.primary,
                  semanticLabel: l10n.projectsActiveBadge,
                ),
              ),
            PopupMenuButton<String>(
              key: Key('project-menu-${project.id}'),
              onSelected: (value) async {
                if (value == 'archive') {
                  final messenger = ScaffoldMessenger.of(context);
                  await ref
                      .read(projectRepositoryProvider)
                      .setArchived(project.id, true);
                  if (active) {
                    ref.read(activeProjectProvider.notifier).clear();
                  }
                  ref.invalidate(projectsListProvider);
                  messenger.showSnackBar(
                    SnackBar(content: Text(l10n.projectsArchived)),
                  );
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'archive',
                  child: Text(l10n.projectsArchive),
                ),
              ],
            ),
          ],
        ),
        onTap: () {
          ref.read(activeProjectProvider.notifier).set(project.id);
          context.push(Routes.vault);
        },
      ),
    );
  }
}
