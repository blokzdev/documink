import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/database_providers.dart';
import '../detection/detection_providers.dart';
import 'memory_guard.dart';
import 'memory_pii_scanner.dart';
import 'memory_repository.dart';
import 'memory_router.dart';

/// Scans would-be memory content for unreferenced PII using the shared
/// detection pipeline (memory.md §3.3).
final memoryPiiScannerProvider = Provider<MemoryPiiScanner>(
  (ref) => MemoryPiiScanner(ref.watch(detectionPipelineProvider)),
);

/// The PII-safe write guard every memory write must pass through.
final memoryWriteGuardProvider = Provider<MemoryWriteGuard>(
  (ref) => MemoryWriteGuard(ref.watch(memoryPiiScannerProvider)),
);

/// Core + Episodic memory access (writes guarded; requires the unlocked vault).
final memoryRepositoryProvider = Provider<MemoryRepository>(
  (ref) => MemoryRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(memoryWriteGuardProvider),
  ),
);

/// The deterministic router dispatching Mink's memory tool calls (memory.md §4).
final memoryRouterProvider = Provider<MemoryRouter>(
  (ref) => MemoryRouter(ref.watch(memoryRepositoryProvider)),
);
