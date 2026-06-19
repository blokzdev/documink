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
- ☐ **Secure storage adapters** — `flutter_secure_storage` is now reserved for the Phase-5 biometric
  wrapped KEK (Android Keystore / Windows DPAPI); the Argon2id **salt moved to a plaintext file**
  (`vault.salt`, ADR-023). Unit tests use an in-memory fake. *(lib/services/secure_key_store.dart)*
- ☐ **Best-effort key zeroization** behaves as documented on a real run (managed-Dart caveat).
- ☐ **Vault unlock UX on device** (Phase 5e) — first-run create (passphrase + confirm) →
  `initialize` against the real **encrypted** DB; relaunch → unlock; wrong passphrase rejected;
  auto-lock after timeout returns to the unlock screen; router gate blocks all screens while locked.
  Headless tests use the plain executor; this confirms the SQLCipher-backed path end-to-end.
- ☐ **Salt-on-file brick fix (ADR-023)** — the case from the bug report: install the fixed APK →
  onboarding **create succeeds** → force-quit → relaunch → **unlock with the same passphrase works**
  (no "incorrect passcode"). Must hold on the affected Samsung/StrongBox device where the Keystore
  key was being lost. *Device:* the reporting phone.
- ☐ **Reset & start over** — on an existing vault, the unlock screen's "Reset & start over" → confirm
  → vault erased → screen returns to **create**, and a fresh passphrase creates a working vault.
- ☐ **Legacy salt migration** — an install whose salt is still in `flutter_secure_storage` (pre-ADR-023)
  unlocks after update and the salt is migrated to `vault.salt` (FSS no longer required thereafter).

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

### 12d — conversational layer (`MinkService` turn loop)

The whole loop is fake-tested headless (`test/features/mink/`, `test/features/chat/`); these
need a **real on-device model** loaded (Standard tier+) to verify behaviour with Gemma:

