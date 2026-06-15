import 'package:documink/features/suggestions/proactive_suggestions_setting.dart';
import 'package:documink/services/settings_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ProviderContainer containerWith(InMemorySettingsStore store) {
    final c = ProviderContainer(
      overrides: [settingsStoreProvider.overrideWithValue(store)],
    );
    addTearDown(c.dispose);
    return c;
  }

  group('proactiveSuggestionsProvider (default on / opt-out)', () {
    test('defaults to on when the key is absent', () {
      final c = containerWith(InMemorySettingsStore());
      expect(c.read(proactiveSuggestionsProvider), isTrue);
    });

    test('an explicit opt-out persists and is read back', () {
      final store = InMemorySettingsStore();
      final c = containerWith(store);

      c.read(proactiveSuggestionsProvider.notifier).set(false);
      expect(c.read(proactiveSuggestionsProvider), isFalse);
      expect(store.getString('proactive_suggestions_enabled'), 'false');
    });

    test('reads a persisted opt-out on build', () {
      final store = InMemorySettingsStore({
        'proactive_suggestions_enabled': 'false',
      });
      expect(containerWith(store).read(proactiveSuggestionsProvider), isFalse);
    });

    test('re-enabling persists true', () {
      final store = InMemorySettingsStore({
        'proactive_suggestions_enabled': 'false',
      });
      final c = containerWith(store);

      c.read(proactiveSuggestionsProvider.notifier).set(true);
      expect(c.read(proactiveSuggestionsProvider), isTrue);
      expect(store.getString('proactive_suggestions_enabled'), 'true');
    });
  });

  group('proactiveSuggestionsDisclosureSeenProvider', () {
    test('defaults to not-seen; markSeen persists', () {
      final store = InMemorySettingsStore();
      final c = containerWith(store);

      expect(c.read(proactiveSuggestionsDisclosureSeenProvider), isFalse);

      c.read(proactiveSuggestionsDisclosureSeenProvider.notifier).markSeen();
      expect(c.read(proactiveSuggestionsDisclosureSeenProvider), isTrue);
      expect(store.getString('seen_proactive_suggestions_disclosure'), 'true');
    });

    test('reads a persisted seen flag on build', () {
      final store = InMemorySettingsStore({
        'seen_proactive_suggestions_disclosure': 'true',
      });
      expect(
        containerWith(store).read(proactiveSuggestionsDisclosureSeenProvider),
        isTrue,
      );
    });
  });
}
