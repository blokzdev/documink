# flutter_gemma — reference

**Source:** https://pub.dev/packages/flutter_gemma (v0.16.5, **MIT**) — **fetched 2026-06-15.**
Vendored summary; not authoritative over `docs/` specs.

## Android setup
- arm64-v8a fully supported. `x86_64`/`armeabi-v7a` work only for `.task`/`.bin` (MediaPipe
  text); **`.litertlm`, embedding FFI, and vision are arm64-only.**
  > ⚠️ **Restricting to arm64 via `ndk.abiFilters` does NOT work the way the pub.dev README
  > implies.** When you build a non-split APK/AAB, Flutter's Gradle plugin **clears and
  > overwrites** every build type's `abiFilters` with all default ABIs, so a flavor/defaultConfig
  > `abiFilters 'arm64-v8a'` is silently unioned away (see `FlutterPlugin.kt`). Enforce arm64 at
  > **build time** instead — see **APK size** below.
- Optional GPU (OpenCL) — declare in `AndroidManifest`:
  ```xml
  <uses-native-library android:name="libOpenCL.so" android:required="false"/>
  <uses-native-library android:name="libOpenCL-car.so" android:required="false"/>
  <uses-native-library android:name="libOpenCL-pixel.so" android:required="false"/>
  ```
- R8/ProGuard (plugin auto-includes, but if `UnsatisfiedLinkError`):
  ```
  -keep class com.google.mediapipe.** { *; }
  -dontwarn com.google.mediapipe.**
  -keep class com.google.protobuf.** { *; }
  -dontwarn com.google.protobuf.**
  ```
- Native libs ship via **Native Assets** (`hook/build.dart`), downloaded at build time and
  bundled into the APK automatically.

## Init
```dart
FlutterGemma.initialize(huggingFaceToken: ..., maxDownloadRetries: 10);
```

## Model install (model is NOT bundled — download/sideload)
```dart
await FlutterGemma.installModel(modelType: ModelType.gemma4)
  .fromFile('/path/to/model.litertlm')   // also .fromNetwork(url, token:) / .fromAsset / .fromBundled
  .withProgress((p) => ...)
  .install();
```
Downloads > 500 MB auto-use a foreground service (`foreground: null|true|false`).

## Formats
| Format | Notes |
|---|---|
| `.litertlm` | **newer**, LiteRT-LM, cross-platform; use `ModelFileType.task` |
| `.task` | older, MediaPipe; `ModelFileType.task` |
| `.bin`/`.tflite` | manual template / embeddings; `ModelFileType.binary` |

`ModelType.gemma4` = Gemma 4 (native function-call tokens); `ModelType.gemmaIt` = Gemma 3/3n.

## Inference
```dart
final model = await FlutterGemma.getActiveModel(maxTokens: 2048,
    preferredBackend: PreferredBackend.gpu); // .cpu / .npu(.litertlm only)
final chat = await model.openChat();              // or createSession()/createChat(systemInstruction:)
final resp = await chat.generateChatResponse();   // or .generateChatResponseAsync().listen(...)
await model.stopGeneration();
```
`Message.text(...)`, `.withImages(...)`, `.toolResponse(...)`; responses: `TextResponse.token`,
`FunctionCallResponse{name,args}`, `ThinkingResponse.content`.

## Size guidance (verbatim intent)
- "Host large models for network download rather than bundling."
- Use `fromNetwork()` + background service for post-install download (Play Asset Delivery-style).

## APK size — the real levers (measured 2026-06-15, flutter_gemma 0.16.5)

flutter_gemma's native `.so` are **not** in the plugin AAR — they're fetched at build time by
`hook/build.dart` (Flutter **Native Assets**) from GitHub Releases and registered as `CodeAsset`s.
On Android they're packed into the app's `libs.jar` (Flutter Gradle plugin `packJniLibs`) and then
merged into the APK, so **AGP `packaging.jniLibs.excludes` DOES apply to them at the final merge.**
Two things bit us; both are fixed in DocuMink:

### 1) Build one arm64 APK at build time (not via abiFilters)
The size that matters is the **per-device** download. `ndk.abiFilters` is overridden by Flutter
(see Android setup note), so enforce the ABI on the command line:
```
flutter build apk --flavor prod --release -t lib/main_prod.dart \
    --target-platform android-arm64 --split-per-abi
# → build/app/outputs/flutter-apk/app-prod-arm64-v8a-release.apk
```
`--target-platform` restricts the Dart AOT + native assets to arm64; `--split-per-abi` produces a
clean per-ABI artifact and takes the Gradle code path that does **not** do the abiFilters override.
The Play **AAB** (`flutter build appbundle`) keeps all ABIs and Play does per-ABI delivery — non-arm64
devices just get no Tier-4 libs (graceful; `isAvailable()==false`).

### 2) Exclude the native libs we don't use (`packaging.jniLibs.excludes`)
The `android_arm64` Native-Asset payload is **146.6 MB uncompressed**. Measured per-lib (from the
`native-v0.12.0-a` + `qdrant-edge-v0.7.2` tarballs):

