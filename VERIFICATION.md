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

## Input handlers (Phase 4 — native; build pending)

- ☐ **Camera capture + OCR**, **image import** (JPG/PNG/HEIC picker), **PDF import**
  (text-layer extraction + per-page OCR). *(to be added when Phase 4 is built)*

## Settings persistence (Phase 5d)

- ☐ **Theme persists across restart** — `shared_preferences`-backed `SettingsStore` saves/loads the
  theme mode on a real device (Android; Windows on V2). Headless tests use the in-memory store.

## UI / accessibility (Phases 5, 16)

- ☐ **Screens render** correctly on device (home/editor/preview/vault/settings); dark mode.
- ☐ **FLAG_SECURE** blocks screenshots/recents on vault screens.
- ☐ **a11y** — TalkBack passthrough, dynamic type to 200%, contrast 4.5:1 / 3:1, ≥48 dp targets.

## Launch (Phase 17)

- ☐ **Third-party security audit** (keys, vault, sync crypto, manifest signing, tool
  dispatch, project isolation, model runtime). Privacy policy live; Data Safety form filed.
