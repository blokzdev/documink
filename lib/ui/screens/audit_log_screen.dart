import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/audit/audit_log_repository.dart';
import '../../features/audit/audit_providers.dart';
import '../widgets/app_empty_state.dart';

/// Settings → Audit log: a transparent, read-only view of privacy-relevant
/// actions (roadmap §15). Carries IDs/token-refs and metadata only — never PII.
class AuditLogScreen extends ConsumerWidget {
  const AuditLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(auditEntriesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Audit log')),
      body: SafeArea(
        child: entriesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) =>
              const Center(child: Text('Could not load the log.')),
          data: (entries) {
            if (entries.isEmpty) {
              return const AppEmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'No activity yet',
                message:
                    'Privacy-relevant actions (saves, reveals, deletes, …) '
                    'are recorded here.',
              );
            }
            return ListView.separated(
              itemCount: entries.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) => _EntryTile(entries[i]),
            );
          },
        ),
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile(this.entry);

  final AuditEntry entry;

  @override
  Widget build(BuildContext context) {
    final when = DateTime.fromMillisecondsSinceEpoch(entry.createdAt);
    final stamp = when
        .toIso8601String()
        .replaceFirst('T', ' ')
        .substring(0, 19);
    return ListTile(
      leading: Icon(
        entry.success ? Icons.check_circle_outline : Icons.error_outline,
        color: entry.success
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.error,
      ),
      title: Text(entry.eventType),
      subtitle: Text(stamp),
      trailing: entry.biometricResult != null
          ? Text(entry.biometricResult!)
          : null,
    );
  }
}
