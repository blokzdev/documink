import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/settings_store.dart';

/// User opt-in for retaining the **encrypted original** of a document (Phase 4c).
/// Off by default (privacy-first; avoids surprise storage growth). Persisted via
/// [settingsStoreProvider] — a non-PII preference, so the unencrypted settings
/// store is appropriate.
final keepOriginalProvider = NotifierProvider<KeepOriginalController, bool>(
  KeepOriginalController.new,
);

class KeepOriginalController extends Notifier<bool> {
  static const settingsKey = 'keep_encrypted_original';

  @override
  bool build() =>
      ref.read(settingsStoreProvider).getString(settingsKey) == 'true';

  void set(bool value) {
    state = value;
    ref.read(settingsStoreProvider).setString(settingsKey, value.toString());
  }
}
