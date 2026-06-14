import 'dart:convert';

import 'package:documink/features/projects/active_project_provider.dart';
import 'package:documink/features/projects/project_providers.dart';
import 'package:documink/l10n/gen/app_localizations.dart';
import 'package:documink/ui/screens/projects_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../support/test_vault.dart';

String _manifest(String name) => jsonEncode({
  'manifest_schema_version': 1,
  'template_id': 'blank',
  'name': name,
  'permissions': <String, dynamic>{},
  'default_policy': <String, dynamic>{},
  'custom_entity_types': <dynamic>[],
});

void main() {
  late TestVault vault;
  late ProviderContainer container;

  setUp(() async {
    vault = await TestVault.unlocked();
    container = ProviderContainer(overrides: [vault.override]);
    addTearDown(container.dispose);
    addTearDown(vault.dispose);
  });

  Future<void> pump(WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: '/projects',
      routes: [
        GoRoute(
          path: '/projects',
          builder: (_, __) => const ProjectsListScreen(),
        ),
        GoRoute(
          path: '/vault',
          builder: (_, __) =>
              const Scaffold(body: Center(child: Text('VAULT'))),
        ),
        GoRoute(
          path: '/projects/new',
          builder: (_, __) => const Scaffold(body: Center(child: Text('NEW'))),
        ),
        GoRoute(
          path: '/projects/:id',
          builder: (_, state) => Scaffold(
            body: Center(child: Text('DETAIL ${state.pathParameters['id']}')),
          ),
        ),
      ],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('empty state when there are no projects', (tester) async {
    await pump(tester);
    expect(find.text('No projects yet'), findsOneWidget);
    expect(find.byKey(const Key('all-documents')), findsOneWidget);
  });

  testWidgets('lists projects; tapping one opens its detail', (tester) async {
    final repo = container.read(projectRepositoryProvider);
    final id = await repo.create(
      name: 'Medical',
      manifestJson: _manifest('Medical'),
    );
    await repo.create(name: 'Taxes', manifestJson: _manifest('Taxes'));

    await pump(tester);
    expect(find.text('Medical'), findsOneWidget);
    expect(find.text('Taxes'), findsOneWidget);

    await tester.tap(find.byKey(Key('project-$id')));
    await tester.pumpAndSettle();

    expect(find.text('DETAIL $id'), findsOneWidget);
  });

  testWidgets('"All documents" clears the active project and opens the vault', (
    tester,
  ) async {
    container.read(activeProjectProvider.notifier).set('something');
    await pump(tester);

    await tester.tap(find.byKey(const Key('all-documents')));
    await tester.pumpAndSettle();

    expect(container.read(activeProjectProvider), isNull);
    expect(find.text('VAULT'), findsOneWidget);
  });

  testWidgets('archive removes a project from the list', (tester) async {
    final repo = container.read(projectRepositoryProvider);
    final id = await repo.create(
      name: 'Scratch',
      manifestJson: _manifest('Scratch'),
    );

    await pump(tester);
    expect(find.text('Scratch'), findsOneWidget);

    await tester.tap(find.byKey(Key('project-menu-$id')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Archive'));
    await tester.pumpAndSettle();

    expect(await repo.listActive(), isEmpty);
    expect(find.text('Scratch'), findsNothing);
  });
}
