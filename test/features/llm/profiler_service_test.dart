import 'dart:io';

import 'package:documink/data/app_database.dart';
import 'package:documink/features/llm/device_capabilities.dart';
import 'package:documink/features/llm/device_signal_collector.dart';
import 'package:documink/features/llm/manifest_verifier.dart';
import 'package:documink/features/llm/model_manifest.dart';
import 'package:documink/features/llm/profiler_repository.dart';
import 'package:documink/features/llm/profiler_service.dart';
import 'package:documink/features/llm/profiler_state.dart';
import 'package:documink/features/llm/tier_catalog.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeCollector implements DeviceSignalCollector {
  _FakeCollector(this.caps);
  final DeviceCapabilities caps;
  @override
  Future<DeviceCapabilities> collect() async => caps;
}

const int _gb = 1000000000;

void main() {
  late AppDatabase db;
  late ProfilerRepository repo;
  late ModelManifest manifest;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = ProfilerRepository(db);
    final signed = File(
      'assets/model_manifest/manifest.signed.json',
    ).readAsStringSync();
    manifest = await ManifestVerifier().verifyAndParse(signed);
  });

  tearDown(() async => db.close());

  test('ProfilerRepository round-trips state through vault_meta', () async {
    expect(await repo.load(), isNull);
    const state = ProfilerState(
      tier: 'performance',
      variant: VariantKind.balanced,
      modelId: 'gemma-4-e4b-int4',
      manifestVersion: 1,
      downloadState: DownloadState.ready,
      score: 144,
      ranAtEpochMs: 1718000000000,
      optInAvailable: ['professional'],
      userPreference: UserPreference.accurate,
      optInTierEnabled: true,
    );
    await repo.save(state);
    final loaded = await repo.load();
    expect(loaded!.tier, 'performance');
    expect(loaded.modelId, 'gemma-4-e4b-int4');
    expect(loaded.downloadState, DownloadState.ready);
    expect(loaded.score, 144);
    expect(loaded.optInAvailable, ['professional']);
    expect(loaded.userPreference, UserPreference.accurate);
    expect(loaded.optInTierEnabled, isTrue);
  });

  test(
    'runProfile selects against the verified manifest and persists',
    () async {
      final service = ProfilerService(
        collector: _FakeCollector(
          const DeviceCapabilities(
            ramBytes: 8 * _gb,
            freeStorageBytes: 20 * _gb,
            cpuCores: 8,
            npuClass: NpuClass.strong,
            gpuVramBytes: 0,
            formFactor: FormFactor.mobile,
          ),
        ),
        repository: repo,
      );
      final state = await service.runProfile(
        manifest,
        now: DateTime.fromMillisecondsSinceEpoch(1718000000000),
      );
      expect(state.tier, 'performance');
      expect(state.modelId, 'gemma-4-e4b-int4'); // balanced variant
      expect(state.manifestVersion, 1);
      expect(state.downloadState, DownloadState.notDownloaded);
      expect(state.ranAtEpochMs, 1718000000000);
      // Persisted.
      expect((await repo.load())!.tier, 'performance');
    },
  );

  test('runProfile at the floor persists none + a floor reason', () async {
    final service = ProfilerService(
      collector: _FakeCollector(
        const DeviceCapabilities(
          ramBytes: 1 * _gb,
          freeStorageBytes: 300000000,
          cpuCores: 2,
          npuClass: NpuClass.none,
          gpuVramBytes: 0,
          formFactor: FormFactor.mobile,
        ),
      ),
      repository: repo,
    );
    final state = await service.runProfile(manifest);
    expect(state.isFloor, isTrue);
    expect(state.modelId, isNull);
    expect(state.floorReason, isNotNull);
    expect((await repo.load())!.isFloor, isTrue);
  });
}
