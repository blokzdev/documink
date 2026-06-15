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

  @override
  String get captureSourceShared => 'Shared';

  @override
  String get pasteKeepOriginalTitle =>
      'Keep an encrypted copy of the original?';

  @override
  String get pasteKeepOriginalBody =>
      'It stays encrypted in your vault — reveal it later with biometrics.';

  @override
  String get pasteKeepOriginalNotNow => 'Not now';

  @override
  String get pasteKeepOriginalKeep => 'Keep';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSectionAppearance => 'Appearance';

  @override
  String get settingsSectionSecurity => 'Security';

  @override
  String get settingsSectionPrivacy => 'Privacy';

  @override
  String get settingsSectionAbout => 'About';

  @override
  String get settingsThemeSystem => 'System default';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsAutoLock => 'Auto-lock';

  @override
  String get settingsAutoLockSubtitle =>
      'Configured after vault unlock (later phase)';

  @override
  String get settingsBiometricUnlock => 'Biometric unlock';

  @override
  String get settingsBiometricUnlockSubtitle =>
      'Available on device (later phase)';

  @override
  String get settingsAuditLog => 'Audit log';

  @override
  String get settingsAuditLogSubtitle => 'View privacy-relevant actions';

  @override
  String get settingsCustomEntities => 'Custom entity types';

  @override
  String get settingsCustomEntitiesSubtitle => 'Define your own detectors';

  @override
  String get settingsKeepOriginal => 'Keep encrypted original';

  @override
  String get settingsKeepOriginalSubtitle =>
      'Store the source image/PDF, encrypted — reveal it later with biometrics';

  @override
  String get settingsAboutTitle => 'DocuMink';

  @override
  String settingsAboutSubtitle(String flavor) {
    return 'Privacy-first, on-device redaction · $flavor build';
  }

  @override
  String get documentTitle => 'Document';

  @override
  String get documentExport => 'Export';

  @override
  String get documentDelete => 'Delete';

  @override
  String get documentDeleteConfirmTitle => 'Delete document?';

  @override
  String get documentDeleteConfirmBody =>
      'This permanently removes the document and its tokens from the vault.';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get documentCopyText => 'Copy redacted text';

  @override
  String get documentCopyJson => 'Copy metadata (JSON)';

  @override
  String get commonCopied => 'Copied';

  @override
  String documentRevealValues(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Reveal original values ($count) · biometric',
      one: 'Reveal 1 original value · biometric',
    );
    return '$_temp0';
  }

  @override
  String get documentViewOriginal => 'View original · biometric';

  @override
  String get documentAuthFailed => 'Authentication failed';

  @override
  String get documentLoadError => 'Could not load the document';

  @override
  String get documentNotFound => 'Document not found.';

  @override
  String get documentRedactedContent => 'Redacted content';

  @override
  String get documentNoPreview => '(no preview stored)';

  @override
  String get originalViewerTitle => 'Original document';

  @override
  String get originalViewerUnsupported => 'Unsupported document type';

  @override
  String get templatePickerTitle => 'New Project';

  @override
  String get templatePickerSubtitle =>
      'Start from a Verified template — each sets up sensible redaction defaults, custom detectors, and a Mink persona for its domain.';

  @override
  String get templatePickerLoadError => 'Could not load templates';

  @override
  String get templatePreviewDefaults => 'Redaction defaults';

  @override
  String get templatePreviewCustomEntities => 'Custom detectors';

  @override
  String get templatePreviewPersona => 'Mink persona';

  @override
  String get templatePreviewNoDefaults =>
      'Safe defaults — tune in Project settings';

  @override
  String get templateProjectNameLabel => 'Project name';

  @override
  String get templateCreateProject => 'Create Project';

  @override
  String get templateProjectCreated => 'Project created';

  @override
  String get projectsTitle => 'Projects';

  @override
  String get projectsNewTooltip => 'New Project';

  @override
  String get projectsAllDocuments => 'All documents';

  @override
  String get projectsAllDocumentsSubtitle => 'Everything across projects';

  @override
  String get projectsSectionYours => 'Your projects';

  @override
  String get projectsEmptyTitle => 'No projects yet';

  @override
  String get projectsEmptyMessage =>
      'Create a Project to scope documents, detectors, and Mink to one context.';

  @override
  String get projectsLoadError => 'Could not load projects';

  @override
  String get projectsActiveBadge => 'Active';

  @override
  String get projectsArchive => 'Archive';

  @override
  String get projectsArchived => 'Project archived';

  @override
  String projectsTemplateLine(String template, String date) {
    return '$template · updated $date';
  }

  @override
  String get projectDetailDocumentsTab => 'Documents';

  @override
  String get projectDetailSettingsTab => 'Settings';

  @override
  String get projectDetailLoadError => 'Could not load this project';

  @override
  String get projectDetailNotFound => 'Project not found.';

  @override
  String get projectDetailNoDocuments => 'No documents in this project yet';

  @override
  String get projectDetailActive => 'Active project';

  @override
  String get projectDetailActiveSubtitle =>
      'New captures and saves go to this project';

  @override
  String get projectSectionPermissions => 'Permissions';

  @override
  String get projectSectionPolicy => 'Default redaction policy';

  @override
  String get projectSectionPersona => 'Mink persona';

  @override
  String get projectPersonaHint =>
      'Persona id (e.g. medical_records_conservative)';

  @override
  String get projectPersonaSave => 'Save persona';

  @override
  String get projectSettingsSaved => 'Settings updated';

  @override
  String get projectPolicyInherit => 'Default (—)';

  @override
  String get projectDecodeOff => 'Off';

  @override
  String get projectDecodeOn => 'On';

  @override
  String get projectDecodeBiometric => 'Biometric';

  @override
  String get permReadDocuments => 'Read documents';

  @override
  String get permDetectPii => 'Detect PII';

  @override
  String get permAnonymize => 'Anonymize';

  @override
  String get permDecode => 'Reveal originals (decode)';

  @override
  String get permRewriteContent => 'Rewrite content';

  @override
  String get permExpandContent => 'Expand content';

  @override
  String get permExport => 'Export';

  @override
  String get permModifyProjectSettings => 'Modify project settings';

  @override
  String get permCrossProjectSearch => 'Cross-project search';

  @override
  String get permSearchWeb => 'Search the web';

  @override
  String get wizardTitle => 'New Project — guided';

  @override
  String get wizardStepBasics => 'Basics';

  @override
  String get wizardStepData => 'Sensitive data';

  @override
  String get wizardStepPermissions => 'Permissions';

  @override
  String get wizardStepReview => 'Review';

  @override
  String get wizardName => 'Project name';

  @override
  String get wizardDomain => 'Domain';

  @override
  String get wizardDataPrompt =>
      'Which sensitive data will this project handle?';

  @override
  String get wizardDefaultAction => 'Default action for the selected types';

  @override
  String get wizardPermRewrite => 'Let Mink rewrite content';

  @override
  String get wizardPermExpand => 'Let Mink expand content';

  @override
  String get wizardPermExport => 'Allow export';

  @override
  String get wizardPermDecodeBiometric =>
      'Require biometrics to reveal originals';

  @override
  String wizardReviewSummary(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count data types',
      one: '1 data type',
      zero: 'no data types',
    );
    return '$name · $_temp0';
  }

  @override
  String get wizardNext => 'Next';

  @override
  String get wizardBack => 'Back';

  @override
  String get wizardCreate => 'Create Project';

  @override
  String get wizardBuildFromScratch => 'Build from scratch (guided)';

  @override
  String get aiTitle => 'On-device AI';

  @override
  String get aiSubtitle =>
      'Download and run Gemma on this device. Everything stays local — nothing is sent to a server.';

  @override
  String get aiSettingsRow => 'On-device AI';

  @override
  String get aiSettingsRowSubtitle => 'Download and run the local AI model';

  @override
  String get aiEnable => 'Download & enable';

  @override
  String aiDownloading(int percent) {
    return 'Downloading model… $percent%';
  }

  @override
  String get aiLoading => 'Loading model…';

  @override
  String get aiReady => 'On-device AI is ready';

  @override
  String get aiError => 'Could not enable on-device AI';

  @override
  String get aiUnsupported => 'This device can\'t run on-device AI';

  @override
  String get aiPromptHint => 'Ask something to test the model…';

  @override
  String get aiRun => 'Run';

  @override
  String get aiResponseTitle => 'Response';

  @override
  String get aiNotProfiled =>
      'Check whether this device can run on-device AI. Nothing is downloaded yet.';

  @override
  String get aiCheckDevice => 'Check my device';

  @override
  String get aiRecheck => 'Re-check my device';

  @override
  String get aiTierRecommended => 'Recommended for your device';

  @override
  String get aiTierLabel => 'Tier';

  @override
  String get aiVariantLabel => 'Variant';

  @override
  String get aiVariantBalanced => 'Balanced';

  @override
  String get aiVariantSpecialized => 'Specialized';

  @override
  String get aiModelLabel => 'Model';

  @override
  String get aiSizeLabel => 'Size';

  @override
  String get aiScoreLabel => 'Device score';

  @override
  String get aiManageTitle => 'Manage';

  @override
  String get aiTierOverride => 'Override tier';

  @override
  String get aiRemove => 'Remove downloaded model';

  @override
  String get aiFloorTitle => 'On-device AI isn\'t available here';

  @override
  String get aiFloorScore =>
      'This device doesn\'t have enough capability headroom to run the on-device assistant.';

  @override
  String get aiFloorRam =>
      'This device doesn\'t have enough memory (RAM) to run the on-device assistant.';

  @override
  String get aiFloorStorage =>
      'There isn\'t enough free storage to download and run the on-device assistant.';

  @override
  String get aiFloorNoTier =>
      'No on-device assistant is available for this device.';

  @override
  String get aiFloorStillWorks =>
      'Redaction and detection still work fully — only the AI assistant is unavailable.';
}
