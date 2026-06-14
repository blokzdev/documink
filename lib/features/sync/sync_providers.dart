import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'conflict_resolver.dart';

/// Detects §9.4 hard sync conflicts (surfaced in Settings → Sync Conflicts).
final syncConflictDetectorProvider = Provider<SyncConflictDetector>(
  (ref) => const SyncConflictDetector(),
);
