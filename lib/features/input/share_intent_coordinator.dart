import 'dart:async';

import 'input_ingestion_service.dart';
import 'share_intent_receiver.dart';

/// Routes inbound shares (Phase 4) into the redaction editor.
///
/// Pure-Dart orchestration (headless-testable): the native receipt is a
/// [ShareIntentReceiver] seam, navigation is an injected callback, and the
/// unlock state is an injected predicate. A share that arrives while the vault
/// is **locked** is held and flushed once [onUnlocked] fires — the editor needs
/// the unlocked vault, and PII must not be routed into a locked app.
class ShareIntentCoordinator {
  ShareIntentCoordinator({
    required ShareIntentReceiver receiver,
    required InputIngestionService ingestion,
    required bool Function() isUnlocked,
    required void Function(String redactText) navigateToEditor,
  }) : _receiver = receiver,
       _ingestion = ingestion,
       _isUnlocked = isUnlocked,
       _navigate = navigateToEditor;

  final ShareIntentReceiver _receiver;
  final InputIngestionService _ingestion;
  final bool Function() _isUnlocked;
  final void Function(String redactText) _navigate;

  StreamSubscription<SharedInput>? _subscription;
  String? _pending;

  /// Subscribe to runtime shares and process the cold-start share (if any).
  /// All paths are guarded: a share that fails (e.g. OCR error, unreadable URI)
  /// is dropped silently rather than crashing the app — it's a best-effort
  /// convenience, never critical.
  Future<void> start() async {
    _subscription = _receiver.shareStream().listen(
      _handleSafely,
      onError: (_) {}, // a malformed share event must not kill the stream
    );
    try {
      final initial = await _receiver.initialShare();
      if (initial != null) await _handle(initial);
    } catch (_) {
      // Ignore a failed cold-start share (the app still opens normally).
    }
  }

  /// Flush a share that arrived while locked. Call when the vault unlocks.
  void onUnlocked() {
    final pending = _pending;
    if (pending != null) {
      _pending = null;
      _navigate(pending);
    }
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  /// Stream-listener wrapper: a single bad share must not throw out of the
  /// subscription (which would become an unhandled async error).
  Future<void> _handleSafely(SharedInput input) async {
    try {
      await _handle(input);
    } catch (_) {
      // Best-effort: drop this share, keep listening for the next one.
    }
  }

  Future<void> _handle(SharedInput input) async {
    final ingested = switch (input.kind) {
      SharedInputKind.text => _ingestion.ingestSharedText(input.value),
      SharedInputKind.image => await _ingestion.ingestSharedImage(input.value),
    };
    _route(ingested.text);
  }

  void _route(String text) {
    if (_isUnlocked()) {
      _navigate(text);
    } else {
      _pending = text; // held until onUnlocked()
    }
  }
}
