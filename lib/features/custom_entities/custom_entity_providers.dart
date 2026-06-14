import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/database_providers.dart';
import '../documents/document_repository.dart';
import '../projects/active_project_provider.dart';
import 'custom_entity_definition.dart';
import 'custom_entity_repository.dart';
import 'custom_entity_validator.dart';
import 'regex_sandbox.dart';

final customEntityValidatorProvider = Provider<CustomEntityValidator>(
  (ref) => const CustomEntityValidator(),
);

/// ReDoS-safe regex preview sandbox for the "Add Custom Entity" live preview.
final regexSandboxProvider = Provider<RegexSandbox>(
  (ref) => const RegexSandbox(),
);

/// Persists custom entity types (requires the unlocked vault DB).
final customEntityRepositoryProvider = Provider<CustomEntityRepository>(
  (ref) => CustomEntityRepository(ref.watch(appDatabaseProvider)),
);

/// The custom entity definitions in scope: the workspace-global ones plus the
/// active Project's own (§6.7 union). Auto-disposes so it refetches when the
/// management screen (or editor detection) reads it, and when the active Project
/// changes.
final customEntitiesProvider =
    FutureProvider.autoDispose<List<CustomEntityDefinition>>((ref) {
      final projectId = ref.watch(activeProjectProvider);
      return ref
          .watch(customEntityRepositoryProvider)
          .listInScope(
            DocumentRepository.defaultWorkspaceId,
            projectId: projectId,
          );
    });
