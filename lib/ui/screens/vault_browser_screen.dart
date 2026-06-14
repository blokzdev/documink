import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/datetime_format.dart';
import '../../core/routes.dart';
import '../../data/app_database.dart';
import '../../features/documents/document_repository.dart';
import '../theme/tokens.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/status_badge.dart';

/// The vault browser: saved (redacted) documents as cards (blueprint §Phase 5).
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
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppTokens.maxContentWidth,
                ),
                child: ListView.separated(
                  padding: const EdgeInsets.all(AppTokens.spacingMd),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppTokens.spacingSm),
                  itemBuilder: (context, i) => _DocumentCard(docs[i]),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  const _DocumentCard(this.doc);

  final Document doc;

  IconData get _typeIcon => switch (doc.type) {
    'image' => Icons.image_outlined,
    'pdf' => Icons.picture_as_pdf_outlined,
    _ => Icons.description_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        onTap: () => context.push(Routes.document(doc.id)),
        child: Padding(
          padding: const EdgeInsets.all(AppTokens.spacingMd),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                ),
                child: Icon(
                  _typeIcon,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
              const SizedBox(width: AppTokens.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatTimestamp(doc.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppTokens.spacingSm),
              StatusBadge(doc.status),
            ],
          ),
        ),
      ),
    );
  }
}
