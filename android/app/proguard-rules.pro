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
