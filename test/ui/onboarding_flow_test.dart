import 'package:documink/core/router.dart';
import 'package:documink/data/app_database.dart';
import 'package:documink/features/llm/device_capability_profiler.dart'
    show FloorReason, noTier;
import 'package:documink/features/llm/llm_providers.dart';
import 'package:documink/features/llm/model_manifest.dart';
import 'package:documink/features/llm/profiler_repository.dart';
import 'package:documink/features/llm/profiler_state.dart';
import 'package:documink/features/llm/tier_catalog.dart';
import 'package:documink/l10n/gen/app_localizations.dart';
import 'package:documink/services/vault_providers.dart';
import 'package:documink/ui/screens/home_screen.dart';
import 'package:documink/ui/screens/onboarding_ai_screen.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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
  FloorReason? floorReason,
}) => ProfilerState(
  tier: tier,
  variant: VariantKind.balanced,
  modelId: modelId,
  manifestVersion: 1,
  downloadState: DownloadState.notDownloaded,
  score: 72,
  ranAtEpochMs: 0,
  optInAvailable: const [],
  floorReason: floorReason,
);

/// Pumps the real app router with the vault "unlocked", a seeded profiler state,
/// and the onboarding flag set per [owed].
Future<ProviderContainer> _pump(
  WidgetTester tester, {
  required bool owed,
  ProfilerState? seed,
}) async {
  final db = AppDatabase(NativeDatabase.memory());
  addTearDown(db.close);
  final repo = ProfilerRepository(db);
  if (seed != null) await repo.save(seed);

  final container = ProviderContainer(
    overrides: [
      appUnlockedProvider.overrideWithValue(true),
      modelManifestProvider.overrideWith((ref) async => _manifest()),
      profilerRepositoryProvider.overrideWithValue(repo),
    ],
  );
  addTearDown(container.dispose);
  if (owed) container.read(aiOnboardingProvider.notifier).require();

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: container.read(routerProvider),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets('onboarding owed + qualifying → Meet Mink with Accept/Skip', (
    tester,
  ) async {
    await _pump(tester, owed: true, seed: _state());
    expect(find.byType(OnboardingAiScreen), findsOneWidget);
    expect(find.text('Meet Mink'), findsOneWidget);
    expect(find.byKey(const Key('onboarding-accept')), findsOneWidget);
    expect(find.byKey(const Key('onboarding-skip')), findsOneWidget);
    expect(find.byKey(const Key('onboarding-options')), findsOneWidget);
  });

  testWidgets('Show options reveals the variant choices', (tester) async {
    await _pump(tester, owed: true, seed: _state());
    await tester.tap(find.byKey(const Key('onboarding-options')));
    await tester.pumpAndSettle();
    // Balanced + Specialized radios for the standard tier.
    expect(find.byType(RadioListTile<String>), findsNWidgets(2));
  });

  testWidgets('onboarding owed + floor → reason + Continue, no Accept', (
    tester,
  ) async {
    await _pump(
      tester,
      owed: true,
      seed: _state(
        tier: noTier,
        modelId: null,
        floorReason: FloorReason.insufficientRam,
      ),
    );
    expect(find.byType(OnboardingAiScreen), findsOneWidget);
    expect(find.byKey(const Key('onboarding-continue')), findsOneWidget);
    expect(find.byKey(const Key('onboarding-accept')), findsNothing);
  });

  testWidgets('Skip clears the flag and routes to Home', (tester) async {
    final container = await _pump(tester, owed: true, seed: _state());
    await tester.tap(find.byKey(const Key('onboarding-skip')));
    await tester.pumpAndSettle();
    expect(container.read(aiOnboardingProvider), isFalse);
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('not owed → Home (gate lets through)', (tester) async {
    await _pump(tester, owed: false, seed: _state());
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(OnboardingAiScreen), findsNothing);
  });
}
