import 'package:documink/data/app_database.dart';
import 'package:documink/features/llm/device_capability_profiler.dart'
    show FloorReason, noTier;
import 'package:documink/features/llm/llm_backend.dart';
import 'package:documink/features/llm/llm_providers.dart';
import 'package:documink/features/llm/model_manifest.dart';
import 'package:documink/features/llm/profiler_repository.dart';
import 'package:documink/features/llm/profiler_state.dart';
import 'package:documink/features/llm/tier_catalog.dart';
import 'package:documink/l10n/gen/app_localizations.dart';
import 'package:documink/ui/screens/ai_settings_screen.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeBackend implements LlmBackend {
  @override
  Future<bool> isAvailable() async => true;
  @override
  Future<String> generate(String prompt, {int maxOutputTokens = 512}) async =>
      'hi';
}

ModelManifest _manifest() => ModelManifest.fromJson({
  'version': 1,
  'tiers': [
    {
      'tier': 'standard',
      'min_score': 55,
      'requires': {'min_ram_mb': 4096},
      'variants': {
        'balanced': {
          'model_id': 'gemma-std-bal',
          'runtime': 'litert_lm',
          'size_bytes': 1200000000,
          'sha256': 'a',
          'url': 'https://e/std-bal',
          'license_bundle': 'apache-2.0',
        },
        'specialized': {
          'model_id': 'gemma-std-spec',
          'runtime': 'litert_lm',
          'size_bytes': 1300000000,
          'sha256': 'b',
          'url': 'https://e/std-spec',
          'license_bundle': 'apache-2.0',
          'benefit_label': 'Sharper',
        },
      },
    },
  ],
  'detection_models': <dynamic>[],
});

ProfilerState _state({
  String tier = 'standard',
  String? modelId = 'gemma-std-bal',
  DownloadState downloadState = DownloadState.notDownloaded,
  FloorReason? floorReason,
}) => ProfilerState(
  tier: tier,
  variant: VariantKind.balanced,
  modelId: modelId,
  manifestVersion: 1,
  downloadState: downloadState,
  score: 72,
  ranAtEpochMs: 0,
  optInAvailable: const [],
  floorReason: floorReason,
);

Future<ProviderContainer> _pump(
  WidgetTester tester, {
  ProfilerState? seed,
  bool active = false,
}) async {
  final db = AppDatabase(NativeDatabase.memory());
  addTearDown(db.close);
  final repo = ProfilerRepository(db);
  if (seed != null) await repo.save(seed);

  final container = ProviderContainer(
    overrides: [
      modelManifestProvider.overrideWith((ref) async => _manifest()),
      profilerRepositoryProvider.overrideWithValue(repo),
    ],
  );
  addTearDown(container.dispose);
  if (active) {
    container.read(activeLlmBackendProvider.notifier).set(_FakeBackend());
  }

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: AiSettingsScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets('not profiled → shows Check my device', (tester) async {
    await _pump(tester);
    expect(find.byKey(const Key('ai-recheck')), findsOneWidget);
    expect(find.text('Check my device'), findsOneWidget);
    expect(find.byKey(const Key('ai-enable')), findsNothing);
  });

  testWidgets('floor → shows the floor explanation + re-check', (tester) async {
    await _pump(
      tester,
      seed: _state(
        tier: noTier,
        modelId: null,
        floorReason: FloorReason.insufficientRam,
      ),
    );
    expect(find.text("On-device AI isn't available here"), findsOneWidget);
    expect(find.byKey(const Key('ai-recheck')), findsOneWidget);
    expect(find.byKey(const Key('ai-enable')), findsNothing);
  });

  testWidgets('recommended (not downloaded) → shows Enable', (tester) async {
    await _pump(tester, seed: _state());
    expect(find.byKey(const Key('ai-enable')), findsOneWidget);
    expect(find.text('Recommended for your device'), findsOneWidget);
    expect(find.text('gemma-std-bal'), findsOneWidget);
    expect(find.byKey(const Key('ai-remove')), findsNothing);
  });

  testWidgets('ready + active → shows manage controls + prompt tester', (
    tester,
  ) async {
    await _pump(
      tester,
      seed: _state(downloadState: DownloadState.ready),
      active: true,
    );
    expect(find.byKey(const Key('ai-variant-toggle')), findsOneWidget);
    expect(find.byKey(const Key('ai-remove')), findsOneWidget);
    expect(find.byKey(const Key('ai-enable')), findsNothing);
    // The prompt tester sits at the bottom of the lazy ListView.
    await tester.scrollUntilVisible(
      find.byKey(const Key('ai-run')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.byKey(const Key('ai-prompt')), findsOneWidget);
    expect(find.byKey(const Key('ai-run')), findsOneWidget);
  });
}
