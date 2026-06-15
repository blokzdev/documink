# flutter_gemma — reference

**Source:** https://pub.dev/packages/flutter_gemma (v0.16.5, **MIT**) — **fetched 2026-06-15.**
Vendored summary; not authoritative over `docs/` specs.

## Android setup
- arm64-v8a fully supported. `x86_64`/`armeabi-v7a` work only for `.task`/`.bin` (MediaPipe
  text); **`.litertlm`, embedding FFI, and vision are arm64-only.** Restrict:
  ```gradle
  android { defaultConfig { ndk { abiFilters 'arm64-v8a' } } }
  ```
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
- Native runtime libs (arm64) are large (~110 MB+): libLiteRtLm ~34 MB, libLiteRt ~10 MB,
  WebGPU accelerator ~18 MB + TopK sampler ~4 MB, GemmaModelConstraintProvider ~22 MB,
  qdrant_edge (RAG) ~23 MB. WebGPU/qdrant/constraint are candidates to exclude when unused.

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
