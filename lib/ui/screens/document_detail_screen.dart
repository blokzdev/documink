import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/documents/document_repository.dart';
import '../theme/tokens.dart';

/// Read-only view of a saved document: its redacted text + metadata. Revealing
/// reversible tokens (biometric-gated) is a later phase.
class DocumentDetailScreen extends ConsumerWidget {
  const DocumentDetailScreen({super.key, required this.documentId});

  final String documentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docAsync = ref.watch(documentByIdProvider(documentId));
    return Scaffold(
      appBar: AppBar(title: const Text('Document')),
      body: SafeArea(
        child: docAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(child: Text('Could not load.')),
          data: (doc) {
            if (doc == null) {
              return const Center(child: Text('Document not found.'));
            }
            final theme = Theme.of(context);
            final redacted = _redactedText(doc.metadataJson);
            return ListView(
              padding: const EdgeInsets.all(AppTokens.spacingMd),
              children: [
                Text(doc.name, style: theme.textTheme.headlineSmall),
                const SizedBox(height: AppTokens.spacingSm),
                Text(
                  '${doc.type} · ${doc.status}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                const SizedBox(height: AppTokens.spacingMd),
                Text('Redacted content', style: theme.textTheme.titleMedium),
                const SizedBox(height: AppTokens.spacingSm),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppTokens.spacingMd),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    redacted ?? '(no preview stored)',
                    key: const Key('document-redacted-text'),
                  ),
                ),
              ],
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
