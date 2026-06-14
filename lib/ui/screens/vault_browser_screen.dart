import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/routes.dart';
import '../../features/documents/document_repository.dart';
import '../widgets/app_empty_state.dart';

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
              return const AppEmptyState(
                icon: Icons.folder_open_outlined,
                title: 'No documents yet',
                message: 'Redact some text and tap “Save to vault”.',
              );
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
