import 'package:documink/features/audit/audit_providers.dart';
import 'package:documink/features/documents/document_repository.dart';
import 'package:documink/l10n/gen/app_localizations.dart';
import 'package:documink/ui/screens/audit_log_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_vault.dart';

void main() {
  late TestVault vault;
  late ProviderContainer container;
  var seq = 0;

  setUp(() async {
    vault = await TestVault.unlocked();
    container = ProviderContainer(overrides: [vault.override]);
    addTearDown(container.dispose);
    addTearDown(vault.dispose);
    seq = 0;
    // The audit row FKs the workspace; ensure it before recording.
    await container.read(documentRepositoryProvider).ensureDefaultWorkspace();
  });

  Future<void> rec(String type, {int? at, int n = 1}) async {
    final repo = container.read(auditLogRepositoryProvider);
    for (var i = 0; i < n; i++) {
      await repo.record(
        id: 'a${seq++}',
        workspaceId: DocumentRepository.defaultWorkspaceId,
        eventType: type,
        success: true,
        nowEpochMs: at ?? DateTime.now().millisecondsSinceEpoch,
      );
    }
  }

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: AuditLogScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('empty state when no activity', (tester) async {
    await pump(tester);
    expect(find.textContaining('No activity yet'), findsOneWidget);
  });

  testWidgets('shows a logged event with a human-readable label', (
    tester,
  ) async {
    await rec('document_saved');
    await pump(tester);
    expect(find.text('Document saved'), findsOneWidget);
  });

  testWidgets('filters by event type via the filter sheet', (tester) async {
    await rec('document_saved');
    await rec('project_created');
    await pump(tester);

    await tester.tap(find.byKey(const Key('audit-filter-button')));
    await tester.pumpAndSettle();
    // 'document_saved' is the first item in the sheet (always on-screen).
    await tester.tap(find.byKey(const Key('audit-type-document_saved')));
    await tester.pumpAndSettle();

    // The selection is applied to the view state...
    expect(
      container.read(auditViewProvider).eventTypes,
      contains('document_saved'),
    );
    // ...and the query now returns only the document event (the badge on the
    // filter button reflects one active type).
    final entries = await container.read(auditEntriesProvider.future);
    expect(entries.map((e) => e.eventType), ['document_saved']);
    expect(
      find.descendant(of: find.byType(Badge), matching: find.text('1')),
      findsOneWidget,
    );
  });

  testWidgets('filters by time range', (tester) async {
    final old = DateTime.now()
        .subtract(const Duration(days: 60))
        .millisecondsSinceEpoch;
    await rec('document_saved'); // now
    await rec('project_archived', at: old); // 60 days ago
    await pump(tester);

    expect(find.text('Project archived'), findsOneWidget);

    await tester.tap(find.byKey(const Key('audit-range-day')));
    await tester.pumpAndSettle();

    // The old event drops out of the 24h window; the recent one stays.
    expect(find.text('Document saved'), findsOneWidget);
    expect(find.text('Project archived'), findsNothing);
  });

  testWidgets('paginates with Load more', (tester) async {
    await rec('document_saved', n: auditPageSize + 5);
    await pump(tester);

    // First page is full → the Load-more affordance is at the end of the list.
    final loadMore = find.byKey(const Key('audit-load-more'));
    await tester.scrollUntilVisible(loadMore, 600);
    expect(loadMore, findsOneWidget);

    await tester.tap(loadMore);
    await tester.pumpAndSettle();

    // All entries now fit → no more Load-more button.
    expect(find.byKey(const Key('audit-load-more')), findsNothing);
  });
}
