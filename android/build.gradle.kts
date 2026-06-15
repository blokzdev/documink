allprojects {
    repositories {
        google()
        mavenCentral()
    }
    // flutter_pdf_text declares a runtimeOnly JPEG2000 decoder
    // (com.github.Tgo1014:JP2ForAndroid) from jitpack.io for Apache PDFBox. jitpack
    // 403s break every Android build, and we use the plugin only for the text layer —
    // JPEG2000 *image* decoding is never exercised (image-only pages OCR via pdfx).
    // Excluding it here (across :app AND the :flutter_pdf_text module, hence
    // allprojects — the plugin's own lint classpath resolves it otherwise) removes
    // jitpack from the build graph entirely. PDFBox then ignores JPX images; the now-
    // dangling com.gemalto.jp2.JP2Decoder reference is suppressed in app/proguard-
    // rules.pro so R8 doesn't fail. pdfrx consolidation (one pdfium backend, no
    // jitpack) remains the path at the Flutter >=3.41 bump. See docs/DECISIONS.md.
    configurations.all {
        exclude(group = "com.github.Tgo1014", module = "JP2ForAndroid")
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
