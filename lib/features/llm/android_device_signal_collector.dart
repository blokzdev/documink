import 'package:flutter/services.dart';

import 'device_capabilities.dart';
import 'device_signal_collector.dart';

/// Production [DeviceSignalCollector] for Android over a first-party
/// `MethodChannel` to `MainActivity` (no third-party plugin). Reads total RAM
/// (`ActivityManager.MemoryInfo.totalMem`), free internal storage (`StatFs`),
/// CPU cores (`Runtime.availableProcessors`), and the OS version; NPU/GPU/system
/// model are reported conservatively (none/0/absent) until refined on-device —
/// the profiler degrades safely (a lower tier) rather than over-promising.
///
/// **Device-only** — exercised on a real device, not by headless `flutter test`
/// (the profiler orchestration is fake-tested via [DeviceSignalCollector]). Wired
/// at bootstrap; channel handler lives in `MainActivity.kt`
/// (`documink/device_signals`).
class AndroidDeviceSignalCollector implements DeviceSignalCollector {
  const AndroidDeviceSignalCollector();

  static const _channel = MethodChannel('documink/device_signals');

  @override
  Future<DeviceCapabilities> collect() async {
    final raw = await _channel.invokeMapMethod<String, dynamic>('collect');
    final m = raw ?? const <String, dynamic>{};
    return DeviceCapabilities(
      ramBytes: _int(m['ramBytes']),
      freeStorageBytes: _int(m['freeStorageBytes']),
      cpuCores: _int(m['cpuCores'], fallback: 1),
      npuClass: NpuClass.none,
      gpuVramBytes: 0,
      systemModelId: null,
      formFactor: FormFactor.mobile,
      platformVersion: m['platformVersion'] == null
          ? null
          : _int(m['platformVersion']),
    );
  }

  static int _int(Object? v, {int fallback = 0}) =>
      v is int ? v : (v is num ? v.toInt() : fallback);
}
