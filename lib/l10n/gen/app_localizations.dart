import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// The application name / window title.
  ///
  /// In en, this message translates to:
  /// **'DocuMink'**
  String get appTitle;

  /// Home screen headline.
  ///
  /// In en, this message translates to:
  /// **'Redact with confidence'**
  String get homeTagline;

  /// Home screen sub-headline.
  ///
  /// In en, this message translates to:
  /// **'On-device, private, and reversible.'**
  String get homeSubtitle;

  /// App-bar title for the camera-scan capture screen.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get captureScanTitle;

  /// App-bar title for the image/PDF import screen.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get captureImportTitle;

  /// Idle-state guidance on the scan screen.
  ///
  /// In en, this message translates to:
  /// **'Capture a document with the camera, then redact the recognized text.'**
  String get captureScanPrompt;

  /// Idle-state guidance on the import screen.
  ///
  /// In en, this message translates to:
  /// **'Pick an image or PDF to extract and redact its text.'**
  String get captureImportPrompt;

  /// Button: open the camera to capture a page.
  ///
  /// In en, this message translates to:
  /// **'Capture page'**
  String get captureCapturePage;

  /// Secondary button on the scan screen: pick an existing photo instead of capturing.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get captureChooseFromGallery;

  /// Button: pick an image from the system photo picker.
  ///
  /// In en, this message translates to:
  /// **'Choose image'**
  String get captureChooseImage;

  /// Button: pick a PDF from the system file picker.
  ///
  /// In en, this message translates to:
  /// **'Choose PDF'**
  String get captureChoosePdf;

  /// Progress label shown while OCR / PDF extraction runs.
  ///
  /// In en, this message translates to:
  /// **'Recognizing text…'**
  String get captureRecognizing;

  /// Error-state title when capture/extraction fails.
  ///
  /// In en, this message translates to:
  /// **'Could not read that'**
  String get captureErrorTitle;

  /// Section header above the extracted text.
  ///
  /// In en, this message translates to:
  /// **'Recognized text'**
  String get captureRecognizedText;

  /// Button: send the recognized text to the redaction editor.
  ///
  /// In en, this message translates to:
  /// **'Redact this text'**
  String get captureRedactThis;

  /// Button: retake a camera capture.
  ///
  /// In en, this message translates to:
  /// **'Capture another'**
  String get captureCaptureAnother;

  /// Button: pick a different image/PDF.
  ///
  /// In en, this message translates to:
  /// **'Choose another'**
  String get captureChooseAnother;

  /// Source badge label for camera-captured text.
  ///
  /// In en, this message translates to:
  /// **'Camera scan'**
  String get captureSourceCamera;

  /// Source badge label for imported-image text.
  ///
  /// In en, this message translates to:
  /// **'Imported image'**
  String get captureSourceImage;

  /// Source badge label for PDF-imported text.
  ///
  /// In en, this message translates to:
  /// **'PDF'**
  String get captureSourcePdf;

  /// Page count shown for an imported PDF.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 page} other{{count} pages}}'**
  String capturePageCount(int count);

  /// Accessibility label for the recognized-text region.
  ///
  /// In en, this message translates to:
  /// **'Recognized text, {count} characters'**
  String captureRecognizedTextSemantics(int count);

  /// App-bar title for the paste-and-redact editor.
  ///
  /// In en, this message translates to:
  /// **'Paste text'**
  String get pasteTitle;

  /// Label for the editor text field.
  ///
  /// In en, this message translates to:
  /// **'Text to redact'**
  String get pasteFieldLabel;

  /// Hint for the editor text field.
  ///
  /// In en, this message translates to:
  /// **'Paste or type text containing sensitive information…'**
  String get pasteFieldHint;

  /// Button: run detection over the entered text.
  ///
  /// In en, this message translates to:
  /// **'Detect'**
  String get pasteDetect;

  /// Button label while detection runs.
  ///
  /// In en, this message translates to:
  /// **'Detecting…'**
  String get pasteDetecting;

  /// Shown when detection found nothing.
  ///
  /// In en, this message translates to:
  /// **'No sensitive entities detected.'**
  String get pasteNoEntities;

  /// Count of detected entities.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 entity detected} other{{count} entities detected}}'**
  String pasteEntitiesDetected(int count);

  /// Section header above the redacted preview.
  ///
  /// In en, this message translates to:
  /// **'Redacted preview'**
  String get pasteRedactedPreview;

  /// Tooltip: copy the redacted preview.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get pasteCopy;

  /// Snackbar confirming the preview was copied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get pasteCopied;

  /// Button: persist the redacted document to the vault.
  ///
  /// In en, this message translates to:
  /// **'Save to vault'**
  String get pasteSaveToVault;

  /// Snackbar confirming the document was saved.
  ///
  /// In en, this message translates to:
  /// **'Saved to vault'**
  String get pasteSavedToVault;

  /// Snackbar when there is nothing to persist.
  ///
  /// In en, this message translates to:
  /// **'Nothing to save'**
  String get pasteNothingToSave;

  /// Error when a reversible operator fails on the input.
  ///
  /// In en, this message translates to:
  /// **'Could not apply that operator to this text.'**
  String get pasteOperatorError;

  /// Operator name: irreversible redaction.
  ///
  /// In en, this message translates to:
  /// **'Redact'**
  String get operatorRedact;

  /// Operator name: partial masking.
  ///
  /// In en, this message translates to:
  /// **'Mask'**
  String get operatorMask;

  /// Operator name: replace with a label.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get operatorReplace;

  /// Operator name: vault-backed random token.
  ///
  /// In en, this message translates to:
  /// **'Token'**
  String get operatorToken;

  /// Operator name: inline ciphertext.
  ///
  /// In en, this message translates to:
  /// **'Encrypt'**
  String get operatorEncrypt;

  /// Operator name: format-preserving encryption.
  ///
  /// In en, this message translates to:
  /// **'FPE'**
  String get operatorFpe;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
