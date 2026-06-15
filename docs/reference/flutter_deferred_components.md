# Flutter deferred components — reference

**Source:** https://docs.flutter.dev/perf/deferred-components — **fetched 2026-06-15.**
Vendored summary; not authoritative over `docs/` specs.

## What it is
Download additional Dart code + assets at runtime to shrink initial install. Android uses
**dynamic feature modules**; **requires building an AAB** (`flutter build appbundle`).
Debug treats deferred imports as regular; only release/profile actually defers.

## Dart usage
```dart
import 'box.dart' deferred as box;
await box.loadLibrary();        // Future<void>; completes when code is available
// all deferred symbols guarded behind a completed loadLibrary()
```
Assets-only components (no `libraries`) install via:
```dart
import 'package:flutter/services.dart';
await DeferredComponent.loadDeferredComponent('assetComponent');
```

## pubspec.yaml
```yaml
flutter:
  deferred-components:
    - name: boxComponent
      libraries:
        - package:MyApp/box.dart
      assets:
        - assets/gallery/
```
After `flutter build appbundle`, the tool generates
`deferred_components_loading_units.yaml` (track in VCS); base loading unit id `1` is implicit.

## Android setup
- `android/app/build.gradle`: `implementation("com.google.android.play:core:1.8.0")`
- `AndroidManifest`: `android:name="io.flutter.embedding.android.FlutterPlayStoreSplitApplication"`
  (or inject `PlayStoreDeferredComponentManager` via `FlutterInjector`).
- Per-component: `strings.xml` `<string name="...Name">`, a feature module under
  `android/<component>/` (its own `build.gradle` + manifest), a
  `loadingUnitMapping` meta-data in the app manifest, and `settings.gradle` `include(":<component>")`.
- Build emits recommended files under `build/android_deferred_components_setup_files/` to copy in.

## ⚠ Native libraries / plugins (the blocker for our runtime)
> "Native libraries (`.so` files for Android, plugin native code) **cannot be deferred
> individually**. They must be compiled into each dynamic feature module that uses them OR
> included in the base component."

A deferred component carries the **Dart AOT `.so` (loading unit) + assets** — not a plugin's
own native libs as a standalone split. Flutter's plugin tooling adds plugins to the **base
app** module. So moving `flutter_gemma`'s LiteRT `.so` into a feature module would require
manual Gradle work that fights Flutter's plugin injection — not a supported/first-class path.

## Local testing
```
bundletool build-apks --bundle=...app-release.aab --output=app.apks --local-testing
bundletool install-apks --apks=app.apks
```
On-demand modules deliver via Play (Play Core `SplitInstallManager`); `--local-testing`
emulates install locally.

## Constraints
AAB-only · Play-Store delivery (Play Core) · debug = no deferral · native plugin code can't be
deferred individually · modules update only with a new AAB version.
