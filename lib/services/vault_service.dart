import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_database.dart';
import '../data/sqlcipher_executor.dart';
import '../data/tokens_dao.dart';
import 'key_service.dart';

/// Lifecycle of the encrypted vault (blueprint §8.2).
enum VaultStatus { locked, unlocking, unlocked, error }

/// Public, key-free view of the vault. Secret material (Master Key, subkeys,
/// DEK) is held privately inside [VaultService] and never exposed through state.
class VaultState {
  const VaultState(this.status, {this.message});
  const VaultState.locked() : this(VaultStatus.locked);

  final VaultStatus status;
  final String? message;

  bool get isUnlocked => status == VaultStatus.unlocked;

  @override
  bool operator ==(Object other) =>
      other is VaultState && other.status == status && other.message == message;

  @override
  int get hashCode => Object.hash(status, message);
}

/// Opens a keyed [QueryExecutor] for the vault file — `openEncryptedExecutor`
/// in production; tests inject a plain file-backed executor.
typedef ExecutorOpener =
    QueryExecutor Function(File file, Uint8List databaseKey);

/// Default opener: the real SQLCipher executor (adapts its named parameters to
/// the positional [ExecutorOpener] shape).
QueryExecutor _openEncrypted(File file, Uint8List databaseKey) =>
    openEncryptedExecutor(file: file, rawKey: databaseKey);

/// Creates the auto-lock countdown — `Timer.new` in production; tests inject a
/// fake that captures the callback to fire deterministically.
typedef TimerFactory =
    Timer Function(Duration duration, void Function() onFire);

/// Drives the vault lock/unlock state machine (blueprint §8.2) and owns the
/// unlocked [AppDatabase] plus the in-RAM key material.
///
/// Passphrase-only in V1 (ADR-005/ADR-020); the biometric fast-path is Phase 5.
/// Key zeroization on lock is best-effort on managed Dart (§8.1).
///
/// The vault file path and the executor opener are injected so the service is
/// unit-testable without the encrypted native build: tests pass a temp file and
/// a plain file-backed executor, exercising the full unlock → DEK-unwrap →
/// token-crypto path. A gated integration test covers the real SQLCipher open.
class VaultService extends StateNotifier<VaultState> {
  VaultService({
    required KeyService keyService,
    required File vaultFile,
    ExecutorOpener openExecutor = _openEncrypted,
    Duration autoLockAfter = const Duration(seconds: 120),
    TimerFactory timerFactory = _realTimer,
  }) : _keyService = keyService,
       _vaultFile = vaultFile,
       _openExecutor = openExecutor,
       _autoLockAfter = autoLockAfter,
       _timerFactory = timerFactory,
       super(const VaultState.locked());

  final KeyService _keyService;
  final File _vaultFile;
  final ExecutorOpener _openExecutor;
  final Duration _autoLockAfter;
  final TimerFactory _timerFactory;

  AppDatabase? _db;
  DerivedKeys? _keys;
  Uint8List? _dek;
  Timer? _autoLockTimer;

  /// Current DEK version stamped onto stored tokens (rotation deferred).
  static const int currentDekVersion = 1;

  // vault_meta keys for post-unlock key material (ADR-020).
  static const String _wrappedDekKey = 'wrapped_dek';
  static const String _dekVersionKey = 'dek_version';

  static Timer _realTimer(Duration d, void Function() onFire) =>
      Timer(d, onFire);

  /// Whether a vault has been initialized (a salt exists).
  Future<bool> vaultExists() => _keyService.vaultExists();

  /// The unlocked database. Throws [StateError] when the vault is locked.
  AppDatabase get database {
    final db = _db;
    if (db == null || !state.isUnlocked) {
      throw StateError('Vault is locked');
    }
    return db;
  }

  /// Token cipher bound to the unlocked DEK + fingerprint key. Throws when locked.
  TokenCrypto get tokenCrypto {
    final keys = _keys;
    final dek = _dek;
    if (keys == null || dek == null || !state.isUnlocked) {
      throw StateError('Vault is locked');
    }
    return TokenCrypto(dek: dek, fingerprintHmacKey: keys.fingerprintHmacKey);
  }

