# VERIFICATION — on-device / native checks to run on the side

The agent develops in a bare Linux container where `flutter analyze`, `flutter
test` (incl. **widget tests**), and the CI scanners run, but there is **no
Android SDK, emulator, or device**. Anything that needs native platform channels,
an encrypted-SQLite build, real rendering, models, or hardware is **not** claimed
as "passing" — it is logged here for you to verify on a device or your Windows box.

**Legend:** ☐ not yet verified · ☑ verified (add date + device).
**Standing rule (CLAUDE.md):** every phase that defers something to device adds
an item here in the same PR.

---

## Build & release (this enablement PR)

- ☐ **Manual APK build** — Actions → *Build APK (manual)* produces an installable
  `documink-prod-release-apk`; installs and launches on your phone. *(SETUP.md §1)*
- ☐ **Local signed AAB** — `flutter build appbundle --flavor prod --release` with
  `android/key.properties` present produces an upload-key-signed `.aab`. *(SETUP.md §3)*
- ☐ **CI signed AAB** — pushing a `v*` tag with the 4 secrets set makes
  *Release (signed AAB)* emit a properly signed `.aab` (not debug-signed). *(SETUP.md §4–5)*
- ☐ **Gradle debug fallback** — release build with NO key.properties/secrets still
  builds (debug-signed) so `apk-size-check` stays green. *(android/app/build.gradle.kts)*
- ☐ **Play App Signing enrolled** — first AAB accepted on an Internal testing track. *(SETUP.md §6)*

## Vault / crypto (Phase 1)

- ☐ **SQLCipher integration test (gated)** — `test/services/vault_service_test.dart`
  `group('SQLCipher integration (gated)')` is `markTestSkipped` headless; runs green
  where the encrypted native build is linked (Android device / Windows). Confirms
  `PRAGMA key`/cipher open + DEK unwrap on a real encrypted DB.
- ☐ **Secure storage adapters** — `flutter_secure_storage` reads/writes the Argon2id
  salt + wrapped KEK via Android Keystore (and Windows DPAPI on V2). Unit tests use
  an in-memory fake. *(lib/services/secure_key_store.dart)*
- ☐ **Best-effort key zeroization** behaves as documented on a real run (managed-Dart caveat).
- ☐ **Vault unlock UX on device** (Phase 5e) — first-run create (passphrase + confirm) →
  `initialize` against the real **encrypted** DB; relaunch → unlock; wrong passphrase rejected;
  auto-lock after timeout returns to the unlock screen; router gate blocks all screens while locked.
  Headless tests use the plain executor; this confirms the SQLCipher-backed path end-to-end.

## Detection (Phase 2)

- ☐ **Tier 2 ML Kit** — `MlKitEntityRecognizer`/`MlKitAnnotator` download the English
  entity model and return spans on-device; composed at bootstrap, not in headless tests.
  *(lib/features/detection/recognizers/mlkit_annotator.dart)*
- ☐ **Tier 3 GLiNER (ONNX)** — bundled-baseline model loads via the ONNX runtime and
  produces PII spans on a capable device. *(ADR-022; detection_providers.dart)*

## Profiler / models (Phases 9–11)

- ☐ **Device signal collectors** — Android (`ActivityManager`, `StatFs`, …) adapters feed
  `ProfilerService` real signals; Windows collectors on V2. *(lib/features/llm/device_signal_collector.dart)*
- ☐ **Tier-4 model download + verify** — signed-manifest fetch, SHA-256 verify, resume.
- ☐ **Tier-4 inference + benchmark gate** — per `docs/models.md` on reference devices
  (Pixel 6/9, Galaxy A, 2–3 GB emulator); release gate: F1 drop >2 pts OR latency +30%.

## Mink / memory (Phase 12)

- ☐ **LLM inference in chat** — streaming responses via `flutter_gemma`/`fllama` on device.
- ☐ **Tool dispatch + biometric gate** — `decode_token` prompts biometric; permission
  denials surface transparently and audit-log `permission_denied`.

## Sync transport (Phase 8 — beyond crypto core)

- ☐ **BYOC Google Drive** OAuth + encrypted delta push/pull.
- ☐ **LAN sync** — mDNS discovery, QR pairing, TLS-pinned WebSocket; second-device onboarding.
- ☐ **cr-sqlite CRDT merge** at the SQLite layer; hard conflicts surface in Settings → Sync Conflicts.

## Input handlers (Phase 4 — native)

Headless tests cover the pure-Dart `InputIngestionService` + the capture UI via fake
`OcrRecognizer` / `ImageInputSource`. The native adapters are wired at bootstrap and need a
device:

- ☐ **Camera permission prompt** — first Scan shows the runtime CAMERA permission rationale;
  denial is handled gracefully (no crash). *(AndroidManifest CAMERA; image_picker)*
- ☐ **Camera capture → OCR** — `MlKitTextRecognizer` recognizes text from a captured page;
  the recognized text appears on the capture screen and seeds the redaction editor.
  *(lib/features/input/mlkit_text_recognizer.dart)*
