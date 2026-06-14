import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'device_capability_profiler.dart';
import 'manifest_verifier.dart';
import 'model_manifest.dart';

/// Path to the bundled, Ed25519-signed model manifest (offline last-known-good;
/// production refreshes weekly from documink.ai, §6.4).
const String signedManifestAsset = 'assets/model_manifest/manifest.signed.json';

final manifestVerifierProvider = Provider<ManifestVerifier>(
  (ref) => ManifestVerifier(),
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
