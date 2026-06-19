import 'dart:io';
import 'dart:typed_data';

/// Durable store for the **non-secret** Argon2id salt, readable *before* the
/// vault opens.
///
/// The salt is public by design (blueprint §8.1 / ADR-020): it only needs to be
/// unique, survive launches, and be available pre-unlock — it is **not** a
/// secret. V1 therefore keeps it in a plaintext app-private file rather than the
/// platform Keystore. A lost/invalidated Keystore key (observed on a StrongBox
/// device — see `docs/DECISIONS.md`) would otherwise make the salt unreadable
/// and permanently brick the vault, even with the correct passphrase. Keeping
/// the salt off the Keystore removes that single point of failure; the SQLCipher
/// database itself remains the encrypted artifact, and its key is never stored.
abstract interface class SaltStore {
  /// The persisted salt, or `null` if none has been written yet.
  Future<Uint8List?> read();

  /// Persists [salt], overwriting any existing value.
  Future<void> write(Uint8List salt);

  /// Whether a (non-empty) salt is currently persisted.
  Future<bool> exists();

  /// Removes the persisted salt, if any.
  Future<void> delete();
}

/// Production [SaltStore]: a plaintext file (the sibling of `vault.db`). Writes
/// are atomic (temp file + rename) so a crash mid-write cannot leave a truncated
/// salt behind.
///
/// File access is **synchronous** (`*Sync`): the salt is 16 bytes on the unlock
/// critical path, so the cost is negligible, and it mirrors the vault's own
/// synchronous SQLite FFI. It also keeps the store usable under `testWidgets`'
/// FakeAsync, where real async `dart:io` futures never complete.
class FileSaltStore implements SaltStore {
  FileSaltStore(this._file);

  final File _file;

  File get _tmp => File('${_file.path}.tmp');

  @override
  Future<Uint8List?> read() async {
    if (!_file.existsSync()) return null;
    final bytes = _file.readAsBytesSync();
    if (bytes.isEmpty) return null;
    return Uint8List.fromList(bytes);
  }

  @override
  Future<void> write(Uint8List salt) async {
    _file.parent.createSync(recursive: true);
    final tmp = _tmp;
    tmp.writeAsBytesSync(salt, flush: true);
    tmp.renameSync(_file.path);
  }

  @override
  Future<bool> exists() async => _file.existsSync() && _file.lengthSync() > 0;

  @override
  Future<void> delete() async {
    if (_file.existsSync()) _file.deleteSync();
    if (_tmp.existsSync()) _tmp.deleteSync();
  }
}
