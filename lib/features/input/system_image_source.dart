import 'package:image_picker/image_picker.dart' as picker;

import 'image_input_source.dart';

/// Production [ImageInputSource] backed by `image_picker` (Android camera +
/// system photo picker; on Android 13+ the picker needs no storage permission).
///
/// **Device-only:** opens native UI, so it is not exercised by headless tests —
/// the orchestration it feeds is tested via a fake source. Wired at bootstrap;
/// capture/permissions/HEIC decode are device-verified (VERIFICATION.md).
class SystemImageSource implements ImageInputSource {
  SystemImageSource([picker.ImagePicker? imagePicker])
    : _picker = imagePicker ?? picker.ImagePicker();

  final picker.ImagePicker _picker;

  @override
  Future<PickedImage?> capturePhoto() => _pick(picker.ImageSource.camera);

  @override
  Future<PickedImage?> pickImage() => _pick(picker.ImageSource.gallery);

  Future<PickedImage?> _pick(picker.ImageSource source) async {
    final file = await _picker.pickImage(source: source, imageQuality: 100);
    return file == null ? null : PickedImage(path: file.path);
  }
}