- ☐ **ML Kit Latin model bundled** — OCR works **offline on first launch** (the
  `com.google.mlkit.vision.DEPENDENCIES=ocr` meta-data installs the model with the app).
- ☐ **Image import** — system photo picker returns an image; **JPG / PNG / HEIC** all decode
  and OCR (HEIC is the iOS/modern-Android format most likely to surprise).
  *(lib/features/input/system_image_source.dart)*
- ☐ **OCR quality** — recognized text on a real document is good enough that Tier-1 detection
  finds the PII (spot-check email/phone/SSN on a sample doc).
- ☐ **End-to-end scan→redact** (PRD §7.2) — scan a page → review recognized text → "Redact this
  text" → detection + operators → save to vault.
- ☐ **Gallery from scan** — the Scan screen's "Choose from gallery" opens the picker and OCRs the
  chosen photo (same path as Import). *(lib/features/input/system_image_source.dart)*

**PDF import (Phase 4b)** — `InputIngestionService.importPdf()` + capture UI are headless-tested
with fakes; the native adapters need a device:
- ☐ **PDF file picker** — "Choose PDF" opens `file_selector` and returns a PDF path.
  *(lib/features/input/file_selector_pdf_source.dart)*
- ☐ **Text-layer extraction** — a born-digital PDF's text is extracted via `flutter_pdf_text`
  (PDFBox) and seeds the editor; no OCR runs (no scanned-page warning shown).
  *(lib/features/input/flutter_pdf_text_extractor.dart)*
- ☐ **Scanned-PDF OCR fallback** — an image-only PDF rasterizes each page via `pdfx` and OCRs it;
  the "Page N was scanned — used OCR" warning shows. *(lib/features/input/pdfx_page_rasterizer.dart)*
- ☐ **Multi-page** — a multi-page PDF concatenates with `--- Page N ---` markers; the source badge
  shows the page count.
- ☐ **Large-PDF performance** — PRD §8.1 budget: a 10-page document processes within ~15 s; watch
  memory on rasterize+OCR of many scanned pages.
- ☐ **APK size** — confirm the 3 new plugins (flutter_pdf_text/PDFBox, pdfx, file_selector) keep
  the base APK under the 150 MB ceiling (CI `apk-size-check` covers this on every build).
- ☐ **No PII page-images linger** — after a scanned-PDF import, the app cache dir
  (`getTemporaryDirectory()`) holds **no leftover `pdf_page_*.png`** files; OCR still succeeds.
  (Delete-after-use is unit-asserted via a fake disposer; this confirms the real deletion on device.)
- ☐ **Inbound share-sheet intent** *(tracked follow-up — next PR)* — receiving text/images shared
  from another app into DocuMink.

## Settings persistence (Phase 5d)

- ☐ **Theme persists across restart** — `shared_preferences`-backed `SettingsStore` saves/loads the
  theme mode on a real device (Android; Windows on V2). Headless tests use the in-memory store.

## Document reveal (Phase 5, native)

- ☐ **Biometric-gated token reveal on device** (Phase 5i) — the document detail "Reveal original
  values" button triggers the real `local_auth` prompt (`LocalAuthAuthenticator`); success reveals
  plaintext, denial/cancel/no-enrollment blocks it; both outcomes audit-logged. Headless tests cover
  the decrypt-after-auth path via a fake authenticator; the real biometric prompt is device-only.

## Export (Phase 7 — native share/save)

- ☐ **Share / save exported artifacts** — wire the OS **share sheet** + file save for the redacted
  `.txt` / JSON (e.g. `share_plus` / file picker) on a device; confirm the redacted output leaves via
  the share intent and is audited. Headless tests cover content generation + the in-app copy action.
- ☐ **PNG/PDF export rendering** — redacted image/PDF artifacts (native graphics) when those input
  types land (Phase 4).

## UI design elevation (visual review — device/screenshots)

The headless container can't render pixels; structure is widget-tested but **aesthetics need eyes**.
After each UI-elevation PR, pull **Build APK (manual)** and review:

- ☐ **Design system (L1)** — Ink-Indigo light **and** dark look right; brandmark renders crisply;
  text hierarchy/contrast (WCAG AA) reads well; component themes (cards/inputs/buttons/dialogs)
  consistent across screens.
- ☐ **Per-screen visual review (L2–L5)** — Home, unlock, editor (entity chips colour-coded + mono
  preview), vault browser cards, document detail (reveal animation), settings, audit — each in
  light/dark, at large dynamic-type, with TalkBack.

## UI / accessibility (Phases 5, 16)

- ☐ **Screens render** correctly on device (home/editor/preview/vault/settings); dark mode.
- ☐ **FLAG_SECURE** blocks screenshots/recents on vault screens.
- ☐ **a11y** — TalkBack passthrough, dynamic type to 200%, contrast 4.5:1 / 3:1, ≥48 dp targets.

## Launch (Phase 17)

- ☐ **Third-party security audit** (keys, vault, sync crypto, manifest signing, tool
  dispatch, project isolation, model runtime). Privacy policy live; Data Safety form filed.
