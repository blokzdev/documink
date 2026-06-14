import 'package:documink/features/projects/active_project_provider.dart';
import 'package:documink/services/settings_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('persists the active project id across containers (restart)', () {
    final store = InMemorySettingsStore();

    ProviderContainer freshContainer() {
      final c = ProviderContainer(
        overrides: [settingsStoreProvider.overrideWithValue(store)],
      );
      addTearDown(c.dispose);
      return c;
    }

    // Fresh install: nothing selected.
    expect(freshContainer().read(activeProjectProvider), isNull);

    // Select a project — it is written through to the store.
    final c1 = freshContainer();
    c1.read(activeProjectProvider.notifier).set('p_123');
    expect(c1.read(activeProjectProvider), 'p_123');

    // A new container (≈ app restart) rehydrates the selection.
    expect(freshContainer().read(activeProjectProvider), 'p_123');

    // Clearing returns to the global view, and that persists too.
    final c2 = freshContainer();
    c2.read(activeProjectProvider.notifier).clear();
    expect(c2.read(activeProjectProvider), isNull);
    expect(freshContainer().read(activeProjectProvider), isNull);
  });
}
