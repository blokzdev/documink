import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/database_providers.dart';
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
