import 'package:documink/features/anonymization/operator.dart';
import 'package:documink/features/custom_entities/custom_entity_definition.dart';
import 'package:documink/features/custom_entities/custom_entity_providers.dart';
import 'package:documink/features/documents/document_repository.dart';
import 'package:documink/ui/screens/custom_entity_form_screen.dart';
import 'package:documink/ui/screens/custom_entity_types_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_vault.dart';

void main() {
  late TestVault vault;
  late ProviderContainer container;

  setUp(() async {
    vault = await TestVault.unlocked();
    container = ProviderContainer(overrides: [vault.override]);
    addTearDown(container.dispose);
    addTearDown(vault.dispose);
  });

  Future<void> pump(WidgetTester tester, Widget child) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(home: child),
      ),
    );
    await tester.pumpAndSettle();
  }

  CustomEntityDefinition def(String label, String pattern) =>
      CustomEntityDefinition(
        id: 'id_$label',
        workspaceId: DocumentRepository.defaultWorkspaceId,
        label: label,
        regexPattern: pattern,
        defaultOperator: Operator.redact,
        createdAtEpochMs: 0,
      );

  testWidgets('list shows empty state then a saved entity', (tester) async {
    await pump(tester, const CustomEntityTypesScreen());
    expect(find.textContaining('No custom entity types'), findsOneWidget);

    await container.read(documentRepositoryProvider).ensureDefaultWorkspace();
    await container
        .read(customEntityRepositoryProvider)
        .save(def('EMPLOYEE_ID', r'EMP-\d{6}'));
    container.invalidate(customEntitiesProvider);
    await pump(tester, const CustomEntityTypesScreen());
    expect(find.text('EMPLOYEE_ID'), findsOneWidget);
  });

  testWidgets('form rejects an invalid regex', (tester) async {
    await pump(tester, const CustomEntityFormScreen());
    await tester.enterText(find.byKey(const Key('cet-label')), 'X');
    await tester.enterText(find.byKey(const Key('cet-regex')), '(');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Invalid pattern'), findsOneWidget);
  });

  testWidgets('form saves a valid entity', (tester) async {
    await pump(tester, const CustomEntityFormScreen());
    await tester.enterText(find.byKey(const Key('cet-label')), 'TICKET');
    await tester.enterText(find.byKey(const Key('cet-regex')), r'TKT-\d+');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final saved = await container.read(customEntitiesProvider.future);
    expect(saved.any((d) => d.label == 'TICKET'), isTrue);
  });
}
