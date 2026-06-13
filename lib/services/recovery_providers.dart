import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'recovery_service.dart';

/// BIP-39 recovery-phrase codec for the Master Key (blueprint §8.4). Stateless.
final recoveryServiceProvider = Provider<RecoveryService>((ref) {
  return RecoveryService();
});
