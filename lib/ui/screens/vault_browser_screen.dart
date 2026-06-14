import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/routes.dart';
import '../../features/documents/document_repository.dart';
import '../theme/tokens.dart';

/// The vault browser: lists saved (redacted) documents (blueprint §Phase 5).
class VaultBrowserScreen extends ConsumerWidget {
  const VaultBrowserScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docsAsync = ref.watch(documentsListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('My documents')),
      body: SafeArea(
        child: docsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) =>
              const Center(child: Text('Could not load documents.')),
          data: (docs) {
            if (docs.isEmpty) {
              return const _EmptyState();
            }
            return ListView.separated(
              itemCount: docs.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final doc = docs[i];
                return ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: Text(doc.name),
                  subtitle: Text(doc.status),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(Routes.document(doc.id)),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.folder_open_outlined,
              size: 48,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: AppTokens.spacingMd),
            Text(
              'No documents yet.\nRedact some text and tap “Save to vault”.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