| lib | MB | keep? |
|---|---:|---|
| `libLiteRtLm.so` (core runtime) | 37.7 | ✅ keep |
| `libGemmaModelConstraintProvider.so` (grammar/structured output) | 19.2 | ❌ drop — we do plain text gen |
| `libQnnHtpV81Skel` / V79 / V75 / V73 `.so` (Qualcomm NPU DSP code) | 11.3 / 10.5 / 10.3 / 10.3 | ❌ drop — NPU optional |
| `libLiteRtGpuAccelerator.so` (Android GPU) | 7.9 | ✅ keep |
| `libLiteRtWebGpuAccelerator.so` (Linux/Windows GPU) | 7.7 | ❌ drop — dead on Android |
| `libQnnSystem.so` / `libQnnHtp.so` (QNN runtime) | 2.8 / 2.6 | ❌ drop — NPU optional |
| `libLiteRtOpenClAccelerator.so` (Android OpenCL) | 2.5 | ✅ keep |
| `libLiteRtTopKWebGpuSampler.so` | 1.3 | ❌ drop — dead on Android |
| `libLiteRtTopKOpenClSampler.so` (OpenCL sampler) | 1.2 | ✅ keep |
| `libQnnHtpV81/79/75/73Stub.so` + `libLiteRtDispatch_Qualcomm.so` | ~2.9 | ❌ drop — NPU optional |
| `libqdrant_edge_ffi.so` (RAG vector store, separate bundle) | 18.3 | ❌ drop — own memory layer |
| `libStreamProxy.so` (streaming callback shim) | ~0 | ✅ keep |

**Kept ≈ 49 MB; dropped ≈ 97 MB.** The exact `excludes` list lives in
`android/app/build.gradle.kts`. There is **no flutter_gemma config knob** to skip individual libs —
the hook bundles every `.so` present in the tarball — so AGP packaging excludes are the lever.
Note the android tarball ships the Linux/Windows **WebGPU** libs too; they're pure dead weight on
Android and safe to drop. If a device throws `UnsatisfiedLinkError` for a dropped lib, remove that
one exclude (tracked in `VERIFICATION.md`).

> **Verify:** `unzip -l app-prod-arm64-v8a-release.apk | grep '\.so'` lists what actually shipped —
> the CI `apk-size-check` job prints this breakdown on every build.

**Result:** the trimmed arm64 release APK is enforced **< 200 MB** by the CI `apk-size-check` gate
(Play's base-APK download limit). The pre-trim universal (all-ABI) APK was 323.8 MB; switching to a
single arm64 split plus dropping ~97 MB of unused native libs brings it comfortably under.
(Sideloaded APKs have no size limit, so device testing works regardless.)

## ✅ Confirmed in-repo (Gate 0 — 2026-06-15)

- **Resolves on the pinned toolchain.** `flutter_gemma: ^0.16.5` ⇒ `flutter pub get` succeeds on
  **Flutter 3.38.6 / Dart 3.10.7** (adds 6 transitive deps). **`check_licenses.dart` is clean**
  (153 hosted packages compliant) — MIT + allow-listed transitives. Safe to depend on; no Flutter
  floor bump needed.
- **Use the Modern API** (`export 'core/api/flutter_gemma.dart'`), not the legacy
  `FlutterGemmaPlugin.instance`. Verified signatures from the pub-cache source:
  ```dart
  await FlutterGemma.initialize();                          // once at bootstrap
  await FlutterGemma.installModel(modelType: ModelType.gemma4,
      fileType: ModelFileType.task)                         // .task (Gemma 4) | .litertlm | binary
    .fromFile(modelPath).install();                          // model already downloaded+verified by us
  final InferenceModel model = await FlutterGemma.getActiveModel(
      maxTokens: 2048, preferredBackend: PreferredBackend.gpu); // .cpu/.gpu/.npu(.litertlm)
  final session = await model.createSession();
  await session.addQueryChunk(Message.text(text: prompt, isUser: true));
  final String out = await session.getResponse();            // or getResponseAsync() (Stream<String>)
  await session.close(); await model.close();
  // helpers: FlutterGemma.isModelInstalled(id), listInstalledModels(), model.stopGeneration()
  ```
- **`ModelType`**: general, gemmaIt, **gemma4**, deepSeek, qwen, qwen3, llama, hammer, functionGemma,
  phi. **`ModelFileType`**: `task` (MediaPipe templates) · `litertlm` (LiteRT-LM, Android/Desktop) ·
  `binary` (.bin/.tflite).
- **qdrant_edge** is flutter_gemma's vector-store/RAG (`searchSimilar` + `VectorStoreFilter`); we
  don't use it → `libqdrant_edge_ffi.so` is safe to exclude.
- **DocuMink wiring:** our `ModelDownloadService` (10c) fetches + SHA-256-verifies the model into
  `ModelStore`, then we hand the path to `installModel().fromFile(path)` — we do **not** use
  flutter_gemma's own downloader (verify against the signed manifest first).
