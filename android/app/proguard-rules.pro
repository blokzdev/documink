# R8/ProGuard keep rules for release builds.

# google_mlkit_text_recognition (Phase 4 OCR): we bundle only the Latin script
# recognizer (TextRecognitionScript.latin). The plugin's initializer statically
# references the Chinese / Devanagari / Japanese / Korean recognizer option
# classes too, so R8 reports them as "missing" and fails the release build.
# We never instantiate those recognizers, so it is safe to tell R8 not to warn
# on the absent references. (Adding those scripts' artifacts instead would bloat
# the APK with models we don't use.)
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**

# Keep the Latin recognizer we DO use (the plugin ships no consumer R8 rules —
# flutter-ml/google_ml_kit_flutter#744 — so be explicit).
-keep class com.google.mlkit.vision.text.latin.** { *; }

# flutter_gemma / MediaPipe LiteRT (Phase 10b on-device LLM). The plugin's own
# consumer rules keep the MediaPipe/protobuf classes, but R8 still errors on
# optional references absent from the release classpath (auto-value @Memoized;
# MediaPipe profiling/template protos). We don't exercise those paths; suppress
# the missing-class errors and keep the JNI-invoked runtime classes.
-dontwarn com.google.auto.value.**
-dontwarn com.google.mediapipe.**
-keep class com.google.mediapipe.** { *; }
-keep class com.google.protobuf.** { *; }
-dontwarn com.google.protobuf.**
