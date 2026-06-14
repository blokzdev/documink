import 'device_capabilities.dart';

/// Collects local device signals for the capability profiler (blueprint §4.7
/// signals table). The concrete Android (`ActivityManager`, `StatFs`, …) and
/// Windows (`GlobalMemoryStatusEx`, DXGI, …) collectors are platform adapters
/// wired at app bootstrap (Phase 5); the scoring/selection logic consumes this
/// interface so it stays pure and testable.
abstract class DeviceSignalCollector {
  Future<DeviceCapabilities> collect();
}
