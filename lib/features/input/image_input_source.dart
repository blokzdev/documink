import 'input_exceptions.dart';

/// A picked image's local file path.
class PickedImage {
  const PickedImage({required this.path});

  final String path;
}

/// Acquires an image to ingest — the device camera or the system photo picker.
///
/// Named [ImageInputSource] (not `ImageSource`) to avoid clashing with
/// `image_picker`'s own `ImageSource` enum in the adapter. Returns null when the
/// user cancels. Device-only in production (`image_picker`); faked in tests via
/// this interface.
abstract interface class ImageInputSource {
  /// Opens the camera to capture a photo. Null if the user cancels.
  Future<PickedImage?> capturePhoto();

  /// Opens the system photo picker. Null if the user cancels.
  Future<PickedImage?> pickImage();
}

/// Thrown when image capture/picking is requested but no platform source was
/// wired (the safe default).
class ImageSourceUnavailableException implements InputUnavailableException {
  const ImageSourceUnavailableException();

  @override
  String toString() => 'Image capture is not available on this device.';
}

/// Safe default [ImageInputSource] — fails loudly until the real source is
/// composed at bootstrap.
class UnavailableImageInputSource implements ImageInputSource {
  const UnavailableImageInputSource();

  @override
  Future<PickedImage?> capturePhoto() async =>
      throw const ImageSourceUnavailableException();

  @override
  Future<PickedImage?> pickImage() async =>
      throw const ImageSourceUnavailableException();
}
