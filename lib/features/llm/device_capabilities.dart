/// NPU class for the capability score (blueprint §4.7): 0=none … 3=flagship.
enum NpuClass {
  none(0),
  basic(1),
  strong(2),
  flagship(3);

  const NpuClass(this.score);

  /// The numeric weight used in [DeviceCapabilities.capabilityScore].
  final int score;
}

/// Device form factor — desktop earns a capability bonus and unlocks the
/// desktop-only "faster vs accurate" preference (§4.7).
enum FormFactor { mobile, desktop }

/// Locally collected device signals (blueprint §4.7). Stored canonically in
/// **bytes**; conversions use decimal units (1 GB = 1e9, 1 MB = 1e6) so the
/// scoring formula and the manifest's `size_bytes` / `min_ram_mb` share one
/// unit system. The native collectors (ActivityManager / GlobalMemoryStatusEx,
/// etc.) populate this; the scoring + selection logic here is pure Dart.
class DeviceCapabilities {
  const DeviceCapabilities({
    required this.ramBytes,
    required this.freeStorageBytes,
    required this.cpuCores,
    required this.npuClass,
    required this.gpuVramBytes,
    this.systemModelId,
    required this.formFactor,
    this.platformVersion,
  });

  final int ramBytes;
  final int freeStorageBytes;
  final int cpuCores;
  final NpuClass npuClass;
  final int gpuVramBytes;

  /// The system-provided model id (e.g. `gemini_nano`), or null if none.
  final String? systemModelId;
  final FormFactor formFactor;
  final int? platformVersion;

  static const double _bytesPerGb = 1e9;
  static const double _bytesPerMb = 1e6;

  bool get systemModelAvailable => systemModelId != null;

  double get _ramGb => ramBytes / _bytesPerGb;
  double get _freeStorageGb => freeStorageBytes / _bytesPerGb;
  double get _gpuVramGb => gpuVramBytes / _bytesPerGb;

  /// The numeric capability score (blueprint §4.7). Device-agnostic, no ceiling.
  double get capabilityScore =>
      (_ramGb * 10) +
      (_freeStorageGb * 2) +
      (cpuCores * 3) +
      (npuClass.score * 20) +
      (_gpuVramGb * 8) +
      (systemModelAvailable ? 50 : 0) +
      (formFactor == FormFactor.desktop ? 15 : 0);

  /// Whether the device satisfies a tier's hard `requires` gate (§4.7).
  bool meetsHardRequirements(TierRequirements requires) {
    if (requires.minRamMb != null &&
        ramBytes < requires.minRamMb! * _bytesPerMb) {
      return false;
    }
    if (requires.minStorageMb != null &&
        freeStorageBytes < requires.minStorageMb! * _bytesPerMb) {
      return false;
    }
    if (requires.systemModel != null && systemModelId != requires.systemModel) {
      return false;
    }
    return true;
  }
}

/// A tier's hard requirement gate (the manifest `requires` block, §4.7).
class TierRequirements {
  const TierRequirements({this.minRamMb, this.minStorageMb, this.systemModel});

  final int? minRamMb;
  final int? minStorageMb;
  final String? systemModel;

  static const TierRequirements none = TierRequirements();

  factory TierRequirements.fromJson(Map<String, dynamic> json) =>
      TierRequirements(
        minRamMb: json['min_ram_mb'] as int?,
        minStorageMb: json['min_storage_mb'] as int?,
        systemModel: json['system_model'] as String?,
      );
}
