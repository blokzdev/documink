import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Persists **non-sensitive** app preferences (e.g. theme mode). Never store PII
/// here (privacy-invariants.md) — sensitive state lives in the encrypted vault.
///
/// The concrete platform store (`shared_preferences`) is wired at bootstrap; an
/// [InMemorySettingsStore] is the default so headless tests and pre-bootstrap
/// reads work without platform channels.
abstract interface class SettingsStore {
  String? getString(String key);
  Future<void> setString(String key, String value);
}

class InMemorySettingsStore implements SettingsStore {
  InMemorySettingsStore([Map<String, String>? seed]) : _values = {...?seed};

  final Map<String, String> _values;

  @override
  String? getString(String key) => _values[key];

  @override
  Future<void> setString(String key, String value) async =>
      _values[key] = value;
}

/// The app's settings store. Overridden at bootstrap with the persistent
/// implementation; defaults to in-memory (tests / pre-bootstrap).
final settingsStoreProvider = Provider<SettingsStore>(
  (ref) => InMemorySettingsStore(),
);
