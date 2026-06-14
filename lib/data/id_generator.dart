import 'dart:math';

/// Generates a record id. Injected into repositories so tests can supply a
/// deterministic counter; production uses [defaultIdGenerator].
typedef IdGenerator = String Function();

final Random _random = Random();

/// A reasonably-unique, sortable-ish id: base36 microsecond timestamp + random
/// suffix. (A full ULID is deferred — the schema only needs a unique TEXT PK;
/// blueprint §3.1 leaves ULID generation to this layer.)
String defaultIdGenerator() {
  final time = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
  final rand = _random.nextInt(1 << 32).toRadixString(36);
  return '${time}_$rand';
}
