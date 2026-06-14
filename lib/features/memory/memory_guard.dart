import 'memory_pii_scanner.dart';

/// Thrown when a memory write is rejected for containing unreferenced PII
/// (memory.md §3.3). Carries the structured violations for diagnostics.
class MemoryPiiLeakError implements Exception {
  const MemoryPiiLeakError(this.violations);

  final List<MemoryPiiViolation> violations;

  String get message =>
      'Memory write rejected: content contains unreferenced PII. '
      'Convert to token references first.';

  @override
  String toString() =>
      'MemoryPiiLeakError: $message '
      '(${violations.map((v) => v.toString()).join(', ')})';
}

/// The single choke point every memory write passes through (memory.md §3.3):
/// asserts that content carries no unreferenced PII before it can be persisted.
class MemoryWriteGuard {
  const MemoryWriteGuard(this._scanner);

  final MemoryPiiScanner _scanner;

  /// Throws [MemoryPiiLeakError] if [content] contains PII that isn't already a
  /// token reference. Returns normally when the content is clean.
  Future<void> assertNoPlaintext(Object? content) async {
    final violations = await _scanner.scan(content);
    if (violations.isNotEmpty) {
      throw MemoryPiiLeakError(violations);
    }
  }
}
