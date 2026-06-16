import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/database_providers.dart';
import '../documents/document_repository.dart';
import 'audit_log_repository.dart';

/// Append-only audit trail (requires the unlocked vault DB).
final auditLogRepositoryProvider = Provider<AuditLogRepository>(
  (ref) => AuditLogRepository(ref.watch(appDatabaseProvider)),
);

/// Whether the audit-log **CSV export** action is available (roadmap §15: "CSV
/// export shipped in V1 with an internal flag for Pro-gate activation in V1.1").
/// **V1 ships it on.** Kept as an overridable provider so V1.1 flips the gate to
/// a Pro-tier check in one place — not a code-archaeology hunt (logged in
/// DECISIONS).
final auditCsvExportEnabledProvider = Provider<bool>((ref) => true);

/// Time window for the audit-log viewer (roadmap §15 "filterable by … time
/// range"). [all] is unbounded; the rest map to a `since` cutoff.
enum AuditRange { all, day, week, month }

/// The cutoff epoch-ms for [range] relative to [now], or null for [AuditRange.all].
int? auditRangeSince(AuditRange range, DateTime now) => switch (range) {
  AuditRange.all => null,
  AuditRange.day =>
    now.subtract(const Duration(days: 1)).millisecondsSinceEpoch,
  AuditRange.week =>
    now.subtract(const Duration(days: 7)).millisecondsSinceEpoch,
  AuditRange.month =>
    now.subtract(const Duration(days: 30)).millisecondsSinceEpoch,
};

/// How many entries one page loads; "Load more" grows the limit by this.
const int auditPageSize = 50;

/// The viewer state: active filters + how many entries to load. A pure value
/// object so the [auditEntriesProvider] query is a function of it.
class AuditView {
  const AuditView({
    this.range = AuditRange.all,
    this.eventTypes = const {},
    this.limit = auditPageSize,
  });

  final AuditRange range;
  final Set<String> eventTypes;
  final int limit;

  AuditView copyWith({
    AuditRange? range,
    Set<String>? eventTypes,
    int? limit,
  }) => AuditView(
    range: range ?? this.range,
    eventTypes: eventTypes ?? this.eventTypes,
    limit: limit ?? this.limit,
  );
}

/// Drives the audit viewer's filters + pagination. Changing any filter resets
/// the page (limit) so a narrowed query starts from the first page.
class AuditViewNotifier extends Notifier<AuditView> {
  @override
  AuditView build() => const AuditView();

  void setRange(AuditRange range) =>
      state = state.copyWith(range: range, limit: auditPageSize);

  void toggleType(String eventType) {
    final next = {...state.eventTypes};
    if (!next.add(eventType)) next.remove(eventType);
    state = state.copyWith(eventTypes: next, limit: auditPageSize);
  }

  void clearTypes() =>
      state = state.copyWith(eventTypes: const {}, limit: auditPageSize);

  void loadMore() => state = state.copyWith(limit: state.limit + auditPageSize);
}

final auditViewProvider = NotifierProvider<AuditViewNotifier, AuditView>(
  AuditViewNotifier.new,
);

/// The audit entries for the active [auditViewProvider] filters (newest first).
/// Auto-disposes so it refetches each time the log is opened and on every filter
/// or page change. Empty `eventTypes` means "all types".
final auditEntriesProvider = FutureProvider.autoDispose<List<AuditEntry>>((
  ref,
) {
  final view = ref.watch(auditViewProvider);
  return ref
      .watch(auditLogRepositoryProvider)
      .query(
        DocumentRepository.defaultWorkspaceId,
        eventTypes: view.eventTypes.isEmpty ? null : view.eventTypes.toList(),
        sinceEpochMs: auditRangeSince(view.range, DateTime.now()),
        limit: view.limit,
      );
});
