import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Toggles platform screenshot / recents-preview protection (Android
/// `FLAG_SECURE`) for the app window. Used by the original-document viewer
/// (Phase 4c) so decrypted content can't be screenshotted or surface in the app
/// switcher. Behind a seam: a no-op default (tests / non-Android) and a tiny
/// first-party platform-channel impl wired at bootstrap (no third-party plugin).
abstract interface class ScreenSecurity {
  /// Turn FLAG_SECURE on (call when a sensitive screen appears).
  Future<void> enable();

  /// Turn FLAG_SECURE off (call when leaving the sensitive screen).
  Future<void> disable();
}

/// Safe default — does nothing. Used in tests and on platforms without a wired
/// implementation.
class NoScreenSecurity implements ScreenSecurity {
  const NoScreenSecurity();

  @override
  Future<void> enable() async {}

  @override
  Future<void> disable() async {}
}

/// Production [ScreenSecurity] over a `MethodChannel` to `MainActivity`
/// (`window.addFlags/clearFlags(FLAG_SECURE)`). Device-only; wired at bootstrap.
class PlatformScreenSecurity implements ScreenSecurity {
  const PlatformScreenSecurity();

  static const _channel = MethodChannel('documink/screen_security');

  @override
  Future<void> enable() => _channel.invokeMethod('setSecure', true);

  @override
  Future<void> disable() => _channel.invokeMethod('setSecure', false);
}

/// App screen-security. Defaults to [NoScreenSecurity]; bootstrap overrides with
/// [PlatformScreenSecurity], tests with a fake/no-op.
final screenSecurityProvider = Provider<ScreenSecurity>(
  (ref) => const NoScreenSecurity(),
);
