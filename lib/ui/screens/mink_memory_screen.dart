import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/memory/memory_repository.dart';
import '../../features/memory/mink_memory_providers.dart';
import '../theme/tokens.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_error_state.dart';
import '../widgets/section_header.dart';
import '../widgets/token_text.dart';

/// Settings → Mink Memory: review and manage what Mink remembers — Core and
/// Episodic entries in the active scope, separated into the active Project and
/// workspace globals, each with provenance and per-entry delete, plus export
/// and a "forget about a topic" action (memory.md §8.1, roadmap Phase 12).
class MinkMemoryScreen extends ConsumerWidget {
  const MinkMemoryScreen({super.key});

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Future<void> Function() delete,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Forget this?'),
        content: const Text('Mink will no longer remember this entry.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Forget'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await delete();
      ref.invalidate(minkMemoryViewProvider);
    }
  }

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    final view = await ref.read(minkMemoryViewProvider.future);
    final json = const JsonEncoder.withIndent(
      '  ',
    ).convert(ref.read(minkMemoryActionsProvider).exportJson(view));
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Memory export'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(child: SelectableText(json)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: json));
              Navigator.pop(ctx);
            },
            child: const Text('Copy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _forgetAbout(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final topic = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Forget about…'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'A topic, e.g. a project or subject',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Forget'),
          ),
        ],
      ),
    );
    if (topic == null || topic.trim().isEmpty) return;
    final view = await ref.read(minkMemoryViewProvider.future);
    final removed = await ref
        .read(minkMemoryActionsProvider)
        .forgetAbout(topic, view);
    ref.invalidate(minkMemoryViewProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Forgot $removed ${removed == 1 ? 'entry' : 'entries'}.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewAsync = ref.watch(minkMemoryViewProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mink memory'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'export') _export(context, ref);
              if (v == 'forget') _forgetAbout(context, ref);
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'export', child: Text('Export as JSON')),
              PopupMenuItem(value: 'forget', child: Text('Forget about…')),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: viewAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => AppErrorState(
            title: 'Could not load Mink memory',
            onRetry: () => ref.invalidate(minkMemoryViewProvider),
          ),
          data: (view) {
            if (view.isEmpty) {
              return const AppEmptyState(
                icon: Icons.psychology_outlined,
                title: 'Nothing remembered yet',
                message:
                    'As you chat and work, Mink remembers useful context here — '
                    'always on-device, never raw personal data.',
              );
            }
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppTokens.maxContentWidth,
                ),
                child: ListView(
                  padding: const EdgeInsets.only(bottom: AppTokens.spacingLg),
                  children: [
                    if (view.projectCore.isNotEmpty ||
                        view.projectEpisodic.isNotEmpty) ...[
                      const SectionHeader('This project'),
                      ...view.projectCore.map(
                        (e) => _CoreTile(
                          e,
                          onDelete: () => _confirmDelete(
                            context,
                            ref,
                            () => ref
                                .read(minkMemoryActionsProvider)
                                .forgetCore(e.id),
                          ),
                        ),
                      ),
                      ...view.projectEpisodic.map(
                        (e) => _EpisodicTile(
                          e,
                          onDelete: () => _confirmDelete(
                            context,
                            ref,
                            () => ref
                                .read(minkMemoryActionsProvider)
                                .forgetEpisodic(e.id),
                          ),
                        ),
                      ),
                    ],
                    const SectionHeader('Global'),
                    ...view.globalCore.map(
                      (e) => _CoreTile(
                        e,
                        onDelete: () => _confirmDelete(
                          context,
                          ref,
                          () => ref
                              .read(minkMemoryActionsProvider)
                              .forgetCore(e.id),
                        ),
                      ),
                    ),
                    ...view.globalEpisodic.map(
                      (e) => _EpisodicTile(
                        e,
                        onDelete: () => _confirmDelete(
                          context,
                          ref,
                          () => ref
                              .read(minkMemoryActionsProvider)
                              .forgetEpisodic(e.id),
                        ),
                      ),
                    ),
                    if (view.globalCore.isEmpty && view.globalEpisodic.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(AppTokens.spacingMd),
                        child: Text('No global memories.'),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CoreTile extends StatelessWidget {
  const _CoreTile(this.entry, {required this.onDelete});

  final CoreMemoryEntry entry;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTokens.spacingMd,
        vertical: AppTokens.spacingXs,
      ),
      child: ListTile(
        leading: const Icon(Icons.bookmark_outline),
        title: Text(entry.key),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TokenText('${entry.value}'),
            const SizedBox(height: AppTokens.spacingXs),
            Text(
              memoryProvenanceLabel(entry.provenance),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          tooltip: 'Forget',
          onPressed: onDelete,
        ),
      ),
    );
  }
}

class _EpisodicTile extends StatelessWidget {
  const _EpisodicTile(this.entry, {required this.onDelete});

  final EpisodicEntry entry;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTokens.spacingMd,
        vertical: AppTokens.spacingXs,
      ),
      child: ListTile(
        leading: const Icon(Icons.history_outlined),
        title: TokenText(entry.summary),
        subtitle: Text(
          entry.episodeType,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          tooltip: 'Forget',
          onPressed: onDelete,
        ),
      ),
    );
  }
}
