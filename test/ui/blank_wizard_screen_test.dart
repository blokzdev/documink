import 'dart:convert';

import 'package:documink/features/anonymization/operator.dart';
import 'package:documink/features/projects/active_project_provider.dart';
import 'package:documink/features/projects/project_providers.dart';
import 'package:documink/l10n/gen/app_localizations.dart';
import 'package:documink/ui/screens/blank_wizard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../support/test_vault.dart';

void main() {
  group('composeBlankManifest', () {
    test('encodes a §6.1 blank manifest from the answers', () {
      final json =
          jsonDecode(
                composeBlankManifest(
                  name: 'My Project',
                  domain: 'finance',
                  labels: {'PERSON', 'SSN'},
                  defaultOperator: Operator.fpe,
                  rewrite: false,
                  expand: true,
                  export: true,
                  decodeBiometric: true,
                ),
              )
              as Map<String, dynamic>;

      expect(json['template_id'], 'blank');
      expect(json['domain'], 'finance');
      final perms = json['permissions'] as Map;
      expect(perms['decode'], 'requires_biometric');
      expect(perms['expand_content'], true);
      expect(perms.containsKey('rewrite_content'), isFalse); // off → omitted
      expect(json['default_policy'], {'PERSON': 'fpe', 'SSN': 'fpe'});
    });
  });

  group('BlankWizardScreen', () {
    late TestVault vault;
    late ProviderContainer container;

    setUp(() async {
      vault = await TestVault.unlocked();
      container = ProviderContainer(overrides: [vault.override]);
      addTearDown(container.dispose);
      addTearDown(vault.dispose);
    });

    testWidgets('walks the steps and creates a Project', (tester) async {
      // A tall surface so the vertical Stepper's content isn't below the fold.
      tester.view.physicalSize = const Size(1200, 2600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final router = GoRouter(
        initialLocation: '/projects/new/wizard',
        routes: [
          GoRoute(
            path: '/projects/new/wizard',
            builder: (_, __) => const BlankWizardScreen(),
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

      // Step 1 — name.
      await tester.enterText(
        find.byKey(const Key('wizard-name')),
        'Field Notes',
      );
      await tester.tap(find.byKey(const Key('wizard-next')));
      await tester.pumpAndSettle();

      // Step 2 — pick a data type.
      await tester.tap(find.byKey(const Key('wizard-label-PERSON')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('wizard-next')));
      await tester.pumpAndSettle();

      // Step 3 — permissions (defaults are fine).
      await tester.tap(find.byKey(const Key('wizard-next')));
      await tester.pumpAndSettle();

      // Step 4 — create.
      await tester.tap(find.byKey(const Key('wizard-create')));
      await tester.pumpAndSettle();

      final projects = await container
          .read(projectRepositoryProvider)
          .listActive();
      expect(projects.single.name, 'Field Notes');
      expect(projects.single.templateId, 'blank');
      expect(container.read(activeProjectProvider), projects.single.id);
      expect(find.textContaining('DETAIL '), findsOneWidget);
    });
  });
}
