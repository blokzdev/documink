import 'package:documink/features/projects/active_project_provider.dart';
import 'package:documink/features/projects/project_providers.dart';
import 'package:documink/features/projects/template_manifest.dart';
import 'package:documink/l10n/gen/app_localizations.dart';
import 'package:documink/ui/screens/template_picker_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_vault.dart';

TemplateDefinition _template(String id, String name) =>
    TemplateDefinition.fromJson({
      'template_id': id,
      'name': name,
      'description': '$name documents',
      'domain': 'general',
      'manifest_schema_version': 1,
      'permissions': {'read_documents': true},
      'default_policy': {'PERSON': 'token_random'},
      'custom_entity_types': [
        {'label': 'CODE_$id', 'regex': r'X-\d+', 'default_operator': 'mask'},
      ],
      'mink_persona': '${id}_persona',
    });

void main() {
  late TestVault vault;
  late ProviderContainer container;

  setUp(() async {
    vault = await TestVault.unlocked();
    container = ProviderContainer(
      overrides: [
        vault.override,
        verifiedTemplatesProvider.overrideWith(
          (ref) async => [
            _template('medical', 'Medical'),
            _template('tax', 'Tax'),
          ],
        ),
      ],
    );
    addTearDown(container.dispose);
    addTearDown(vault.dispose);
  });

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: TemplatePickerScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('lists the verified templates', (tester) async {
    await pump(tester);
    expect(find.text('Medical'), findsOneWidget);
    expect(find.text('Tax'), findsOneWidget);
  });

  testWidgets('previewing a template and creating a Project', (tester) async {
    await pump(tester);

    await tester.tap(find.byKey(const Key('template-medical')));
    await tester.pumpAndSettle();

    // Preview sheet shows the name field (prefilled with the template name).
    final nameField = find.byKey(const Key('project-name-field'));
    expect(nameField, findsOneWidget);
    await tester.enterText(nameField, 'My Records');

    await tester.tap(find.byKey(const Key('create-project-button')));
    await tester.pumpAndSettle();

    // The Project is created from the template and becomes active.
    final projects = await container
        .read(projectRepositoryProvider)
        .listActive();
    expect(projects.single.name, 'My Records');
    expect(projects.single.templateId, 'medical');
    expect(container.read(activeProjectProvider), projects.single.id);
  });
}
