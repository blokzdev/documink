import 'dart:async';
import 'dart:io';

import 'package:documink/core/bootstrap.dart';
import 'package:documink/core/flavors/flavor.dart';
import 'package:documink/services/key_service.dart';
import 'package:documink/services/secure_key_store.dart';
import 'package:documink/services/vault_providers.dart';
import 'package:documink/services/vault_service.dart';
import 'package:documink/ui/screens/vault_unlock_screen.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeSecureKeyStore implements SecureKeyStore {
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

/// A no-op timer so the vault's auto-lock countdown doesn't leave a real pending
/// timer in the widget test.
class _FakeTimer implements Timer {
  @override
  void cancel() {}
  @override
  bool get isActive => false;
  @override
  int get tick => 0;
}

void main() {
  late Directory tempDir;
  late File vaultFile;
  late _FakeSecureKeyStore store;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('dm_unlock_test');
    vaultFile = File('${tempDir.path}/vault.db');
    store = _FakeSecureKeyStore();
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  VaultService newService() => VaultService(
    keyService: KeyService(store),
    vaultFile: vaultFile,
    openExecutor: (file, _) => NativeDatabase(file),
    timerFactory: (_, __) => _FakeTimer(),
  );

  ProviderContainer container({List<Override> extra = const []}) {
    final c = ProviderContainer(
      overrides: [
        vaultServiceProvider.overrideWith((ref) => newService()),
        ...extra,
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  Future<void> pumpScreen(WidgetTester tester, ProviderContainer c) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(home: VaultUnlockScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('first run creates the vault and unlocks', (tester) async {
    final c = container();
    await pumpScreen(tester, c);

    expect(find.text('Create your vault'), findsOneWidget);
    await tester.enterText(find.byType(TextField).at(0), 'correct horse');
    await tester.enterText(find.byType(TextField).at(1), 'correct horse');
    await tester.tap(find.text('Create vault'));
    await tester.pumpAndSettle();

    expect(c.read(appUnlockedProvider), isTrue);
  });

  testWidgets('rejects mismatched passphrases', (tester) async {
    final c = container();
    await pumpScreen(tester, c);

    await tester.enterText(find.byType(TextField).at(0), 'aaaaaaaa');
    await tester.enterText(find.byType(TextField).at(1), 'bbbbbbbb');
    await tester.tap(find.text('Create vault'));
    await tester.pump();

    expect(find.text('Passphrases do not match.'), findsOneWidget);
    expect(c.read(appUnlockedProvider), isFalse);
  });

  testWidgets('existing vault: wrong passphrase rejected, right one unlocks', (
    tester,
  ) async {
    final init = newService();
    addTearDown(init.dispose);
    await init.initialize('correct horse');
    await init.lock();

    final c = container();
    await pumpScreen(tester, c);
    expect(find.text('Unlock DocuMink'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), 'wrong pass');
    await tester.tap(find.text('Unlock'));
    await tester.pumpAndSettle();
    expect(find.text('Incorrect passphrase.'), findsOneWidget);
    expect(c.read(appUnlockedProvider), isFalse);

    await tester.enterText(find.byType(TextField).at(0), 'correct horse');
    await tester.tap(find.text('Unlock'));
    await tester.pumpAndSettle();
    expect(c.read(appUnlockedProvider), isTrue);
  });

  testWidgets('locked app redirects to the unlock screen', (tester) async {
    final c = container(
      extra: [
        currentFlavorProvider.overrideWithValue(Flavor.dev),
        appUnlockedProvider.overrideWithValue(false),
      ],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(container: c, child: const DocuMinkApp()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Create your vault'), findsOneWidget);
  });
}
