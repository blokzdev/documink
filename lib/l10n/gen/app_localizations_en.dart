// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'DocuMink';

  @override
  String get homeTagline => 'Redact with confidence';

  @override
  String get homeSubtitle => 'On-device, private, and reversible.';

  @override
  String get captureScanTitle => 'Scan';

  @override
  String get captureImportTitle => 'Import';

  @override
  String get captureScanPrompt =>
      'Capture a document with the camera, then redact the recognized text.';

  @override
  String get captureImportPrompt =>
      'Pick an image or PDF to extract and redact its text.';

  @override
  String get captureCapturePage => 'Capture page';

  @override
  String get captureChooseFromGallery => 'Choose from gallery';

  @override
  String get captureChooseImage => 'Choose image';

  @override
  String get captureChoosePdf => 'Choose PDF';

  @override
  String get captureRecognizing => 'Recognizing text…';

  @override
  String get captureErrorTitle => 'Could not read that';

  @override
  String get captureRecognizedText => 'Recognized text';

  @override
  String get captureRedactThis => 'Redact this text';

  @override
  String get captureCaptureAnother => 'Capture another';

  @override
  String get captureChooseAnother => 'Choose another';

  @override
  String get captureSourceCamera => 'Camera scan';

  @override
  String get captureSourceImage => 'Imported image';

  @override
  String get captureSourcePdf => 'PDF';

  @override
  String capturePageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pages',
      one: '1 page',
    );
    return '$_temp0';
  }

  @override
  String captureRecognizedTextSemantics(int count) {
    return 'Recognized text, $count characters';
  }

  @override
  String get pasteTitle => 'Paste text';

  @override
  String get pasteFieldLabel => 'Text to redact';

  @override
  String get pasteFieldHint =>
      'Paste or type text containing sensitive information…';

  @override
  String get pasteDetect => 'Detect';

  @override
  String get pasteDetecting => 'Detecting…';

  @override
  String get pasteNoEntities => 'No sensitive entities detected.';

  @override
  String pasteEntitiesDetected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entities detected',
      one: '1 entity detected',
    );
    return '$_temp0';
  }

  @override
  String get pasteRedactedPreview => 'Redacted preview';

  @override
  String get pasteCopy => 'Copy';

  @override
  String get pasteCopied => 'Copied';

  @override
  String get pasteSaveToVault => 'Save to vault';

  @override
  String get pasteSavedToVault => 'Saved to vault';

  @override
  String get pasteNothingToSave => 'Nothing to save';

  @override
  String get pasteOperatorError =>
      'Could not apply that operator to this text.';

  @override
  String get operatorRedact => 'Redact';

  @override
  String get operatorMask => 'Mask';

  @override
  String get operatorReplace => 'Replace';

  @override
  String get operatorToken => 'Token';

  @override
  String get operatorEncrypt => 'Encrypt';

  @override
  String get operatorFpe => 'FPE';
}
