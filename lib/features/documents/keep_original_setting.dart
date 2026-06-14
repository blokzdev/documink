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

/// Whether the one-time, in-context "keep the original?" hint has been shown and
/// acted on/dismissed — so we nudge the opt-in once, not repeatedly.
final keepOriginalHintSeenProvider =
    NotifierProvider<KeepOriginalHintController, bool>(
      KeepOriginalHintController.new,
    );

class KeepOriginalHintController extends Notifier<bool> {
  static const settingsKey = 'seen_keep_original_hint';

  @override
  bool build() =>
      ref.read(settingsStoreProvider).getString(settingsKey) == 'true';

  void markSeen() {
    state = true;
    ref.read(settingsStoreProvider).setString(settingsKey, 'true');
  }
}
