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

  /// Source badge label for content shared from another app.
  ///
  /// In en, this message translates to:
  /// **'Shared'**
  String get captureSourceShared;

  /// Title of the in-context keep-original opt-in hint.
  ///
  /// In en, this message translates to:
  /// **'Keep an encrypted copy of the original?'**
  String get pasteKeepOriginalTitle;

  /// Body of the keep-original hint.
  ///
  /// In en, this message translates to:
  /// **'It stays encrypted in your vault — reveal it later with biometrics.'**
  String get pasteKeepOriginalBody;

  /// Dismiss the keep-original hint without enabling it.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get pasteKeepOriginalNotNow;

  /// Enable keeping the encrypted original.
  ///
  /// In en, this message translates to:
  /// **'Keep'**
  String get pasteKeepOriginalKeep;

  /// Settings screen app-bar title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Settings section header.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsSectionAppearance;

  /// Settings section header.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get settingsSectionSecurity;

  /// Settings section header.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get settingsSectionPrivacy;

  /// Settings section header.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsSectionAbout;

  /// Theme option: follow system.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get settingsThemeSystem;

  /// Theme option: light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// Theme option: dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// Security row title.
  ///
  /// In en, this message translates to:
  /// **'Auto-lock'**
  String get settingsAutoLock;

  /// Security row subtitle.
  ///
  /// In en, this message translates to:
  /// **'Configured after vault unlock (later phase)'**
  String get settingsAutoLockSubtitle;

  /// Security row title.
  ///
  /// In en, this message translates to:
  /// **'Biometric unlock'**
  String get settingsBiometricUnlock;

  /// Security row subtitle.
  ///
  /// In en, this message translates to:
  /// **'Available on device (later phase)'**
  String get settingsBiometricUnlockSubtitle;

  /// Privacy row title.
  ///
  /// In en, this message translates to:
  /// **'Audit log'**
  String get settingsAuditLog;

  /// Privacy row subtitle.
  ///
  /// In en, this message translates to:
  /// **'View privacy-relevant actions'**
  String get settingsAuditLogSubtitle;

  /// Privacy row title.
  ///
  /// In en, this message translates to:
  /// **'Custom entity types'**
  String get settingsCustomEntities;

  /// Privacy row subtitle.
  ///
  /// In en, this message translates to:
  /// **'Define your own detectors'**
  String get settingsCustomEntitiesSubtitle;

  /// Privacy toggle title.
  ///
  /// In en, this message translates to:
  /// **'Keep encrypted original'**
  String get settingsKeepOriginal;

  /// Privacy toggle subtitle.
  ///
  /// In en, this message translates to:
  /// **'Store the source image/PDF, encrypted — reveal it later with biometrics'**
  String get settingsKeepOriginalSubtitle;

  /// Privacy toggle title for Mink proactive suggestions.
  ///
  /// In en, this message translates to:
  /// **'Proactive suggestions'**
  String get settingsProactiveSuggestions;

  /// Privacy toggle subtitle for Mink proactive suggestions.
  ///
  /// In en, this message translates to:
  /// **'Let Mink offer an occasional follow-up tip after an action — in-context and dismissible, never a notification'**
  String get settingsProactiveSuggestionsSubtitle;

  /// Button that applies a proactive suggestion's one-tap action.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get suggestionApply;

  /// Button that dismisses a proactive suggestion card.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get suggestionDismiss;

  /// One-time disclosure shown above the first proactive suggestion.
  ///
  /// In en, this message translates to:
  /// **'Mink can offer occasional follow-up tips after an action. You can turn this off in Settings.'**
  String get suggestionDisclosure;

  /// About row title.
  ///
  /// In en, this message translates to:
  /// **'DocuMink'**
  String get settingsAboutTitle;

  /// About row subtitle with the build flavor.
  ///
  /// In en, this message translates to:
  /// **'Privacy-first, on-device redaction · {flavor} build'**
  String settingsAboutSubtitle(String flavor);

  /// Document detail app-bar title.
  ///
  /// In en, this message translates to:
  /// **'Document'**
  String get documentTitle;

  /// Export action tooltip.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get documentExport;

  /// Delete action tooltip/button.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get documentDelete;

  /// Delete confirm dialog title.
  ///
  /// In en, this message translates to:
  /// **'Delete document?'**
  String get documentDeleteConfirmTitle;

  /// Delete confirm dialog body.
  ///
  /// In en, this message translates to:
  /// **'This permanently removes the document and its tokens from the vault.'**
  String get documentDeleteConfirmBody;

  /// Generic cancel button.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// Export sheet: copy redacted text.
  ///
  /// In en, this message translates to:
  /// **'Copy redacted text'**
  String get documentCopyText;

  /// Export sheet: copy JSON metadata.
  ///
  /// In en, this message translates to:
  /// **'Copy metadata (JSON)'**
  String get documentCopyJson;

  /// Snackbar: content copied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get commonCopied;

  /// Reveal reversible tokens button.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Reveal 1 original value · biometric} other{Reveal original values ({count}) · biometric}}'**
  String documentRevealValues(int count);

  /// View the retained original button.
  ///
  /// In en, this message translates to:
  /// **'View original · biometric'**
  String get documentViewOriginal;

  /// Snackbar when biometric auth fails.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed'**
  String get documentAuthFailed;

  /// Error state title.
  ///
  /// In en, this message translates to:
  /// **'Could not load the document'**
  String get documentLoadError;

  /// Shown when the document is missing.
  ///
  /// In en, this message translates to:
  /// **'Document not found.'**
  String get documentNotFound;

  /// Section header for redacted text.
  ///
  /// In en, this message translates to:
  /// **'Redacted content'**
  String get documentRedactedContent;

  /// Placeholder when no redacted preview.
  ///
  /// In en, this message translates to:
  /// **'(no preview stored)'**
  String get documentNoPreview;

  /// Secure original-document viewer title.
  ///
  /// In en, this message translates to:
  /// **'Original document'**
  String get originalViewerTitle;

  /// Viewer fallback for non-image/PDF.
  ///
  /// In en, this message translates to:
  /// **'Unsupported document type'**
  String get originalViewerUnsupported;

  /// Template picker app-bar title.
  ///
  /// In en, this message translates to:
  /// **'New Project'**
  String get templatePickerTitle;

  /// Template picker intro text.
  ///
  /// In en, this message translates to:
  /// **'Start from a Verified template — each sets up sensible redaction defaults, custom detectors, and a Mink persona for its domain.'**
  String get templatePickerSubtitle;

  /// Error state when the signed templates catalog fails to load/verify.
  ///
  /// In en, this message translates to:
  /// **'Could not load templates'**
  String get templatePickerLoadError;

  /// Preview section: the template's default policy.
  ///
  /// In en, this message translates to:
  /// **'Redaction defaults'**
  String get templatePreviewDefaults;

  /// Preview section: the template's seeded custom entity types.
  ///
  /// In en, this message translates to:
  /// **'Custom detectors'**
  String get templatePreviewCustomEntities;

  /// Preview section: the template's Mink persona.
  ///
  /// In en, this message translates to:
  /// **'Mink persona'**
  String get templatePreviewPersona;

  /// Shown when a template has no explicit default policy (e.g. blank).
  ///
  /// In en, this message translates to:
  /// **'Safe defaults — tune in Project settings'**
  String get templatePreviewNoDefaults;

  /// Label for the new-project name field.
  ///
  /// In en, this message translates to:
  /// **'Project name'**
  String get templateProjectNameLabel;

  /// Button: create a project from the selected template.
  ///
  /// In en, this message translates to:
  /// **'Create Project'**
  String get templateCreateProject;

  /// Snackbar confirming the project was created.
  ///
  /// In en, this message translates to:
  /// **'Project created'**
  String get templateProjectCreated;

  /// Projects list app-bar title.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get projectsTitle;

  /// Tooltip for the new-project action.
  ///
  /// In en, this message translates to:
  /// **'New Project'**
  String get projectsNewTooltip;

  /// Tile that clears the active project (whole-workspace view).
  ///
  /// In en, this message translates to:
  /// **'All documents'**
  String get projectsAllDocuments;

  /// Subtitle for the all-documents tile.
  ///
  /// In en, this message translates to:
  /// **'Everything across projects'**
  String get projectsAllDocumentsSubtitle;

  /// Section header above the project list.
  ///
  /// In en, this message translates to:
  /// **'Your projects'**
  String get projectsSectionYours;

  /// Empty-state title for the project list.
  ///
  /// In en, this message translates to:
  /// **'No projects yet'**
  String get projectsEmptyTitle;

  /// Empty-state message for the project list.
  ///
  /// In en, this message translates to:
  /// **'Create a Project to scope documents, detectors, and Mink to one context.'**
  String get projectsEmptyMessage;

  /// Error-state title for the project list.
  ///
  /// In en, this message translates to:
  /// **'Could not load projects'**
  String get projectsLoadError;

  /// Badge marking the currently active project.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get projectsActiveBadge;

  /// Menu action: archive a project.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get projectsArchive;

  /// Snackbar confirming a project was archived.
  ///
  /// In en, this message translates to:
  /// **'Project archived'**
  String get projectsArchived;

  /// Project card subtitle: template id and last-updated date.
  ///
  /// In en, this message translates to:
  /// **'{template} · updated {date}'**
  String projectsTemplateLine(String template, String date);

  /// Project detail tab: documents.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get projectDetailDocumentsTab;

  /// Project detail tab: settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get projectDetailSettingsTab;

  /// Error state for the project detail screen.
  ///
  /// In en, this message translates to:
  /// **'Could not load this project'**
  String get projectDetailLoadError;

  /// Shown when the project is missing.
  ///
  /// In en, this message translates to:
  /// **'Project not found.'**
  String get projectDetailNotFound;

  /// Empty state for a project's documents tab.
  ///
  /// In en, this message translates to:
  /// **'No documents in this project yet'**
  String get projectDetailNoDocuments;

  /// Toggle: make this the active project.
  ///
  /// In en, this message translates to:
  /// **'Active project'**
  String get projectDetailActive;

  /// Subtitle for the active-project toggle.
  ///
  /// In en, this message translates to:
  /// **'New captures and saves go to this project'**
  String get projectDetailActiveSubtitle;

  /// Settings section: Mink permissions.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get projectSectionPermissions;

  /// Settings section: default anonymization policy.
  ///
  /// In en, this message translates to:
  /// **'Default redaction policy'**
  String get projectSectionPolicy;

  /// Settings section: Mink persona.
  ///
  /// In en, this message translates to:
  /// **'Mink persona'**
  String get projectSectionPersona;

  /// Hint for the persona field.
  ///
  /// In en, this message translates to:
  /// **'Persona id (e.g. medical_records_conservative)'**
  String get projectPersonaHint;

  /// Button: save the persona.
  ///
  /// In en, this message translates to:
  /// **'Save persona'**
  String get projectPersonaSave;

  /// Snackbar after a settings change is persisted.
  ///
  /// In en, this message translates to:
  /// **'Settings updated'**
  String get projectSettingsSaved;

  /// Policy dropdown option: no explicit operator (use fallback).
  ///
  /// In en, this message translates to:
  /// **'Default (—)'**
  String get projectPolicyInherit;

  /// Decode permission: denied.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get projectDecodeOff;

  /// Decode permission: granted.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get projectDecodeOn;

  /// Decode permission: granted but biometric-gated.
  ///
  /// In en, this message translates to:
  /// **'Biometric'**
  String get projectDecodeBiometric;

  /// Permission label.
  ///
  /// In en, this message translates to:
  /// **'Read documents'**
  String get permReadDocuments;

  /// Permission label.
  ///
  /// In en, this message translates to:
  /// **'Detect PII'**
  String get permDetectPii;

  /// Permission label.
  ///
  /// In en, this message translates to:
  /// **'Anonymize'**
  String get permAnonymize;

  /// Permission label.
  ///
  /// In en, this message translates to:
  /// **'Reveal originals (decode)'**
  String get permDecode;

  /// Permission label.
  ///
  /// In en, this message translates to:
  /// **'Rewrite content'**
  String get permRewriteContent;

  /// Permission label.
  ///
  /// In en, this message translates to:
  /// **'Expand content'**
  String get permExpandContent;

  /// Permission label.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get permExport;

  /// Permission label.
  ///
  /// In en, this message translates to:
  /// **'Modify project settings'**
  String get permModifyProjectSettings;

  /// Permission label.
  ///
  /// In en, this message translates to:
  /// **'Cross-project search'**
  String get permCrossProjectSearch;

  /// Permission label.
  ///
  /// In en, this message translates to:
  /// **'Search the web'**
  String get permSearchWeb;

  /// Blank-wizard app-bar title.
  ///
  /// In en, this message translates to:
  /// **'New Project — guided'**
  String get wizardTitle;

  /// Wizard step: basics.
  ///
  /// In en, this message translates to:
  /// **'Basics'**
  String get wizardStepBasics;

  /// Wizard step: sensitive data.
  ///
  /// In en, this message translates to:
  /// **'Sensitive data'**
  String get wizardStepData;

  /// Wizard step: permissions.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get wizardStepPermissions;

  /// Wizard step: review.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get wizardStepReview;

  /// Wizard: project name field.
  ///
  /// In en, this message translates to:
  /// **'Project name'**
  String get wizardName;

  /// Wizard: domain dropdown.
  ///
  /// In en, this message translates to:
  /// **'Domain'**
  String get wizardDomain;

  /// Wizard: sensitive-data step prompt.
  ///
  /// In en, this message translates to:
  /// **'Which sensitive data will this project handle?'**
  String get wizardDataPrompt;

  /// Wizard: default operator dropdown label.
  ///
  /// In en, this message translates to:
  /// **'Default action for the selected types'**
  String get wizardDefaultAction;

  /// Wizard permission toggle.
  ///
  /// In en, this message translates to:
  /// **'Let Mink rewrite content'**
  String get wizardPermRewrite;

  /// Wizard permission toggle.
  ///
  /// In en, this message translates to:
  /// **'Let Mink expand content'**
  String get wizardPermExpand;

  /// Wizard permission toggle.
  ///
  /// In en, this message translates to:
  /// **'Allow export'**
  String get wizardPermExport;

  /// Wizard permission toggle.
  ///
  /// In en, this message translates to:
  /// **'Require biometrics to reveal originals'**
  String get wizardPermDecodeBiometric;

  /// Wizard review summary line.
  ///
  /// In en, this message translates to:
  /// **'{name} · {count, plural, =0{no data types} =1{1 data type} other{{count} data types}}'**
  String wizardReviewSummary(String name, int count);

  /// Wizard: advance to the next step.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get wizardNext;

  /// Wizard: go to the previous step.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get wizardBack;

  /// Wizard: create the project.
  ///
  /// In en, this message translates to:
  /// **'Create Project'**
  String get wizardCreate;

  /// Template picker: launch the blank wizard.
  ///
  /// In en, this message translates to:
  /// **'Build from scratch (guided)'**
  String get wizardBuildFromScratch;

  /// AI settings screen title.
  ///
  /// In en, this message translates to:
  /// **'On-device AI'**
  String get aiTitle;

  /// AI settings intro.
  ///
  /// In en, this message translates to:
  /// **'Download and run Gemma on this device. Everything stays local — nothing is sent to a server.'**
  String get aiSubtitle;

  /// Settings row opening the on-device AI screen.
  ///
  /// In en, this message translates to:
  /// **'On-device AI'**
  String get aiSettingsRow;

  /// Settings row subtitle for on-device AI.
  ///
  /// In en, this message translates to:
  /// **'Download and run the local AI model'**
  String get aiSettingsRowSubtitle;

  /// Privacy row opening the Mink memory screen.
  ///
  /// In en, this message translates to:
  /// **'Mink memory'**
  String get settingsMinkMemory;

  /// Privacy row subtitle for Mink memory.
  ///
  /// In en, this message translates to:
  /// **'Review and manage what Mink remembers'**
  String get settingsMinkMemorySubtitle;

  /// Button to download + load the on-device model.
  ///
  /// In en, this message translates to:
  /// **'Download & enable'**
  String get aiEnable;

  /// Progress label while the model downloads.
  ///
  /// In en, this message translates to:
  /// **'Downloading model… {percent}%'**
  String aiDownloading(int percent);

  /// Shown while the model loads into the runtime.
  ///
  /// In en, this message translates to:
  /// **'Loading model…'**
  String get aiLoading;

  /// Shown once the model is loaded.
  ///
  /// In en, this message translates to:
  /// **'On-device AI is ready'**
  String get aiReady;

  /// Error state for AI enablement.
  ///
  /// In en, this message translates to:
  /// **'Could not enable on-device AI'**
  String get aiError;

  /// Shown when no model variant is available.
  ///
  /// In en, this message translates to:
  /// **'This device can\'t run on-device AI'**
  String get aiUnsupported;

  /// Hint for the test-prompt field.
  ///
  /// In en, this message translates to:
  /// **'Ask something to test the model…'**
  String get aiPromptHint;

  /// Run the test prompt.
  ///
  /// In en, this message translates to:
  /// **'Run'**
  String get aiRun;

  /// Header above the model's response.
  ///
  /// In en, this message translates to:
  /// **'Response'**
  String get aiResponseTitle;

  /// Shown before the profiler has run.
  ///
  /// In en, this message translates to:
  /// **'Check whether this device can run on-device AI. Nothing is downloaded yet.'**
  String get aiNotProfiled;

  /// Runs the capability profiler for the first time.
  ///
  /// In en, this message translates to:
  /// **'Check my device'**
  String get aiCheckDevice;

  /// Re-runs the capability profiler.
  ///
  /// In en, this message translates to:
  /// **'Re-check my device'**
  String get aiRecheck;

  /// Label above the recommended tier.
  ///
  /// In en, this message translates to:
  /// **'Recommended for your device'**
  String get aiTierRecommended;

  /// Capability tier field label.
  ///
  /// In en, this message translates to:
  /// **'Tier'**
  String get aiTierLabel;

  /// Model variant field label.
  ///
  /// In en, this message translates to:
  /// **'Variant'**
  String get aiVariantLabel;

  /// The Balanced model variant.
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get aiVariantBalanced;

  /// The Specialized model variant.
  ///
  /// In en, this message translates to:
  /// **'Specialized'**
  String get aiVariantSpecialized;

  /// Model id/name field label.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get aiModelLabel;

  /// Download size field label.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get aiSizeLabel;

  /// Capability score field label.
  ///
  /// In en, this message translates to:
  /// **'Device score'**
  String get aiScoreLabel;

  /// Header for the model management controls.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get aiManageTitle;

  /// Label for the tier override dropdown.
  ///
  /// In en, this message translates to:
  /// **'Override tier'**
  String get aiTierOverride;

  /// Deletes the on-device model file.
  ///
  /// In en, this message translates to:
  /// **'Remove downloaded model'**
  String get aiRemove;

  /// Floor-state title (device below minimum).
  ///
  /// In en, this message translates to:
  /// **'On-device AI isn\'t available here'**
  String get aiFloorTitle;

  /// Floor reason: insufficient capability score.
  ///
  /// In en, this message translates to:
  /// **'This device doesn\'t have enough capability headroom to run the on-device assistant.'**
  String get aiFloorScore;

  /// Floor reason: insufficient RAM.
  ///
  /// In en, this message translates to:
  /// **'This device doesn\'t have enough memory (RAM) to run the on-device assistant.'**
  String get aiFloorRam;

  /// Floor reason: insufficient storage.
  ///
  /// In en, this message translates to:
  /// **'There isn\'t enough free storage to download and run the on-device assistant.'**
  String get aiFloorStorage;

  /// Floor reason: no qualifying tier.
  ///
  /// In en, this message translates to:
  /// **'No on-device assistant is available for this device.'**
  String get aiFloorNoTier;

  /// Reassurance shown in the floor state.
  ///
  /// In en, this message translates to:
  /// **'Redaction and detection still work fully — only the AI assistant is unavailable.'**
  String get aiFloorStillWorks;

  /// First-run AI onboarding title.
  ///
  /// In en, this message translates to:
  /// **'Meet Mink'**
  String get onboardingTitle;

  /// First-run AI onboarding intro paragraph.
  ///
  /// In en, this message translates to:
  /// **'Mink is your on-device assistant. It runs entirely on this device — nothing is sent to a server. Add it now, or anytime in Settings.'**
  String get onboardingIntro;

  /// Download + enable the selected model.
  ///
  /// In en, this message translates to:
  /// **'Accept & download'**
  String get onboardingAccept;

  /// Skip AI setup and continue to the app.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get onboardingSkip;

  /// Reveal alternative model variants/tiers.
  ///
  /// In en, this message translates to:
  /// **'Show options'**
  String get onboardingShowOptions;

  /// Proceed past the floor onboarding state.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboardingContinue;

  /// Size caution tag on an opt-in tier.
  ///
  /// In en, this message translates to:
  /// **'larger download'**
  String get onboardingOptInWarning;

  /// Tooltip on the disabled Mink action at the AI floor.
  ///
  /// In en, this message translates to:
  /// **'Needs a more capable device'**
  String get homeMinkUnavailable;
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
