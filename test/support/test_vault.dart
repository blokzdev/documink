import 'dart:async';
import 'dart:io';

import 'package:documink/services/key_service.dart';
import 'package:documink/services/secure_key_store.dart';
import 'package:documink/services/vault_providers.dart';
import 'package:documink/services/vault_service.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// In-memory [SecureKeyStore] for headless tests (no platform channels).
class FakeSecureKeyStore implements SecureKeyStore {
  final _values = <String, String>{};

  @override
  Future<String?> read(String key) async => _values[key];
  @override
  Future<void> write(String key, String value) async => _values[key] = value;
  @override
  Future<void> delete(String key) async => _values.remove(key);
  @override
  Future<bool> containsKey(String key) async => _values.containsKey(key);
}

/// No-op timer so the vault's auto-lock countdown leaves no pending real timer.
class _FakeTimer implements Timer {
  @override
  void cancel() {}
  @override
  bool get isActive => false;
  @override
  int get tick => 0;
}

/// A real [VaultService] backed by an in-memory key store + plain (unencrypted)
/// executor — the Phase-1c test seam — so widget/unit tests can exercise the
/// full vault-backed path headlessly without the SQLCipher native build.
class TestVault {
  TestVault._(this.service, this._tempDir);

  final VaultService service;
  final Directory _tempDir;

  /// Builds and **unlocks** a fresh vault. The returned [override] injects it as
  /// [vaultServiceProvider]; the owning [ProviderContainer] disposes the service.
  static Future<TestVault> unlocked({
    String passphrase = 'test-passphrase',
  }) async {
    final dir = Directory.systemTemp.createTempSync('dm_test_vault');
    final service = VaultService(
      keyService: KeyService(FakeSecureKeyStore()),
      vaultFile: File('${dir.path}/vault.db'),
      openExecutor: (file, _) => NativeDatabase(file),
      timerFactory: (_, __) => _FakeTimer(),
    );
    await service.initialize(passphrase);
    return TestVault._(service, dir);
  }

  Override get override => vaultServiceProvider.overrideWith((ref) => service);

  /// Cleans up the temp directory. The service itself is disposed by the
  /// container that owns the override.
  void dispose() {
    if (_tempDir.existsSync()) _tempDir.deleteSync(recursive: true);
  }
}
