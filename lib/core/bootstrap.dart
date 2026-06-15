import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gemma/flutter_gemma.dart' show FlutterGemma;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/gen/app_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'flavors/flavor.dart';
import 'router.dart';
import '../features/llm/ai_activation_service.dart';
import '../features/llm/android_device_signal_collector.dart';
import '../features/llm/http_model_source.dart';
import '../features/llm/llm_providers.dart';
import '../features/llm/model_store.dart';
import '../features/input/file_selector_pdf_source.dart';
import '../features/input/flutter_pdf_text_extractor.dart';
import '../features/input/input_providers.dart';
import '../features/input/mlkit_text_recognizer.dart';
import '../features/input/pdfx_page_rasterizer.dart';
import '../features/input/receive_sharing_intent_share_receiver.dart';
import '../features/input/share_intent_coordinator.dart';
import '../features/input/system_image_source.dart';
import '../features/security/screen_security.dart';
import '../services/authenticator.dart';
import '../services/local_auth_authenticator.dart';
import '../services/settings_store.dart';
import '../services/shared_preferences_settings_store.dart';
import '../services/vault_providers.dart';
import 'routes.dart';
import '../ui/theme/app_theme.dart';
import '../ui/theme/theme_mode_controller.dart';

Future<void> bootstrap(Flavor flavor) async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final supportDir = await getApplicationSupportDirectory();
  final vaultFile = File('${supportDir.path}/vault.db');
  // Tier-4 on-device LLM runtime (Phase 10b). Initializes flutter_gemma once;
  // the model is downloaded + verified on demand (no model bundled).
  await FlutterGemma.initialize();
  runApp(
    ProviderScope(
      overrides: [
        currentFlavorProvider.overrideWithValue(flavor),
        settingsStoreProvider.overrideWithValue(
          SharedPreferencesSettingsStore(prefs),
        ),
        vaultFileProvider.overrideWithValue(vaultFile),
        authenticatorProvider.overrideWithValue(LocalAuthAuthenticator()),
        // Phase 4 input: real on-device OCR + camera/picker adapters. Behind
        // seams so headless tests use fakes; device-verified (VERIFICATION.md).
        ocrRecognizerProvider.overrideWithValue(MlKitTextRecognizer()),
        imageInputSourceProvider.overrideWithValue(SystemImageSource()),
        // Phase 4b PDF import: pick (file_selector) → extract text layer
        // (flutter_pdf_text) → rasterize scanned pages (pdfx) into the OCR seam.
        pdfSourceProvider.overrideWithValue(const FileSelectorPdfSource()),
        pdfTextExtractorProvider.overrideWithValue(
          const FlutterPdfTextExtractor(),
        ),
        pdfPageRasterizerProvider.overrideWithValue(const PdfxPageRasterizer()),
        // Phase 4 inbound share-sheet intent (receive text/images from other
        // apps). Behind the ShareIntentReceiver seam; faked in tests.
        shareIntentReceiverProvider.overrideWithValue(
          const ReceiveSharingIntentShareReceiver(),
        ),
        // Phase 4c: real FLAG_SECURE toggling for the original-document viewer.
        screenSecurityProvider.overrideWithValue(
          const PlatformScreenSecurity(),
        ),
        // Phase 10b/10c Tier-4: HTTP model transport + app-support model store.
        // The model is downloaded + SHA-256-verified on demand; the runtime
        // (flutter_gemma) loads it. Device-verified (VERIFICATION.md).
        modelSourceProvider.overrideWithValue(const HttpModelSource()),
        modelStoreProvider.overrideWithValue(ModelStore(supportDir)),
        // Phase 11: real device-capability signals for the profiler (RAM/storage/
        // cores/OS via a first-party channel). Device-verified (VERIFICATION.md).
        deviceSignalCollectorProvider.overrideWithValue(
          const AndroidDeviceSignalCollector(),
        ),
      ],
      child: const DocuMinkApp(),
    ),
  );
}

class DocuMinkApp extends ConsumerStatefulWidget {
  const DocuMinkApp({super.key});

  @override
  ConsumerState<DocuMinkApp> createState() => _DocuMinkAppState();
}

class _DocuMinkAppState extends ConsumerState<DocuMinkApp> {
  ShareIntentCoordinator? _shareCoordinator;

  @override
  void initState() {
    super.initState();
    // After the first frame the router exists; wire inbound shares → editor,
    // holding any share that arrives while the vault is locked until unlock.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final router = ref.read(routerProvider);
      final coordinator = ShareIntentCoordinator(
        receiver: ref.read(shareIntentReceiverProvider),
        ingestion: ref.read(inputIngestionServiceProvider),
        isUnlocked: () => ref.read(appUnlockedProvider),
        navigateToEditor: (text) => router.push(Routes.paste, extra: text),
      );
      _shareCoordinator = coordinator;
      // Phase 11: re-enable a previously-downloaded Tier-4 model on unlock so
      // enablement survives restarts (activation is otherwise in-memory).
      // Best-effort: guard the provider read so an environment without the
      // bootstrap-wired model store (e.g. full-app widget tests) doesn't crash
      // startup — AI just stays Unavailable there.
      void restoreAi() {
        try {
          ref.read(aiActivationServiceProvider).restoreOnUnlock();
        } catch (_) {
          // Providers not wired (tests) — skip restore.
        }
      }

      ref.listenManual(appUnlockedProvider, (_, unlocked) {
        if (unlocked) {
          coordinator.onUnlocked();
          restoreAi();
        }
      });
      if (ref.read(appUnlockedProvider)) restoreAi();
      coordinator.start();
    });
  }

  @override
  void dispose() {
    _shareCoordinator?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ref.watch(themeModeProvider),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