- ☐ **Real tool-call reliability** — Gemma 4 E2B emits well-formed `{"tool","args"}` JSON that
  `parseToolInvocation` accepts often enough to be useful (and falls back to plain answers cleanly
  when it doesn't). *Where:* chat with AI enabled; *Device:* phone at Standard+.
- ☐ **Answer quality / no PII leakage** — Mink references values as `<TYPE>`/token-refs and never
  emits decoded personal data in replies. *Device:* phone, with a redacted document in scope.
- ☐ **Latency + memory under the loop** — multi-iteration tool turns stay within the perf ceilings
  (no OOM on a mid-tier device). *Device:* phone at Standard + a Light-tier device.
- ☐ **Episodic auto-capture is tier-correct on device** — a chat turn that runs a tool writes one
  PII-safe `episode_type:'chat'` entry at Standard+, and **nothing** at Minimum/floor. *Where:*
  Settings → Mink Memory (12f) after a chat; *Device:* phone re-profiled to each tier.
- ☐ **Biometric gate, real prompt** — a tool resolving to `allow_with_biometric` triggers the OS
  biometric/credential sheet; cancelling denies the tool and audits `biometricResult:'failed'`.
  *Device:* phone with biometrics enrolled. *(decode_token's own reveal gate verified in 12e/12f.)*

### 12e — chat UI

Screen structure/navigation/send-flow are widget-tested headless (`test/ui/screens/chat_*`);
these need a **device** (real model + real navigation/rendering):

- ☐ **End-to-end chat on device** — open *Chat with Mink* (above floor, AI enabled), start a chat,
  send a message, see Mink reply with real Gemma; tool-call chips render inline. *Device:* phone.
- ☐ **Unavailable/floor banners** — below the floor or with AI off, sending shows the right banner
  ("below the AI floor" / "not enabled in Settings → AI Model") and does not hang. *Device:* a
  floor-class phone + an above-floor phone with AI disabled.
- ☐ **Masking on device** — any `<<tok_…>>` in a reply renders as `⟨hidden⟩` (never the raw marker
  or decoded value). *Device:* phone. *(Tap-to-reveal verified when `decode_token` lands.)*
- ☐ **Report-AI-output** — "Report" on a Mink message shows the local-flag snackbar and writes an
  `ai_output_reported` row visible in Settings → Audit Log; nothing leaves the device. *Device:* phone.
- ☐ **Composer/scroll behaviour** — multi-line input, send-on-enter, auto-scroll to newest, and the
  in-flight progress indicator behave on a real keyboard. *Device:* phone.

### 12f — Mink Memory inspector (Settings → Mink Memory)

List/provenance/delete are widget-tested headless (`test/ui/screens/mink_memory_screen_test.dart`);
device checks for rendering + real accumulated memory:

- ☐ **Inspector with real memory** — after some chats/actions, Settings → Mink Memory shows Core +
  Episodic split into *This project* / *Global* with correct provenance labels. *Device:* phone.
- ☐ **Delete + Forget about…** — per-entry delete (with confirm) and "Forget about a topic" remove
  the right entries and the list refreshes. *Device:* phone.
- ☐ **Export JSON** — the export dialog renders the in-scope memory and Copy puts it on the
  clipboard; no plaintext PII appears (values are token-refs). *Device:* phone.

## Proactive suggestions (Phase 13)

The deterministic engine + card + Settings toggle are fully headless-tested. The
only device-only piece is the optional **Layer-2 LLM enrichment**, which needs a
loaded Tier-4 model.

- ☐ **On-device LLM suggestion (Tier 2+)** — on a redaction where the deterministic
  rule does *not* fire (e.g. no recurring type), with a model loaded, `LlmSuggestionSource`
  may surface a context-aware card; confirm the prompt/latency are acceptable and that a
  malformed/declined generation simply shows no card (never an error). *(lib/features/suggestions/llm_suggestion_source.dart;
  real `LlmBackend` wired at bootstrap.)*
- ☐ **Card rendering + one-tap on device** — the `proactive-suggestion-card` renders correctly
  and **Apply** tokenizes the label in the real editor; **Dismiss** clears it. (Headless
  widget-tested; this confirms real rendering/gestures.)

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
- ☐ **EXIF / orientation OCR** *(audit/research)* — a **rotated** camera/gallery photo (90°/180°)
  still OCRs correctly. If rotated photos give garbled/empty text, ML Kit `fromFilePath` isn't
  honoring EXIF on this path → add EXIF-aware rotation (e.g. read orientation, pass
  `InputImageRotation`) before adding any plugin.
- ☐ **HEIC decode** *(audit/research)* — a HEIC/HEIF image (default on some Samsung cameras) OCRs;
  if `image_picker` returns HEIC-as-`.jpg` and ML Kit fails to decode, force JPEG / convert.
- ☐ **Large-image memory** *(audit/research)* — a 12+ MP photo OCRs without OOM/jank; downscale
  before OCR if needed.

**PDF import (Phase 4b)** — `InputIngestionService.importPdf()` + capture UI are headless-tested
with fakes; the native adapters need a device:
- ☐ **PDF file picker** — "Choose PDF" opens `file_selector` and returns a PDF path.
  *(lib/features/input/file_selector_pdf_source.dart)*
- ☐ **Text-layer extraction** — a born-digital PDF's text is extracted via `flutter_pdf_text`
  (PDFBox) and seeds the editor; no OCR runs (no scanned-page warning shown).
  *(lib/features/input/flutter_pdf_text_extractor.dart)*
- ☐ **JPEG2000 PDF still extracts (JP2 decoder excluded)** — a born-digital PDF that **contains a
  JPEG2000 image** still extracts its text layer cleanly after the `JP2ForAndroid` jitpack dep was
  excluded from the build (docs/DECISIONS.md 2026-06-15). PDFBox should log/ignore the JPX image,
  not crash; a page it can't extract degrades to empty → OCR fallback. *(android/app/build.gradle.kts
  exclude; lib/features/input/flutter_pdf_text_extractor.dart per-page guard)*
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
**Inbound share-sheet intent (Phase 4d)** — `ShareIntentCoordinator` routing is headless-tested
with a fake receiver; the native `ACTION_SEND` receipt needs a device:
- ☐ **Share text** — from another app (e.g. a browser/notes) → DocuMink opens the editor seeded with
  the text and auto-detects. *(receive_sharing_intent; AndroidManifest SEND text/plain)*
- ☐ **Share image** — share a photo → OCR runs → editor seeded with the recognized text.
- ☐ **Shared image `content://` path** *(audit/research)* — confirm `receive_sharing_intent` hands us
  a real filesystem path (not a raw `content://` URI) so ML Kit `fromFilePath` can read it; if not,
  copy the URI to app cache before OCR. A failure now degrades gracefully (the coordinator drops the
  share rather than crashing), but the share simply won't open until this is confirmed.
- ☐ **Malformed/failed share** *(audit)* — a share that fails OCR or is unreadable does **not** crash
  the app (coordinator guards all async paths); the share is silently dropped.
- ☐ **Share while locked** — share when the vault is locked → app shows the unlock screen, then routes
  to the editor **after** unlocking (the held-pending path). Nothing routes while locked.
- ☐ **Warm relaunch (singleTop)** — sharing again while DocuMink is already running routes the new
  share (the `getMediaStream()` path), not just the cold-start one.

## Settings persistence (Phase 5d)

- ☐ **Theme persists across restart** — `shared_preferences`-backed `SettingsStore` saves/loads the
  theme mode on a real device (Android; Windows on V2). Headless tests use the in-memory store.

## Document reveal (Phase 5, native)

- ☐ **Biometric-gated token reveal on device** (Phase 5i) — the document detail "Reveal original
  values" button triggers the real `local_auth` prompt (`LocalAuthAuthenticator`); success reveals
  plaintext, denial/cancel/no-enrollment blocks it; both outcomes audit-logged. Headless tests cover
  the decrypt-after-auth path via a fake authenticator; the real biometric prompt is device-only.

## Encrypted original-document retention (Phase 4c)

The crypto/repository/reveal core (4c-1) is unit-tested headlessly. 4c-2's data-flow + viewer need
a device:
- ☐ **Opt-in capture→retain** — with "Keep encrypted original" ON, scan/import an image or PDF →
  redact → save; confirm a `document_originals` row exists and the source file's bytes round-trip.
- ☐ **View original · biometric** — the document-detail "View original" button triggers the real
  `local_auth` prompt; success opens the viewer (image via `Image.memory`, PDF via `pdfx`);
  denial/cancel blocks it; both audited (`document_original_revealed`).
- ☐ **FLAG_SECURE** — while the original viewer is open, screenshots/screen-record are blocked and the
  app-switcher preview is obscured; the flag is **cleared** after leaving the viewer (other screens
  screenshot normally). *(MainActivity `documink/screen_security` channel.)*
- ☐ **No decrypted residue** — after closing the viewer, no decrypted original lingers (image cache
  evicted; no temp file written for image view; pdfx render temps cleaned).
- ☐ **Backgrounding** — sending the app to background while the viewer is open dismisses it.
- ☐ **Delete cascade** — deleting a document with a retained original removes the original row too.
- ☐ **Contextual notice** — the one-time "keep the original?" hint appears (when a source is in hand
  and the user hasn't decided) and does not reappear after Keep/Not-now.
- ☐ **Large-file** — a multi-MB image / multi-page PDF encrypts + reveals without OOM or jank.

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

## Tier-4 on-device AI — Gemma 4 E2B (Phase 10b)

All device-only; the runtime is `UnavailableLlmBackend` until activated. Full runbook in SETUP.md §9.
- ☐ **arm64 release APK size** — `flutter build apk --flavor prod --release` → the
  `app-prod-release.apk` is arm64-only and **under 200 MB** (Play base-APK limit). CI gate enforces.
- ☐ **Lib trim is safe** — with `qdrant_edge`/WebGPU/constraint `.so` excluded
  (`android/app/build.gradle.kts`), the model **loads + runs** with no `UnsatisfiedLinkError`. If one
  occurs, remove that single exclude and re-test.
- ☐ **Model download + verify** — Settings → On-device AI → *Download & enable*: the Gemma 4 E2B
  model downloads (progress), **SHA-256 matches** the signed manifest (fill the real hash first,
  SETUP.md §9), and `DownloadState` → ready. A tampered/mismatched hash is rejected.
- ☐ **Inference works** — the prompt tester returns a coherent response; re-prompt works; no crash.
- ☐ **Memory / latency** — no OOM on a 4 GB device (Standard tier); first-token + full-response
  latency are acceptable; backgrounding mid-generation doesn't crash.
- ☐ **GPU path** — OpenCL acceleration engages where available (`PreferredBackend.gpu`), CPU
  fallback otherwise.
- ☐ **Graceful degradation** — with AI not enabled (or on a below-Standard device), detection +
  the rest of the app work unchanged (backend stays Unavailable).

## Tier-4 UX — profiler + Settings → AI Model (Phase 11a)

Pure-Dart orchestration is fake-tested; these need a real device (the native signal collector + the
on-device model). Settings → On-device AI.
- ☐ **Real device-signal collector** — `AndroidDeviceSignalCollector` (the `documink/device_signals`
  channel) returns sane RAM / free-storage / CPU-core / OS-version values (sanity-check against the
  device's actual specs).
- ☐ **Profiler picks the expected tier** — *Check my device* selects the tier you'd expect for the
  phone (e.g. Standard on a ≥ 4 GB device); a low-RAM device/emulator lands at the floor with the
  correct reason copy.
- ☐ **Enablement persists across restart** — enable + download the model, force-quit, relaunch +
  unlock: the engine auto-restores to **ready** (no re-download) via `AiActivationService`.
- ☐ **Variant switch / tier override** — toggling Balanced↔Specialized and the tier dropdown
  downloads the right model and re-points the backend; each writes an audit row.
- ☐ **Remove model** — *Remove downloaded model* deletes the file, disables the engine, and frees the
  space; re-enable works afterwards.
- ☐ **No-silent-swap audit** — Settings → Audit Log shows `tier_change` / `variant_change` /
  `model_install` / `model_uninstall` rows for the above actions (metadata = ids/versions/score only,
  no PII).
- ☐ **Manifest-version bump** — after the signed manifest's version increases, the next unlock writes
  one `manifest_update` audit row.

## Tier-4 onboarding + floor UX (Phase 11b)

Widget-tested headless; these need a real device for the first-run flow + a11y.
- ☐ **First-run onboarding** — a freshly created vault routes **unlock → "Meet Mink"** (not Home);
  the profiler runs and shows the recommended tier. **Accept & download** lands at Home with the model
  ready; **Skip** lands at Home with AI off; **Show options** lets you pick Specialized / an opt-in
  tier before downloading.
- ☐ **No re-prompt** — after onboarding (accept or skip), relaunch + unlock goes **straight to Home**
  (the profiler has run; the step isn't shown again).
- ☐ **Floor onboarding** — on a below-floor device the step shows the honest floor reason + **Continue**
  (+ Re-check), no download.
- ☐ **Home floor gating** — on a below-floor device the **"Chat with Mink"** card is **visibly disabled
  (greyed, lock icon), not hidden**; TalkBack announces it as disabled with the "Needs a more capable
  device" reason; all other actions stay enabled.
- ☐ **Recovery** — "Re-check my device" after freeing RAM/storage re-qualifies and re-enables the
  Mink surfaces.

## Projects & templates — AI-scaffolded creation (Path B, Phase 14d)

Headless here: the orchestrator branching, scaffold manifest, personal-template store, and the
screen structure are unit/widget-tested with fakes. These need a device with a loaded Tier-4 model
and the real file picker:

- ☐ **Real upload** — `Create from a document` → the native file picker opens; pick a PDF; text is
  extracted (text layer + OCR fallback for scanned pages) — *what:* `InputIngestionService.importPdf`,
  *where:* upload→scaffold screen, *device:* Android with a file + camera/ML Kit for OCR.
- ☐ **On-device classification + branching** — with a loaded model, a clearly-medical/legal/etc.
  document yields a **strong** match (correct Verified template pre-selected); an ambiguous one yields
  **weak** candidates; an out-of-catalog domain yields the **AI-scaffolded** review; below-floor / no
  model yields the **fallback** to picker/wizard. (Inference *quality* is only observable on-device.)
- ☐ **AI-scaffolded create + badge** — creating from the no-match branch produces an `ai_scaffolded`
  project that is **badged** in project detail and never shown as Verified (§15 #22).
- ☐ **Document import lands in the project** — after create, the uploaded text opens in the redaction
  editor; on save the document appears under the **new project's Documents tab** (active-project
  scoping), not the global workspace.
- ☐ **Personal templates** — `Save as personal template` (from the scaffold prompt or project
  settings) makes the template appear under **"Yours"** in the picker; creating from it reproduces the
  setup. (Round-trips through the encrypted vault — exercise on a real SQLCipher build.)

## Audit log transparency (Phase 15b)

Headless here: filters, pagination, label mapping, and the CSV-export action (over the active filter,
flag-gated) are widget/unit-tested. This needs a device:

- ☐ **Native CSV file share** — the export dialog currently copies CSV to the clipboard (no Phase-7
  share stack yet). When the share stack lands, route export through it and confirm a real file share
  on-device — *where:* Settings → Audit log → Export, *device:* Android share sheet.

## UI / accessibility (Phases 5, 16)

- ☐ **Screens render** correctly on device (home/editor/preview/vault/settings); dark mode.
- ☐ **FLAG_SECURE** blocks screenshots/recents on vault screens.
- ☐ **a11y** — TalkBack passthrough, dynamic type to 200%, contrast 4.5:1 / 3:1, ≥48 dp targets.

## Launch (Phase 17)

- ☐ **Third-party security audit** (keys, vault, sync crypto, manifest signing, tool
  dispatch, project isolation, model runtime). Privacy policy live; Data Safety form filed.
