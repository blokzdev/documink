import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/database_providers.dart';
import 'chat_repository.dart';

/// Chat session + message persistence (requires the unlocked vault).
final chatRepositoryProvider = Provider<ChatRepository>(
  (ref) => ChatRepository(ref.watch(appDatabaseProvider)),
);