  /// First-run setup: generate the salt + DEK, key the new database, and
  /// persist the wrapped DEK. Throws [StateError] if a vault already exists.
  Future<void> initialize(String passphrase) async {
    if (await _keyService.vaultExists()) {
      throw StateError('Vault already initialized; call unlock()');
    }
    state = const VaultState(VaultStatus.unlocking);
    AppDatabase? db;
    DerivedKeys? keys;
    Uint8List? dek;
    try {
      final salt = await _keyService.loadOrCreateSalt();
      keys = await _deriveSubkeys(passphrase, salt);
      db = AppDatabase(_openExecutor(_vaultFile, keys.databaseKey));
      dek = _keyService.generateDek();
      final wrapped = await _keyService.wrapDek(dek, keys.keyEncryptionKey);
      await db
          .into(db.vaultMeta)
          .insert(
            VaultMetaCompanion.insert(key: _wrappedDekKey, value: wrapped),
          );
      await db
          .into(db.vaultMeta)
          .insert(
            VaultMetaCompanion.insert(
              key: _dekVersionKey,
              value: _encodeVersion(currentDekVersion),
            ),
          );
      _adopt(db: db, keys: keys, dek: dek);
    } catch (error) {
      await _discard(db: db, keys: keys, dek: dek);
      state = const VaultState(
        VaultStatus.error,
        message: 'Vault initialization failed',
      );
      rethrow;
    }
  }

  /// Unlocks an existing vault. A wrong passphrase fails authentication (the
  /// DEK unwrap — and, with the real cipher, the database open itself), leaving
  /// the vault locked. Throws [StateError] if no vault exists.
  Future<void> unlock(String passphrase) async {
    final salt = await _keyService.readSalt();
    if (salt == null) {
      throw StateError('No vault to unlock; call initialize()');
    }
    state = const VaultState(VaultStatus.unlocking);
    AppDatabase? db;
    DerivedKeys? keys;
    Uint8List? dek;
    try {
      keys = await _deriveSubkeys(passphrase, salt);
      db = AppDatabase(_openExecutor(_vaultFile, keys.databaseKey));
      final row = await (db.select(
        db.vaultMeta,
      )..where((t) => t.key.equals(_wrappedDekKey))).getSingleOrNull();
      if (row == null) {
        throw StateError('Vault metadata is missing the wrapped DEK');
      }
      // Throws SecretBoxAuthenticationError on the wrong passphrase/KEK.
      dek = await _keyService.unwrapDek(row.value, keys.keyEncryptionKey);
      _adopt(db: db, keys: keys, dek: dek);
    } catch (error) {
      await _discard(db: db, keys: keys, dek: dek);
      state = const VaultState.locked();
      rethrow;
    }
  }

  /// Locks the vault: stops the timer, closes the database, and best-effort
  /// zeroes all key material.
  Future<void> lock() async {
    await _discard(db: _db, keys: _keys, dek: _dek);
    _db = null;
    _keys = null;
    _dek = null;
    if (mounted) state = const VaultState.locked();
  }

  /// Registers user activity, restarting the auto-lock countdown. No-op while
  /// locked.
  void touch() {
    if (state.isUnlocked) _armAutoLock();
  }

  Future<DerivedKeys> _deriveSubkeys(String passphrase, Uint8List salt) async {
    final mk = _keyService.deriveMasterKey(passphrase, salt);
    try {
      return await _keyService.deriveSubkeys(mk);
    } finally {
      mk.fillRange(0, mk.length, 0); // MK lives no longer than necessary.
    }
  }

  void _adopt({
    required AppDatabase db,
    required DerivedKeys keys,
    required Uint8List dek,
  }) {
    _db = db;
    _keys = keys;
    _dek = dek;
    _armAutoLock();
    state = const VaultState(VaultStatus.unlocked);
  }

  Future<void> _discard({
    AppDatabase? db,
    DerivedKeys? keys,
    Uint8List? dek,
  }) async {
    _autoLockTimer?.cancel();
    _autoLockTimer = null;
    keys?.destroy();
    if (dek != null) dek.fillRange(0, dek.length, 0);
    if (db != null) await db.close();
  }

  void _armAutoLock() {
    _autoLockTimer?.cancel();
    _autoLockTimer = _timerFactory(_autoLockAfter, () => unawaited(lock()));
  }

  static Uint8List _encodeVersion(int version) =>
      Uint8List(4)..buffer.asByteData().setUint32(0, version);

  @override
  void dispose() {
    // Best-effort synchronous cleanup on disposal.
    _autoLockTimer?.cancel();
    _keys?.destroy();
    final dek = _dek;
    if (dek != null) dek.fillRange(0, dek.length, 0);
    unawaited(_db?.close() ?? Future<void>.value());
    super.dispose();
  }
}
