import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import 'share_intent_receiver.dart';

/// Production [ShareIntentReceiver] backed by `receive_sharing_intent`
/// (Apache-2.0).
///
/// **Device-only:** receives platform `ACTION_SEND` intents, so it is not
/// exercised by headless tests — the coordinator it feeds is tested with a fake.
/// Wired at bootstrap; receipt is device-verified (VERIFICATION.md). V1 takes
/// the first supported item per share (batch is V3); text/url → text,
/// image → image, video/file are ignored.
class ReceiveSharingIntentShareReceiver implements ShareIntentReceiver {
  const ReceiveSharingIntentShareReceiver();

  @override
  Future<SharedInput?> initialShare() async {
    final media = await ReceiveSharingIntent.instance.getInitialMedia();
    final mapped = _firstSupported(media);
    // Clear the cached intent so a relaunch / next cold start doesn't reprocess.
    await ReceiveSharingIntent.instance.reset();
    return mapped;
  }

  @override
  Stream<SharedInput> shareStream() => ReceiveSharingIntent.instance
      .getMediaStream()
      .map(_firstSupported)
      .where((input) => input != null)
      .cast<SharedInput>();

  static SharedInput? _firstSupported(List<SharedMediaFile> media) {
    for (final file in media) {
      switch (file.type) {
        case SharedMediaType.text:
        case SharedMediaType.url:
          // The plugin carries shared text/url content in `path`.
          return SharedInput(kind: SharedInputKind.text, value: file.path);
        case SharedMediaType.image:
          return SharedInput(kind: SharedInputKind.image, value: file.path);
        case SharedMediaType.video:
        case SharedMediaType.file:
          continue; // unsupported in V1
      }
    }
    return null;
  }
}
