import 'package:documink/features/llm/device_capabilities.dart';
import 'package:documink/features/llm/device_capability_profiler.dart';
import 'package:documink/features/llm/tier_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

const int _gb = 1000000000; // decimal GB, matching manifest size_bytes
const int _mb = 1000000;

ModelVariant _variant(int sizeBytes) => ModelVariant(
  modelId: 'm$sizeBytes',
  runtime: 'litert_lm',
  sizeBytes: sizeBytes,
  licenseBundle: 'apache-2.0',
  sha256: 'deadbeef',
  url: 'https://documink.ai/models/m.task',
);

/// A representative catalog mirroring the §4.7 structure.
final TierCatalog _catalog = TierCatalog(
  version: 6,
  tiers: [
    CatalogTier(
      tier: 'minimum',
      minScore: 30,
      requires: const TierRequirements(minRamMb: 2048),
      optInOnly: false,
      variants: {VariantKind.balanced: _variant(250 * _mb)},
    ),
    CatalogTier(
      tier: 'standard',
      minScore: 60,
      requires: const TierRequirements(minRamMb: 4096),
      optInOnly: false,
      variants: {VariantKind.balanced: _variant(1200 * _mb)},
    ),
    CatalogTier(
      tier: 'performance',
      minScore: 90,
      requires: const TierRequirements(minRamMb: 6144),
      optInOnly: false,
      variants: {
        VariantKind.balanced: _variant(1800 * _mb),
        VariantKind.specialized: _variant(5 * _gb),
      },
    ),
    CatalogTier(
      tier: 'system_provided_android',
      minScore: 100,
      requires: const TierRequirements(systemModel: 'gemini_nano'),
      optInOnly: false,
      variants: {VariantKind.balanced: _variant(0)},
    ),
    CatalogTier(
      tier: 'ultra',
      minScore: 150,
      requires: TierRequirements.none,
      optInOnly: true,
      variants: {VariantKind.specialized: _variant(8 * _gb)},
    ),
  ],
);

void main() {
  const profiler = DeviceCapabilityProfiler();

  group('capabilityScore (§4.7 formula)', () {
    test('sums the weighted signals', () {
      const caps = DeviceCapabilities(
        ramBytes: 6 * _gb,
        freeStorageBytes: 10 * _gb,
        cpuCores: 8,
        npuClass: NpuClass.basic,
        gpuVramBytes: 0,
        formFactor: FormFactor.mobile,
      );
      // 6*10 + 10*2 + 8*3 + 1*20 + 0 + 0 + 0 = 124
      expect(caps.capabilityScore, 124);
    });

    test('system model (+50) and desktop (+15) bonuses apply', () {
      const caps = DeviceCapabilities(
        ramBytes: 0,
        freeStorageBytes: 0,
        cpuCores: 0,
        npuClass: NpuClass.none,
        gpuVramBytes: 0,
        systemModelId: 'gemini_nano',
        formFactor: FormFactor.desktop,
      );
      expect(caps.capabilityScore, 65);
    });
  });

  group('selectTier fixtures', () {
    test('floor device → none, insufficient score', () {
      const caps = DeviceCapabilities(
        ramBytes: 1500 * _mb,
        freeStorageBytes: 1 * _gb,
        cpuCores: 4,
        npuClass: NpuClass.none,
        gpuVramBytes: 0,
        formFactor: FormFactor.mobile,
      ); // score = 15 + 2 + 12 = 29 < 30
      final sel = profiler.selectTier(caps, _catalog);
      expect(sel.isFloor, isTrue);
      expect(sel.recommendedTier, noTier);
      expect(sel.floorReason, FloorReason.insufficientScore);
      expect(sel.deviceScore, 29);
    });

    test('minimum device → minimum tier, Balanced', () {
      const caps = DeviceCapabilities(
        ramBytes: 2500 * _mb,
        freeStorageBytes: 2 * _gb,
        cpuCores: 4,
        npuClass: NpuClass.none,
        gpuVramBytes: 0,
        formFactor: FormFactor.mobile,
      ); // score = 25 + 4 + 12 = 41
      final sel = profiler.selectTier(caps, _catalog);
      expect(sel.recommendedTier, 'minimum');
      expect(sel.recommendedVariant, VariantKind.balanced);
      expect(sel.optInAvailable, isEmpty);
    });

    test('mid/flagship device → performance tier', () {
      const caps = DeviceCapabilities(
        ramBytes: 8 * _gb,
        freeStorageBytes: 10 * _gb,
        cpuCores: 8,
        npuClass: NpuClass.basic,
        gpuVramBytes: 0,
        formFactor: FormFactor.mobile,
      ); // score = 80 + 20 + 24 + 20 = 144
      final sel = profiler.selectTier(caps, _catalog);
      expect(sel.recommendedTier, 'performance');
    });

    test('flagship + system model → system tier, ultra offered opt-in', () {
      const caps = DeviceCapabilities(
        ramBytes: 16 * _gb,
        freeStorageBytes: 100 * _gb,
        cpuCores: 8,
        npuClass: NpuClass.flagship,
        gpuVramBytes: 0,
        systemModelId: 'gemini_nano',
        formFactor: FormFactor.mobile,
      ); // score = 160 + 200 + 24 + 60 + 50 = 494
      final sel = profiler.selectTier(caps, _catalog);
      expect(sel.recommendedTier, 'system_provided_android');
      expect(sel.optInAvailable, ['ultra']);
    });

    test(
      'synthetic future device (no ceiling) → highest auto tier, graceful',
      () {
        const caps = DeviceCapabilities(
          ramBytes: 64 * _gb,
          freeStorageBytes: 1000 * _gb,
          cpuCores: 32,
          npuClass: NpuClass.flagship,
          gpuVramBytes: 24 * _gb,
          formFactor: FormFactor.desktop,
        ); // far beyond current tiers; no system model (desktop)
        final sel = profiler.selectTier(caps, _catalog);
        // system_provided needs gemini_nano (absent) → highest non-system auto.
        expect(sel.recommendedTier, 'performance');
        expect(sel.optInAvailable, ['ultra']);
        expect(sel.deviceScore, greaterThan(3000));
      },
    );

    test('high score but tiny storage → floor, insufficient storage', () {
      const caps = DeviceCapabilities(
        ramBytes: 8 * _gb,
        freeStorageBytes: 200 * _mb,
        cpuCores: 8,
        npuClass: NpuClass.none,
        gpuVramBytes: 0,
        formFactor: FormFactor.mobile,
      ); // score ~104 but 200MB can't fit any variant + 20% headroom
      final sel = profiler.selectTier(caps, _catalog);
      expect(sel.isFloor, isTrue);
      expect(sel.floorReason, FloorReason.insufficientStorage);
    });

    test('RAM gate: score met but min_ram_mb fails → not that tier', () {
      const caps = DeviceCapabilities(
        ramBytes: 3 * _gb, // < performance's 6144MB and standard's 4096MB
        freeStorageBytes: 50 * _gb,
        cpuCores: 16,
        npuClass: NpuClass.strong,
        gpuVramBytes: 0,
        formFactor: FormFactor.mobile,
      ); // score = 30 + 100 + 48 + 40 = 218, but only 3GB RAM
      final sel = profiler.selectTier(caps, _catalog);
      expect(sel.recommendedTier, 'minimum'); // only minimum's 2048MB gate met
    });
  });
}
