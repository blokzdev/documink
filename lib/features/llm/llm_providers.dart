import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/database_providers.dart';
import 'device_capability_profiler.dart';
import 'device_signal_collector.dart';
import 'llm_backend.dart';
import 'manifest_verifier.dart';
import 'model_manifest.dart';
import 'profiler_repository.dart';
import 'profiler_service.dart';

/// Path to the bundled, Ed25519-signed model manifest (offline last-known-good;
/// production refreshes weekly from documink.ai, §6.4).
const String signedManifestAsset = 'assets/model_manifest/manifest.signed.json';

final manifestVerifierProvider = Provider<ManifestVerifier>(
  (ref) => ManifestVerifier(),
);

/// The on-device LLM text-generation backend (Tier 4). Defaults to the
/// fail-loud [UnavailableLlmBackend]; the real `flutter_gemma`/LiteRT adapter is
/// composed at bootstrap on supported devices (Phase 10b) and device-verified.
final llmBackendProvider = Provider<LlmBackend>(
  (ref) => const UnavailableLlmBackend(),
);

/// The verified model manifest. Throws if the bundled manifest fails Ed25519
/// verification — the app never acts on an unverified manifest (§4.7/§6.4).
final modelManifestProvider = FutureProvider<ModelManifest>((ref) async {
  final signed = await rootBundle.loadString(signedManifestAsset);
  return ref.read(manifestVerifierProvider).verifyAndParse(signed);
});

final deviceCapabilityProfilerProvider = Provider<DeviceCapabilityProfiler>(
  (ref) => const DeviceCapabilityProfiler(),
);

/// The platform device-signal collector. Overridden at app bootstrap (Phase 5)
/// with the Android/Windows native adapter; unimplemented in the bare core.
final deviceSignalCollectorProvider = Provider<DeviceSignalCollector>((ref) {
  throw UnimplementedError(
    'deviceSignalCollectorProvider must be overridden with a platform adapter',
  );
});

/// Persists the profiler outcome to `vault_meta` (requires the unlocked vault).
final profilerRepositoryProvider = Provider<ProfilerRepository>(
  (ref) => ProfilerRepository(ref.watch(appDatabaseProvider)),
);

final profilerServiceProvider = Provider<ProfilerService>(
  (ref) => ProfilerService(
    collector: ref.watch(deviceSignalCollectorProvider),
    repository: ref.watch(profilerRepositoryProvider),
    profiler: ref.watch(deviceCapabilityProfilerProvider),
  ),
);
