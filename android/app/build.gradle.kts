import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release (upload-key) signing material. Read from android/key.properties for
// local builds, falling back to ANDROID_* env vars for CI (release.yml writes
// key.properties from secrets, so the file path is preferred there too).
// When NONE is present we leave release unsigned-by-upload-key and fall back to
// the debug key below, so the secret-less apk-size-check job and fork PRs still
// build. See SETUP.md. Never commit key.properties or the keystore.
val keystorePropsFile = rootProject.file("key.properties")
val keystoreProps = Properties().apply {
    if (keystorePropsFile.exists()) keystorePropsFile.inputStream().use { load(it) }
}
fun signingValue(propKey: String, envKey: String): String? =
    keystoreProps.getProperty(propKey) ?: System.getenv(envKey)

val releaseStoreFile = signingValue("storeFile", "ANDROID_KEYSTORE_PATH")
val hasReleaseSigning = releaseStoreFile != null && file(releaseStoreFile).exists()

android {
    namespace = "ai.documink.documink"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "ai.documink.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // minSdk 26 (Android 8.0): required by com.google.mlkit:entity-extraction
        // (Tier 2 detection). Raised from Flutter's default 24 — see blueprint §11
        // and docs/DECISIONS.md.
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    flavorDimensions += "environment"
    productFlavors {
        create("dev") {
            dimension = "environment"
            applicationIdSuffix = ".dev"
            resValue("string", "app_name", "DocuMink Dev")
        }
        create("staging") {
            dimension = "environment"
            applicationIdSuffix = ".staging"
            resValue("string", "app_name", "DocuMink Staging")
        }
        create("prod") {
            dimension = "environment"
            resValue("string", "app_name", "DocuMink")
            // Tier-4 (Phase 10b): the LiteRT/flutter_gemma runtime ships arm64-only
            // native libs. We do NOT set ndk.abiFilters here — when --split-per-abi
            // is NOT passed the Flutter Gradle plugin clears+overrides buildType
            // abiFilters with all default ABIs (FlutterPlugin.kt), so a flavor-level
            // filter is unioned away. The realistic per-device ABI is enforced at
            // build time instead: CI / sideload build with
            // `--target-platform android-arm64 --split-per-abi` (one arm64 APK);
            // the Play AAB keeps all ABIs and Play does per-ABI delivery (non-arm64
            // devices simply get no Tier-4 libs — graceful, isAvailable()==false).
            // See docs/reference/flutter_gemma.md (APK size) + DECISIONS.md.
        }
    }

    // Trim flutter_gemma/LiteRT native libs we don't use (~97 MB of the 146 MB
    // android_arm64 native-asset payload — measured, see docs/reference/
    // flutter_gemma.md). These .so are delivered via Flutter Native Assets
    // (hook/build.dart) but still land in jniLibs, so AGP packaging excludes
    // apply at the final merge. Kept: libLiteRtLm + StreamProxy + the Android
    // GPU/OpenCL accelerators + OpenCL TopK sampler (CPU/GPU inference path).
    // Dropped below: the qdrant_edge RAG store (we use our own memory layer),
    // the WebGPU accelerator + its TopK sampler (Linux/Windows GPU — dead weight
    // on Android), the grammar/structured-output constraint provider (we do plain
    // text generation), and the entire Qualcomm QNN NPU runtime stack (NPU is an
    // optional accelerator; the model still runs on CPU/GPU). If a real device
    // throws UnsatisfiedLinkError for one of these, drop its exclude (tracked in
    // VERIFICATION.md).
    packaging {
        jniLibs {
            excludes += listOf(
                // qdrant-edge RAG vector store (18.3 MB) — unused.
                "**/libqdrant_edge_ffi.so",
                // WebGPU GPU backend + sampler (9.0 MB) — desktop-only, dead on Android.
                "**/libLiteRtWebGpuAccelerator.so",
                "**/libLiteRtTopKWebGpuSampler.so",
                // Grammar/structured-output constraints (19.2 MB) — unused.
                "**/libGemmaModelConstraintProvider.so",
                // Qualcomm QNN NPU runtime stack (~50.7 MB) — optional accelerator.
                "**/libLiteRtDispatch_Qualcomm.so",
                "**/libQnnHtp.so",
                "**/libQnnSystem.so",
                "**/libQnnHtpV73Stub.so",
                "**/libQnnHtpV73Skel.so",
                "**/libQnnHtpV75Stub.so",
                "**/libQnnHtpV75Skel.so",
                "**/libQnnHtpV79Stub.so",
                "**/libQnnHtpV79Skel.so",
                "**/libQnnHtpV81Stub.so",
                "**/libQnnHtpV81Skel.so",
            )
        }
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                storeFile = file(releaseStoreFile!!)
                storePassword = signingValue("storePassword", "ANDROID_KEYSTORE_PASSWORD")
                keyAlias = signingValue("keyAlias", "ANDROID_KEY_ALIAS")
                keyPassword = signingValue("keyPassword", "ANDROID_KEY_PASSWORD")
            }
        }
    }

    buildTypes {
        release {
            // Sign with the upload key when signing material is present (local
            // key.properties or CI secrets via release.yml); otherwise fall back
            // to the debug key so secret-less builds (apk-size-check, fork PRs,
            // `flutter run --release`) still work. A debug-signed AAB is NOT
            // acceptable to Play — see SETUP.md.
            signingConfig = if (hasReleaseSigning) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            // R8 runs on release; ship our keep rules so the ML Kit text
            // recognizer's references to non-bundled scripts don't fail the
            // build (proguard-rules.pro). isMinifyEnabled is set explicitly so
            // the custom rules are guaranteed to apply.
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

// flutter_pdf_text pulls a runtimeOnly JPEG2000 decoder
// (com.github.Tgo1014:JP2ForAndroid) from jitpack.io for Apache PDFBox. jitpack
// 403s break every Android build (apk-size-check, Build APK, Release AAB), and we
// use flutter_pdf_text only for the text layer — JPEG2000 *image* decoding is never
// exercised (image-only pages OCR via pdfx). Dropping it removes jitpack from the
// build graph entirely; per PDFBox-Android, JPX images are then ignored with a logged
// warning and text extraction is unaffected. pdfrx consolidation (one pdfium backend,
// no jitpack) remains the path at the Flutter >=3.41 bump. See docs/DECISIONS.md.
configurations.all {
    exclude(group = "com.github.Tgo1014", module = "JP2ForAndroid")
}

flutter {
    source = "../.."
}
