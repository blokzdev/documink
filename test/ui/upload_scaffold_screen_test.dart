import 'package:documink/core/routes.dart';
import 'package:documink/features/input/ingested_text.dart';
import 'package:documink/features/llm/llm_backend.dart';
import 'package:documink/features/projects/active_project_provider.dart';
import 'package:documink/features/projects/ai_scaffold_orchestrator.dart';
import 'package:documink/features/projects/domain_inference_service.dart';
import 'package:documink/features/projects/project_providers.dart';
import 'package:documink/features/projects/template_manifest.dart';
import 'package:documink/l10n/gen/app_localizations.dart';
import 'package:documink/ui/screens/upload_scaffold_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../support/test_vault.dart';

/// Canned LLM returning a fixed completion so the orchestrator branches
/// deterministically (no real model).
class _FakeLlm implements LlmBackend {
  _FakeLlm(this.reply, {this.available = true});
  final String reply;
  final bool available;

  @override
  Future<bool> isAvailable() async => available;
  @override
  Future<String> generate(String prompt, {int maxOutputTokens = 512}) async {
    if (!available) throw const LlmUnavailableException();
    return reply;
  }
}

TemplateDefinition _template(String id, String name) =>
    TemplateDefinition.fromJson({
      'template_id': id,
      'name': name,
      'description': '$name documents',
      'domain': 'general',
      'manifest_schema_version': 1,
      'permissions': {'read_documents': true},
      'default_policy': {'PERSON': 'token_random'},
      'custom_entity_types': <dynamic>[],
    });

void main() {
  late TestVault vault;
  late ProviderContainer container;

  /// Builds the container with a fake orchestrator that yields the given LLM
  /// reply over a fixed ingested document.
  ProviderContainer build(String reply, {bool available = true}) {
    return ProviderContainer(
      overrides: [
        vault.override,
        verifiedTemplatesProvider.overrideWith(
          (ref) async => [
            _template('medical', 'Medical'),
            _template('legal', 'Legal'),
            _template('tax', 'Tax'),
          ],
        ),
        aiScaffoldOrchestratorProvider.overrideWith(
          (ref) => AiScaffoldOrchestrator(
            pickDocument: () async => const IngestedText(
              text: 'A clinical discharge summary for the patient.',
              source: InputSourceKind.pdfImport,
            ),
            inference: DomainInferenceService(
              _FakeLlm(reply, available: available),
            ),
          ),
        ),
      ],
    );
  }

  setUp(() async {
    vault = await TestVault.unlocked();
  });

  tearDown(() {
    container.dispose();
    vault.dispose();
  });

  Future<void> pump(WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: Routes.newProjectAiScaffold,
      routes: [
        GoRoute(
          path: Routes.newProjectAiScaffold,
          builder: (_, __) => const UploadScaffoldScreen(),
        ),
        GoRoute(
          path: Routes.paste,
          builder: (_, __) => const Scaffold(body: Text('paste-editor-stub')),
        ),
        GoRoute(
          path: Routes.newProject,
          builder: (_, __) => const Scaffold(body: Text('picker-stub')),
        ),
        GoRoute(
          path: Routes.newProjectWizard,
          builder: (_, __) => const Scaffold(body: Text('wizard-stub')),
        ),
      ],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> analyze(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('upload-choose')));
    await tester.pumpAndSettle();
  }

  testWidgets('strong match pre-selects the verified template and creates it', (
    tester,
  ) async {
    container = build(
      '{"domain":"healthcare","confidence":0.92,"candidates":["medical"]}',
    );
    await pump(tester);
    await analyze(tester);

    // The recommended template card is shown, name prefilled with its name.
    expect(find.byKey(const Key('upload-strong-medical')), findsOneWidget);

    await tester.tap(find.byKey(const Key('upload-create')));
    await tester.pumpAndSettle();

    final projects = await container
        .read(projectRepositoryProvider)
        .listActive();
    expect(projects.single.templateId, 'medical');
    expect(container.read(activeProjectProvider), projects.single.id);
    // Handed off to the redaction editor to import the document.
    expect(find.text('paste-editor-stub'), findsOneWidget);
  });

  testWidgets('weak match offers candidates; picking one creates it', (
    tester,
  ) async {
    container = build(
      '{"domain":"legal","confidence":0.6,"candidates":["legal","tax"]}',
    );
    await pump(tester);
    await analyze(tester);

    expect(find.byKey(const Key('upload-candidate-legal')), findsOneWidget);
    expect(find.byKey(const Key('upload-candidate-tax')), findsOneWidget);

    await tester.tap(find.byKey(const Key('upload-candidate-tax')));
    await tester.pumpAndSettle();

    final projects = await container
        .read(projectRepositoryProvider)
        .listActive();
    expect(projects.single.templateId, 'tax');
  });

  testWidgets('no match scaffolds an AI project, badged, with a save prompt', (
    tester,
  ) async {
    container = build(
      '{"domain":"veterinary","confidence":0.3,"candidates":["medical"]}',
    );
    await pump(tester);
    await analyze(tester);

    expect(find.byKey(const Key('ai-scaffolded-badge')), findsOneWidget);

    await tester.tap(find.byKey(const Key('upload-create')));
    await tester.pumpAndSettle();

    // The save-as-personal-template dialog appears; decline it.
    expect(find.byKey(const Key('upload-save-personal-yes')), findsOneWidget);
    await tester.tap(find.byKey(const Key('upload-save-personal-no')));
    await tester.pumpAndSettle();

    final projects = await container
        .read(projectRepositoryProvider)
        .listActive();
    expect(projects.single.templateId, 'ai_scaffolded');
    expect(
      await container.read(personalTemplateRepositoryProvider).list(),
      isEmpty,
    );
  });

  testWidgets('scaffold + confirm save persists a personal template', (
    tester,
  ) async {
    container = build(
      '{"domain":"veterinary","confidence":0.3,"candidates":["medical"]}',
    );
    await pump(tester);
    await analyze(tester);

    await tester.tap(find.byKey(const Key('upload-create')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('upload-save-personal-yes')));
    await tester.pumpAndSettle();

    final saved = await container
        .read(personalTemplateRepositoryProvider)
        .list();
    expect(saved, hasLength(1));
    expect(saved.single.origin.name, 'aiScaffolded');
  });

  testWidgets('AI unavailable shows the fallback options', (tester) async {
    container = build('', available: false);
    await pump(tester);
    await analyze(tester);

    expect(find.byKey(const Key('upload-fallback-picker')), findsOneWidget);
    await tester.tap(find.byKey(const Key('upload-fallback-picker')));
    await tester.pumpAndSettle();
    expect(find.text('picker-stub'), findsOneWidget);
  });
}
