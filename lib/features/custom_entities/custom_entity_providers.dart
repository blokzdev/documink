import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/database_providers.dart';
import '../documents/document_repository.dart';
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

/// The custom entity definitions in the default workspace. Auto-disposes so it
/// refetches when the management screen (or editor detection) reads it.
final customEntitiesProvider =
    FutureProvider.autoDispose<List<CustomEntityDefinition>>(
      (ref) => ref
          .watch(customEntityRepositoryProvider)
          .listInScope(DocumentRepository.defaultWorkspaceId),
    );
