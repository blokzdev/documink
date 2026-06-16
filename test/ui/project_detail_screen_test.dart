import 'dart:convert';
import 'dart:typed_data';

import 'package:documink/data/app_database.dart';
import 'package:documink/features/documents/document_repository.dart';
import 'package:documink/features/projects/active_project_provider.dart';
import 'package:documink/features/projects/project_providers.dart';
import 'package:documink/l10n/gen/app_localizations.dart';
import 'package:documink/services/database_providers.dart';
import 'package:documink/ui/screens/project_detail_screen.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_vault.dart';

String _manifest() => jsonEncode({
  'manifest_schema_version': 1,
  'template_id': 'blank',
  'name': 'P',
  'permissions': {'read_documents': true, 'export': false},
  'default_policy': {'PERSON': 'token_random'},
  'custom_entity_types': <dynamic>[],
  'mink_persona': 'old_persona',
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

  Future<String> makeProject() => container
      .read(projectRepositoryProvider)
      .create(name: 'P', manifestJson: _manifest());

  Future<void> pump(WidgetTester tester, String id) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ProjectDetailScreen(projectId: id),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<Map<String, dynamic>> manifestOf(String id) async {
    final project = await container.read(projectRepositoryProvider).getById(id);
    return jsonDecode(project!.manifestJson) as Map<String, dynamic>;
  }

  testWidgets('Documents tab lists the project documents', (tester) async {
    final id = await makeProject();
    // Insert a document scoped to the project.
    await container
        .read(appDatabaseProvider)
        .into(container.read(appDatabaseProvider).documents)
        .insert(
          DocumentsCompanion.insert(
            id: 'd1',
            workspaceId: DocumentRepository.defaultWorkspaceId,
            projectId: Value(id),
            name: 'Scan A',
            type: 'text',
            sourceHash: Uint8List.fromList([1]),
            createdAt: 0,
            updatedAt: 0,
            status: 'redacted',
          ),
        );

    await pump(tester, id);
    expect(find.text('Scan A'), findsOneWidget);
  });

  testWidgets('toggling a permission persists to the manifest', (tester) async {
    final id = await makeProject();
    await pump(tester, id);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    // read_documents starts true; toggle it off.
    await tester.tap(find.byKey(const Key('perm-read_documents')));
    await tester.pumpAndSettle();

    final m = await manifestOf(id);
    expect((m['permissions'] as Map)['read_documents'], false);
  });

  testWidgets('the active toggle sets the active project', (tester) async {
    final id = await makeProject();
    await pump(tester, id);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    expect(container.read(activeProjectProvider), isNull);
    await tester.tap(find.byKey(const Key('active-project-toggle')));
    await tester.pumpAndSettle();
    expect(container.read(activeProjectProvider), id);
  });

  testWidgets('editing the persona persists', (tester) async {
    final id = await makeProject();
    await pump(tester, id);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    await tester.drag(
      find.byKey(const Key('project-settings-list')),
      const Offset(0, -1200),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('persona-field')),
      'new_persona',
    );
    await tester.tap(find.byKey(const Key('persona-save')));
    await tester.pumpAndSettle();

    final m = await manifestOf(id);
    expect(m['mink_persona'], 'new_persona');
  });

  testWidgets('shows the AI-scaffolded badge for an ai_scaffolded project', (
    tester,
  ) async {
    final id = await container
        .read(projectRepositoryProvider)
        .create(
          name: 'Scaffolded',
          templateId: 'ai_scaffolded',
          manifestJson: jsonEncode({
            'manifest_schema_version': 1,
            'template_id': 'ai_scaffolded',
            'name': 'Scaffolded',
            'permissions': {'read_documents': true},
            'default_policy': <String, dynamic>{},
            'custom_entity_types': <dynamic>[],
          }),
        );
    await pump(tester, id);
    expect(find.byKey(const Key('ai-scaffolded-badge')), findsOneWidget);
  });

  testWidgets('does not badge a Verified-template project', (tester) async {
    final id = await makeProject();
    await pump(tester, id);
    expect(find.byKey(const Key('ai-scaffolded-badge')), findsNothing);
  });

  testWidgets('save-as-personal-template persists the manifest', (
    tester,
  ) async {
    final id = await makeProject();
    await pump(tester, id);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await tester.drag(
      find.byKey(const Key('project-settings-list')),
      const Offset(0, -1600),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('save-as-personal-template')));
    await tester.pumpAndSettle();

    final saved = await container
        .read(personalTemplateRepositoryProvider)
        .list();
    expect(saved, hasLength(1));
    expect(saved.single.name, 'P');
    expect(saved.single.origin.name, 'customized');
  });
}
