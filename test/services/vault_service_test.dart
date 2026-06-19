import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:documink/data/app_database.dart';
import 'package:documink/data/tokens_dao.dart';
import 'package:documink/services/key_service.dart';
import 'package:documink/services/salt_store.dart';
import 'package:documink/services/vault_service.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// VaultService + token-crypto tests for V1 Phase 1c (blueprint §8.2, §3.1
/// tokens). The lock/unlock state machine and token crypto are exercised with a
/// plain file-backed executor (persists across unlocks, no native encryption
/// needed); a gated test covers the real SQLCipher open where the encrypted
/// build is linked.
void main() {
  late Directory tempDir;
  late File vaultFile;
  late File saltFile;
  late KeyService keyService;
  late _FakeScheduler scheduler;
  final List<VaultService> services = [];

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('documink_vault_test');
    vaultFile = File('${tempDir.path}/vault.db');
    saltFile = File('${tempDir.path}/vault.salt');
    keyService = KeyService(FileSaltStore(saltFile));
    scheduler = _FakeScheduler();
  });

  tearDown(() async {
    for (final s in services) {
      s.dispose();
    }
    services.clear();
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  /// Builds a VaultService backed by a plain (unencrypted) file executor so the
  /// state machine + DEK handling are testable without the SQLCipher build.
  VaultService buildService({
    Duration autoLock = const Duration(seconds: 120),
  }) {
    final service = VaultService(
      keyService: keyService,
      vaultFile: vaultFile,
      openExecutor: (file, _) => NativeDatabase(file),
      autoLockAfter: autoLock,
      timerFactory: scheduler.arm,
    );
    services.add(service);
    return service;
  }

  Uint8List bytes(int length, int fill) =>
      Uint8List.fromList(List.filled(length, fill));

  group('TokenCrypto (pure)', () {
    final crypto = TokenCrypto(
      dek: bytes(32, 0x11),
      fingerprintHmacKey: bytes(32, 0x22),
    );

    test(
      'encrypt → decrypt round-trips under the matching token value',
      () async {
        const plaintext = 'alice@example.com';
        final blob = await crypto.encrypt(plaintext, tokenValue: '[EMAIL_1]');
        expect(await crypto.decrypt(blob, tokenValue: '[EMAIL_1]'), plaintext);
      },
    );

    test('decrypt rejects a mismatched token value (AAD binding)', () async {
      final blob = await crypto.encrypt(
        'alice@example.com',
        tokenValue: '[EMAIL_1]',
      );
      expect(
        () => crypto.decrypt(blob, tokenValue: '[EMAIL_2]'),
        throwsA(isA<SecretBoxAuthenticationError>()),
      );
    });

    test('fingerprint is deterministic and input-sensitive', () async {
      final a1 = await crypto.fingerprint('alice@example.com');
      final a2 = await crypto.fingerprint('alice@example.com');
      final b = await crypto.fingerprint('bob@example.com');
      expect(a1, a2);
      expect(a1.length, 32);
      expect(a1, isNot(b));
    });
  });

  group('VaultService lifecycle', () {
    test('initialize opens the vault and exposes db + token crypto', () async {
      final vault = buildService();
      expect(vault.state.status, VaultStatus.locked);
      await vault.initialize('correct horse');
      expect(vault.state.isUnlocked, isTrue);
      expect(vault.database, isA<AppDatabase>());
      expect(vault.tokenCrypto, isA<TokenCrypto>());
    });

    test('lock closes the vault and blocks access', () async {
      final vault = buildService();
      await vault.initialize('correct horse');
      await vault.lock();
      expect(vault.state.status, VaultStatus.locked);
      expect(() => vault.database, throwsStateError);
      expect(() => vault.tokenCrypto, throwsStateError);
    });

    test(
      'initialize → lock → unlock re-opens with the right passphrase',
      () async {
        final vault = buildService();
        await vault.initialize('correct horse');
        await vault.lock();
        await vault.unlock('correct horse');
        expect(vault.state.isUnlocked, isTrue);
      },
    );

    test('unlock with the wrong passphrase fails and stays locked', () async {
      final vault = buildService();
      await vault.initialize('correct horse');
      await vault.lock();
      await expectLater(
        vault.unlock('battery staple'),
        throwsA(isA<SecretBoxAuthenticationError>()),
      );
      expect(vault.state.status, VaultStatus.locked);
      expect(() => vault.database, throwsStateError);
    });

    test('initialize refuses to run twice', () async {
      final vault = buildService();
      await vault.initialize('correct horse');
      await expectLater(vault.initialize('again'), throwsStateError);
    });

    test('auto-lock timer locks the vault when it fires', () async {
      final vault = buildService();
      await vault.initialize('correct horse');
      expect(scheduler.armCount, 1);
      await scheduler.fire();
      expect(vault.state.status, VaultStatus.locked);
      expect(() => vault.database, throwsStateError);
    });

    test('failed initialize rolls back salt + db (atomic create)', () async {
      // A service whose executor throws when opening the DB: salt is written
      // first, then the open fails — the rollback must wipe both.
      final service = VaultService(
        keyService: keyService,
        vaultFile: vaultFile,
        openExecutor: (_, __) => throw const FileSystemException('boom'),
        timerFactory: scheduler.arm,
      );
      services.add(service);

      await expectLater(service.initialize('correct horse'), throwsA(anything));

      expect(await keyService.hasSalt(), isFalse, reason: 'salt rolled back');
      expect(saltFile.existsSync(), isFalse);
      expect(
        await service.vaultExists(),
        isFalse,
        reason: 'clean create state',
      );
    });

    test('vaultExists self-heals a half-created vault (salt, no db)', () async {
      // Simulate a crash after the salt was written but before the DB existed.
      await keyService.loadOrCreateSalt();
      expect(await keyService.hasSalt(), isTrue);
      expect(vaultFile.existsSync(), isFalse);

      final vault = buildService();
      expect(
        await vault.vaultExists(),
        isFalse,
        reason: 'inconsistent ⇒ false',
      );
      expect(
        await keyService.hasSalt(),
        isFalse,
        reason: 'stray salt cleaned so next run is a fresh create',
      );
    });

    test('reset erases the vault and returns to create mode', () async {
      final vault = buildService();
      await vault.initialize('correct horse');
      expect(await vault.vaultExists(), isTrue);

      await vault.reset();

      expect(vault.state.status, VaultStatus.locked);
      expect(await vault.vaultExists(), isFalse);
      expect(await keyService.hasSalt(), isFalse);
      expect(vaultFile.existsSync(), isFalse);
      // A fresh create works after reset.
      await vault.initialize('new passphrase');
      expect(vault.state.isUnlocked, isTrue);
    });

    test('touch re-arms the auto-lock timer while unlocked', () async {
      final vault = buildService();
      await vault.initialize('correct horse');
      expect(scheduler.armCount, 1);
      vault.touch();
      expect(scheduler.armCount, 2);
    });
  });

  group('TokensRepository (encrypted token at rest)', () {
    test('store → findByFingerprint → revealPlaintext round-trips', () async {
      final vault = buildService();
      await vault.initialize('correct horse');
      final db = vault.database;
      await _seedFixture(db);

      final repo = TokensRepository(db, vault.tokenCrypto);
      const plaintext = 'alice@example.com';
      await repo.store(
        id: 'tok1',
        workspaceId: 'ws1',
        entityId: 'ent1',
        tokenValue: '[EMAIL_1]',
        plaintext: plaintext,
        createdAt: 0,
      );

      final fingerprint = await vault.tokenCrypto.fingerprint(plaintext);
      final found = await repo.findByFingerprint('ws1', fingerprint);
      expect(found, isNotNull);
      expect(await repo.revealPlaintext(found!), plaintext);

      // The stored ciphertext is not the plaintext bytes.
      expect(found.ciphertext, isNot(Uint8List.fromList(plaintext.codeUnits)));

      final miss = await repo.findByFingerprint(
        'ws1',
        await vault.tokenCrypto.fingerprint('bob@example.com'),
      );
      expect(miss, isNull);
    });
  });

  group('SQLCipher integration (gated)', () {
    test('real encrypted vault initializes and unlocks', () async {
      final encFile = File('${tempDir.path}/enc.db');
      final vault = VaultService(
        keyService: keyService,
        vaultFile: encFile,
        // default openExecutor = openEncryptedExecutor (real SQLCipher)
        timerFactory: scheduler.arm,
      );
      services.add(vault);
      try {
        await vault.initialize('correct horse');
      } on Object catch (e) {
        markTestSkipped('Encrypted SQLite build not linked here: $e');
        return;
      }
      expect(vault.state.isUnlocked, isTrue);
      await vault.lock();

      final reopened = VaultService(
        keyService: keyService,
        vaultFile: encFile,
        timerFactory: scheduler.arm,
      );
      services.add(reopened);
      await reopened.unlock('correct horse');
      expect(reopened.state.isUnlocked, isTrue);
    });
  });
}

/// Inserts the workspace → document → entity rows a token row depends on (FK on).
Future<void> _seedFixture(AppDatabase db) async {
  await db
      .into(db.workspaces)
      .insert(
        WorkspacesCompanion.insert(
          id: 'ws1',
          name: 'Workspace',
          createdAt: 0,
          kekVersion: 1,
        ),
      );
  await db
      .into(db.documents)
      .insert(
        DocumentsCompanion.insert(
          id: 'doc1',
          workspaceId: 'ws1',
          name: 'Doc',
          type: 'text',
          sourceHash: Uint8List.fromList([1, 2, 3]),
          createdAt: 0,
          updatedAt: 0,
          status: 'draft',
        ),
      );
  await db
      .into(db.entities)
      .insert(
        EntitiesCompanion.insert(
          id: 'ent1',
          workspaceId: 'ws1',
          documentId: 'doc1',
          entityType: 'EMAIL',
          detector: 'regex',
          spanStart: 0,
          spanEnd: 17,
          confidence: 1,
          operatorApplied: 'mask',
          createdAt: 0,
        ),
      );
}

/// Captures the auto-lock callback so tests fire it deterministically; returns a
/// no-op [Timer] so no real timer is left pending.
class _FakeScheduler {
  int armCount = 0;
  void Function()? _callback;

  Timer arm(Duration duration, void Function() onFire) {
    armCount++;
    _callback = onFire;
    return _FakeTimer();
  }

  Future<void> fire() async {
    _callback?.call();
    // Let the fire-and-forget lock() complete.
    await Future<void>.delayed(Duration.zero);
  }
}

class _FakeTimer implements Timer {
  bool _active = true;

  @override
  void cancel() => _active = false;

  @override
  bool get isActive => _active;

  @override
  int get tick => 0;
}
