import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../detection/detection_providers.dart';
import 'memory_guard.dart';
import 'memory_pii_scanner.dart';

/// Scans would-be memory content for unreferenced PII using the shared
/// detection pipeline (memory.md §3.3).
final memoryPiiScannerProvider = Provider<MemoryPiiScanner>(
  (ref) => MemoryPiiScanner(ref.watch(detectionPipelineProvider)),
);

/// The PII-safe write guard every memory write must pass through.
final memoryWriteGuardProvider = Provider<MemoryWriteGuard>(
  (ref) => MemoryWriteGuard(ref.watch(memoryPiiScannerProvider)),
);
