import 'package:documink/features/documents/keep_original_setting.dart';
import 'package:documink/services/settings_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('defaults to off; set persists to the store', () {
    final store = InMemorySettingsStore();
    final c = ProviderContainer(
      overrides: [settingsStoreProvider.overrideWithValue(store)],
    );
    addTearDown(c.dispose);

    expect(c.read(keepOriginalProvider), isFalse);

    c.read(keepOriginalProvider.notifier).set(true);
    expect(c.read(keepOriginalProvider), isTrue);
    expect(store.getString('keep_encrypted_original'), 'true');
  });

  test('reads a persisted opt-in on build', () {
    final store = InMemorySettingsStore({'keep_encrypted_original': 'true'});
    final c = ProviderContainer(
      overrides: [settingsStoreProvider.overrideWithValue(store)],
    );
    addTearDown(c.dispose);

    expect(c.read(keepOriginalProvider), isTrue);
  });
}
