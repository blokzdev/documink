import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/datetime_format.dart';
import '../../features/documents/document_repository.dart';
import '../../features/documents/reveal_service.dart';
import '../theme/app_typography.dart';
import '../theme/tokens.dart';
import '../widgets/app_error_state.dart';
import '../widgets/status_badge.dart';

/// The reversible tokens for a document (drives whether to show Reveal).
final _tokenCountProvider = FutureProvider.autoDispose.family<int, String>(
  (ref, id) async =>
      (await ref.watch(documentRepositoryProvider).tokensForDocument(id))
          .length,
);

/// View of a saved document: its redacted text, with a biometric-gated reveal of
/// the original values behind reversible tokens (§5 `decode`).
class DocumentDetailScreen extends ConsumerStatefulWidget {
  const DocumentDetailScreen({super.key, required this.documentId});

  final String documentId;

  @override
  ConsumerState<DocumentDetailScreen> createState() =>
      _DocumentDetailScreenState();
}

class _DocumentDetailScreenState extends ConsumerState<DocumentDetailScreen> {
  Map<String, String>? _revealed;
  bool _revealing = false;

  Future<void> _reveal() async {
    setState(() => _revealing = true);
    final revealed = await ref
        .read(revealServiceProvider)
        .reveal(widget.documentId);
    if (!mounted) return;
    setState(() {
      _revealing = false;
      _revealed = revealed;
    });
    if (revealed == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Authentication failed')));
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete document?'),
        content: const Text(
          'This permanently removes the document and its tokens from the vault.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref
        .read(documentRepositoryProvider)
        .deleteDocument(widget.documentId);
    ref.invalidate(documentsListProvider);
    if (!mounted) return;
    await Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final docAsync = ref.watch(documentByIdProvider(widget.documentId));
    final tokenCount =
        ref.watch(_tokenCountProvider(widget.documentId)).valueOrNull ?? 0;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Document'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete',
            onPressed: _delete,
          ),
        ],
      ),
      body: SafeArea(
        child: docAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => AppErrorState(
            title: 'Could not load the document',
            onRetry: () =>
                ref.invalidate(documentByIdProvider(widget.documentId)),
          ),
          data: (doc) {
            if (doc == null) {
              return const Center(child: Text('Document not found.'));
            }
            final redacted = _redactedText(doc.metadataJson);
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppTokens.maxContentWidth,
                ),
                child: ListView(
                  padding: const EdgeInsets.all(AppTokens.spacingMd),
                  children: [
                    Text(doc.name, style: theme.textTheme.headlineSmall),
                    const SizedBox(height: AppTokens.spacingSm),
                    Row(
                      children: [
                        StatusBadge(doc.status),
                        const SizedBox(width: AppTokens.spacingSm),
                        Expanded(
                          child: Text(
                            '${doc.type} · ${formatTimestamp(doc.createdAt)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTokens.spacingLg),
                    Text(
                      'Redacted content',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppTokens.spacingSm),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppTokens.spacingMd),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(AppTokens.radiusMd),
                        ),
                      ),
                      child: SelectableText(
                        redacted ?? '(no preview stored)',
                        key: const Key('document-redacted-text'),
                        style: AppTypography.mono(context),
                      ),
                    ),
                    if (tokenCount > 0) ...[
                      const SizedBox(height: AppTokens.spacingMd),
                      FilledButton.tonalIcon(
                        onPressed: _revealing ? null : _reveal,
                        icon: const Icon(Icons.lock_open_outlined),
                        label: Text(
                          'Reveal original values ($tokenCount) · biometric',
                        ),
                      ),
                    ],
                    AnimatedSwitcher(
                      duration: AppTokens.durationMedium,
                      child: (_revealed != null && _revealed!.isNotEmpty)
                          ? Padding(
                              key: const Key('revealed-values'),
                              padding: const EdgeInsets.only(
                                top: AppTokens.spacingMd,
                              ),
                              child: Card(
                                color: theme.colorScheme.tertiaryContainer
                                    .withValues(alpha: 0.4),
                                child: Padding(
                                  padding: const EdgeInsets.all(
                                    AppTokens.spacingMd,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      for (final entry in _revealed!.entries)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 2,
                                          ),
                                          child: Text(
                                            '${entry.key} → ${entry.value}',
                                            style: AppTypography.mono(context),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
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

  String? _redactedText(String? metadataJson) {
    if (metadataJson == null) return null;
    final decoded = jsonDecode(metadataJson);
    return decoded is Map<String, dynamic>
        ? decoded['redactedText'] as String?
        : null;
  }
}
