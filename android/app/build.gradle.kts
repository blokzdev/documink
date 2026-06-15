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
            // Tier-4 (Phase 10b): the LiteRT/flutter_gemma runtime (.litertlm /
            // FFI / vision) is arm64-only, so prod ships a single ABI. This keeps
            // the on-device-AI build under Play's ~200 MB base limit without a
            // dynamic feature module (Flutter can't defer a plugin's native libs
            // — see docs/reference/flutter_deferred_components.md + DECISIONS.md).
            // dev/staging keep all ABIs for emulator work.
            ndk { abiFilters += "arm64-v8a" }
        }
    }

    // Drop flutter_gemma/LiteRT native libs we don't use, to shrink the APK:
    // the qdrant_edge RAG vector store, and the WebGPU accelerator + constraint
    // provider (we use CPU/GPU(OpenCL) inference, not WebGPU or grammar
    // constraints). If a real device throws UnsatisfiedLinkError for one of
    // these, remove its exclude (tracked in VERIFICATION.md).
    packaging {
        jniLibs {
            excludes += listOf(
                "**/libqdrant_edge_ffi.so",
                "**/libLiteRtWebGpuAccelerator.so",
                "**/libLiteRtTopKWebGpuSampler.so",
                "**/libGemmaModelConstraintProvider.so",
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

flutter {
    source = "../.."
}
