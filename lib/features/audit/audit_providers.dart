import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/database_providers.dart';
import '../documents/document_repository.dart';
import 'audit_log_repository.dart';

/// Append-only audit trail (requires the unlocked vault DB).
final auditLogRepositoryProvider = Provider<AuditLogRepository>(
  (ref) => AuditLogRepository(ref.watch(appDatabaseProvider)),
);

/// The most recent audit entries (newest first). Auto-disposes so it refetches
/// each time the audit log is opened.
final auditEntriesProvider = FutureProvider.autoDispose<List<AuditEntry>>(
  (ref) => ref
      .watch(auditLogRepositoryProvider)
      .query(DocumentRepository.defaultWorkspaceId, limit: 200),
);
