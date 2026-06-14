import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/database_providers.dart';
import 'custom_entity_repository.dart';
import 'custom_entity_validator.dart';

final customEntityValidatorProvider = Provider<CustomEntityValidator>(
  (ref) => const CustomEntityValidator(),
);

/// Persists custom entity types (requires the unlocked vault DB).
final customEntityRepositoryProvider = Provider<CustomEntityRepository>(
  (ref) => CustomEntityRepository(ref.watch(appDatabaseProvider)),
);
