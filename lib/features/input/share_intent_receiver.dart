/// What another app shared into DocuMink.
enum SharedInputKind { text, image }

/// A single shared item. [value] is the text content for [SharedInputKind.text]
/// or the image file path for [SharedInputKind.image].
class SharedInput {
  const SharedInput({required this.kind, required this.value});

  final SharedInputKind kind;
  final String value;
}

/// Receives `ACTION_SEND` shares from other apps.
///
/// Device-only in production (platform intents). Behind this interface so the
/// [ShareIntentCoordinator] orchestration is unit-testable with a fake; the real
/// adapter wraps `receive_sharing_intent` and is composed at bootstrap.
abstract interface class ShareIntentReceiver {
  /// The share that cold-started the app (consumed once), or null if none.
  Future<SharedInput?> initialShare();

  /// Subsequent shares delivered while the app is already running (the
  /// `singleTop` relaunch case).
  Stream<SharedInput> shareStream();
}

/// Safe default — yields nothing. Bootstrap overrides it with the real adapter;
/// tests override with a fake.
class NoShareIntentReceiver implements ShareIntentReceiver {
  const NoShareIntentReceiver();

  @override
  Future<SharedInput?> initialShare() async => null;

  @override
  Stream<SharedInput> shareStream() => const Stream.empty();
}
