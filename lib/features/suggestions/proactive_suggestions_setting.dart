import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/settings_store.dart';

/// Whether Mink may surface proactive suggestions (blueprint §5.5, PRD §5.2).
/// **Default on** (opt-out): the feature is non-intrusive (post-action, single
/// in-context card, dismissible, never a notification), and a one-time disclosure
/// precedes the first suggestion (see [proactiveSuggestionsDisclosureSeenProvider]),
/// honoring §15 #20. Persisted via [settingsStoreProvider] — a non-PII preference.
///
/// The default-on read uses `!= 'false'` so an absent key reads on while an
/// explicit opt-out still persists. Mirrors `KeepOriginalController`.
final proactiveSuggestionsProvider =
    NotifierProvider<ProactiveSuggestionsController, bool>(
      ProactiveSuggestionsController.new,
    );

class ProactiveSuggestionsController extends Notifier<bool> {
  static const settingsKey = 'proactive_suggestions_enabled';

  @override
  bool build() =>
      ref.read(settingsStoreProvider).getString(settingsKey) != 'false';

  void set(bool value) {
    state = value;
    ref.read(settingsStoreProvider).setString(settingsKey, value.toString());
  }
}

/// Whether the one-time "Mink can offer follow-up tips" disclosure has been shown
/// (on the first suggestion) — so we surface it once, not on every suggestion.
/// Mirrors `keepOriginalHintSeenProvider`.
final proactiveSuggestionsDisclosureSeenProvider =
    NotifierProvider<ProactiveSuggestionsDisclosureController, bool>(
      ProactiveSuggestionsDisclosureController.new,
    );

class ProactiveSuggestionsDisclosureController extends Notifier<bool> {
  static const settingsKey = 'seen_proactive_suggestions_disclosure';

  @override
  bool build() =>
      ref.read(settingsStoreProvider).getString(settingsKey) == 'true';

  void markSeen() {
    state = true;
    ref.read(settingsStoreProvider).setString(settingsKey, 'true');
  }
}
