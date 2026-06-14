import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/database_providers.dart';
import 'audit_log_repository.dart';

/// Append-only audit trail (requires the unlocked vault DB).
final auditLogRepositoryProvider = Provider<AuditLogRepository>(
  (ref) => AuditLogRepository(ref.watch(appDatabaseProvider)),
);
