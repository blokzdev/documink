/// Marker for input-layer exceptions whose `toString()` is a safe, user-facing
/// message — the capture UI shows it verbatim. Unexpected/raw errors (e.g. a
/// native `PlatformException`) are not marked, so the UI shows a generic
/// fallback instead of leaking internals.
abstract interface class InputUnavailableException implements Exception {}
