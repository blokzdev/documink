import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/datetime_format.dart';
import '../../features/audit/audit_event_labels.dart';
import '../../features/audit/audit_event_type.dart';
import '../../features/audit/audit_log_repository.dart';
import '../../features/audit/audit_providers.dart';
import '../../l10n/gen/app_localizations.dart';
import '../theme/tokens.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_error_state.dart';
import '../widgets/section_header.dart';

/// Settings → Audit log: a transparent, read-only view of privacy-relevant
/// actions (roadmap §15) — filterable by event type + time range and paginated.
/// Carries IDs/token-refs and metadata only — never PII.
class AuditLogScreen extends ConsumerWidget {
  const AuditLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final view = ref.watch(auditViewProvider);
    final entriesAsync = ref.watch(auditEntriesProvider);
    final typeCount = view.eventTypes.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.auditLogTitle),
        actions: [
          if (ref.watch(auditCsvExportEnabledProvider))
            IconButton(
              key: const Key('audit-export-button'),
              tooltip: l10n.auditExportTooltip,
              icon: const Icon(Icons.ios_share_outlined),
              onPressed: () => _exportCsv(context, ref),
            ),
          IconButton(
            key: const Key('audit-filter-button'),
            tooltip: l10n.auditFilterTooltip,
            icon: Badge(
              isLabelVisible: typeCount > 0,
              label: Text('$typeCount'),
              child: const Icon(Icons.filter_list),
            ),
            onPressed: () => _openTypeFilter(context, ref),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: _RangeBar(
            range: view.range,
            onChanged: (r) => ref.read(auditViewProvider.notifier).setRange(r),
          ),
        ),
      ),
      body: SafeArea(
        child: entriesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => AppErrorState(
            title: l10n.auditLogLoadError,
            onRetry: () => ref.invalidate(auditEntriesProvider),
          ),
          data: (entries) {
            if (entries.isEmpty) {
              return AppEmptyState(
                icon: Icons.receipt_long_outlined,
                title: l10n.auditLogEmptyTitle,
                message: l10n.auditLogEmptyMessage,
              );
            }
            // The query asked for `view.limit`; getting exactly that many means
            // there may be more to load.
            final mayHaveMore = entries.length >= view.limit;
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(auditEntriesProvider);
                await ref.read(auditEntriesProvider.future);
              },
              child: ListView.separated(
                itemCount: entries.length + (mayHaveMore ? 1 : 0),
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  if (i == entries.length) {
                    return Padding(
                      padding: const EdgeInsets.all(AppTokens.spacingMd),
                      child: OutlinedButton(
                        key: const Key('audit-load-more'),
                        onPressed: () =>
                            ref.read(auditViewProvider.notifier).loadMore(),
                        child: Text(l10n.auditLoadMore),
                      ),
                    );
                  }
                  return _EntryTile(entries[i]);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _openTypeFilter(BuildContext context, WidgetRef ref) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _TypeFilterSheet(),
    );
  }

  /// Builds CSV over the **current filter** and shows it for copy/share. Reuses
  /// `AuditLogRepository.exportCsv`; local-only (clipboard) — consistent with the
  /// Mink-memory export precedent. Native file share is a device follow-up
  /// (VERIFICATION.md). The CSV carries the same IDs/metadata as the rows — no PII.
  Future<void> _exportCsv(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final entries = await ref.read(auditEntriesProvider.future);
    final csv = AuditLogRepository.exportCsv(entries);
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.auditExportTitle),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: SelectableText(key: const Key('audit-export-csv'), csv),
          ),
        ),
        actions: [
          TextButton(
            key: const Key('audit-export-copy'),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: csv));
              Navigator.pop(ctx);
              messenger.showSnackBar(
                SnackBar(content: Text(l10n.auditExportCopied)),
              );
            },
            child: Text(l10n.auditExportCopy),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.auditExportClose),
          ),
        ],
      ),
    );
  }
}

/// The time-range selector (All / 24h / 7d / 30d).
class _RangeBar extends StatelessWidget {
  const _RangeBar({required this.range, required this.onChanged});

  final AuditRange range;
  final ValueChanged<AuditRange> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    String label(AuditRange r) => switch (r) {
      AuditRange.all => l10n.auditRangeAll,
      AuditRange.day => l10n.auditRangeDay,
      AuditRange.week => l10n.auditRangeWeek,
      AuditRange.month => l10n.auditRangeMonth,
    };
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTokens.spacingMd,
        0,
        AppTokens.spacingMd,
        AppTokens.spacingSm,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Wrap(
          spacing: AppTokens.spacingSm,
          children: [
            for (final r in AuditRange.values)
              ChoiceChip(
                key: Key('audit-range-${r.name}'),
                label: Text(label(r)),
                selected: range == r,
                onSelected: (_) => onChanged(r),
              ),
          ],
        ),
      ),
    );
  }
}

/// Multi-select bottom sheet for filtering by event type, grouped by area.
class _TypeFilterSheet extends ConsumerWidget {
  const _TypeFilterSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final selected = ref.watch(auditViewProvider).eventTypes;
    final notifier = ref.read(auditViewProvider.notifier);

    String groupLabel(String key) => switch (key) {
      'documents' => l10n.auditGroupDocuments,
      'security' => l10n.auditGroupSecurity,
      'ai' => l10n.auditGroupAi,
      'projects' => l10n.auditGroupProjects,
      'sync' => l10n.auditGroupSync,
      _ => key,
    };

    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.only(bottom: AppTokens.spacingLg),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTokens.spacingMd,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.auditFilterTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                TextButton(
                  key: const Key('audit-filter-clear'),
                  onPressed: selected.isEmpty ? null : notifier.clearTypes,
                  child: Text(l10n.auditFilterClear),
                ),
              ],
            ),
          ),
          for (final entry in auditEventTypeGroups.entries) ...[
            SectionHeader(groupLabel(entry.key)),
            for (final type in entry.value)
              CheckboxListTile(
                key: Key('audit-type-$type'),
                dense: true,
                title: Text(prettifyAuditEvent(type)),
                value: selected.contains(type),
                onChanged: (_) => notifier.toggleType(type),
              ),
          ],
        ],
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile(this.entry);

  final AuditEntry entry;

  IconData get _eventIcon => switch (entry.eventType) {
    'document_saved' => Icons.save_outlined,
    'document_deleted' => Icons.delete_outline,
    AuditEventType.documentOriginalRevealed => Icons.lock_open_outlined,
    AuditEventType.decode => Icons.lock_open_outlined,
    AuditEventType.export => Icons.ios_share_outlined,
    AuditEventType.vaultUnlock => Icons.key_outlined,
    AuditEventType.biometricFailed => Icons.fingerprint_outlined,
    AuditEventType.minkToolCall => Icons.smart_toy_outlined,
    AuditEventType.projectCreated ||
    AuditEventType.projectModified ||
    AuditEventType.projectArchived => Icons.folder_outlined,
    AuditEventType.personalTemplateSaved ||
    AuditEventType.personalTemplateDeleted => Icons.bookmark_outline,
    AuditEventType.syncPush || AuditEventType.syncPull => Icons.sync_outlined,
    _ => Icons.receipt_long_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final stamp = formatTimestamp(entry.createdAt);
    final tint = entry.success ? scheme.primary : scheme.error;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: tint.withValues(alpha: 0.14),
        foregroundColor: tint,
        child: Icon(_eventIcon, size: 20),
      ),
      title: Text(prettifyAuditEvent(entry.eventType)),
      subtitle: Text(stamp),
      trailing: entry.biometricResult != null
          ? Text(entry.biometricResult!)
          : null,
    );
  }
}
