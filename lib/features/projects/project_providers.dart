import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tool_permission_registry.dart';

/// Decides whether a Mink tool call is permitted under a Project manifest
/// (blueprint §5/§6.7).
final toolPermissionRegistryProvider = Provider<ToolPermissionRegistry>(
  (ref) => const ToolPermissionRegistry(),
);
