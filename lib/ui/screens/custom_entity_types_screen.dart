import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/routes.dart';
import '../../features/custom_entities/custom_entity_definition.dart';
import '../../features/custom_entities/custom_entity_providers.dart';
import '../theme/app_typography.dart';
import '../theme/tokens.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_error_state.dart';

/// Settings → Custom entity types: list / add / edit / delete user-defined
/// detectors (roadmap §6). Saved entities feed the detection pipeline.
class CustomEntityTypesScreen extends ConsumerWidget {
  const CustomEntityTypesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entitiesAsync = ref.watch(customEntitiesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Custom entity types')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(Routes.customEntityForm),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: SafeArea(
        child: entitiesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => AppErrorState(
            title: 'Could not load custom entities',
            onRetry: () => ref.invalidate(customEntitiesProvider),
          ),
          data: (entities) {
            if (entities.isEmpty) {
              return const AppEmptyState(
                icon: Icons.label_outline,
                title: 'No custom entity types',
                message:
                    'Add a label + regex to detect your own sensitive data '
                    '(e.g. employee IDs, case numbers).',
              );
            }
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppTokens.maxContentWidth,
                ),
                child: ListView.separated(
                  padding: const EdgeInsets.all(AppTokens.spacingMd),
                  itemCount: entities.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppTokens.spacingSm),
                  itemBuilder: (context, i) => _EntityCard(entities[i]),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _EntityCard extends ConsumerWidget {
  const _EntityCard(this.def);

  final CustomEntityDefinition def;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Card(
      child: ListTile(
        title: Text(def.label, style: theme.textTheme.titleMedium),
        subtitle: Text(
          def.regexPattern,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.mono(context),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          tooltip: 'Delete',
          onPressed: () async {
            await ref.read(customEntityRepositoryProvider).delete(def.id);
            ref.invalidate(customEntitiesProvider);
          },
        ),
        onTap: () => context.push(Routes.customEntityForm, extra: def),
      ),
    );
  }
}
