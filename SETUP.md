# SETUP — what I need from you (Android build, signing & Play Store)

This is the running runbook for everything the agent needs **you** to do on your
Windows laptop (things involving secrets/keys the agent must never hold). It is
kept current as the release setup evolves. Commands are PowerShell unless noted.

> **Privacy/security note:** the agent never creates or commits keystores,
> passwords, or service-account files. You generate and keep those. Everything
> here that is a secret is gitignored (`android/key.properties`, `*.jks`, …).

---

## 0. TL;DR checklist

- [ ] **Install a test APK on your phone now** — no setup needed (§1).
- [ ] Generate an **upload keystore** (`.jks`) and keep it safe (§2).
- [ ] Create local **`android/key.properties`** for local release builds (§3).
- [ ] Add **4 GitHub secrets** so CI can sign release AABs (§4).
- [ ] Create the app in **Play Console**, enroll **Play App Signing** with your first AAB (§5–6).
- [ ] *(Later)* add a **Play service account** for automated upload (§7).

---

## 1. Get a test APK on your phone (available right now)

No keys needed — this is a debug-signed build, fine for sideloading.

1. GitHub → **Actions** tab → **Build APK (manual)** workflow → **Run workflow**
   (pick the branch, usually `main`) → wait for it to finish.
2. Open the finished run → **Artifacts** → download **`documink-prod-release-apk`**.
3. Unzip → copy `app-prod-release.apk` to your phone.
4. On the phone: tap the file → allow "install unknown apps" for your file
   manager when prompted → install.

> This APK is **debug-signed** — perfect for testing, **not** for Play Store.
> Play Store builds are signed AABs (below).

---

## 2. Generate the upload keystore (one time)

You need a JDK's `keytool`. Easiest source: the JDK bundled with Android Studio
(JBR) or Flutter. If `keytool` isn't on PATH, use the full path, e.g.
`"$env:JAVA_HOME\bin\keytool.exe"` or the Android Studio JBR at
`"C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe"`.

```powershell
# Creates documink-upload-keystore.jks in your user profile. Pick strong, DISTINCT
# passwords for the store and the key. Validity must be long (Play requires >2050).
keytool -genkeypair -v `
  -keystore "$env:USERPROFILE\documink-upload-keystore.jks" `
  -storetype JKS `
  -keyalg RSA -keysize 2048 -validity 10000 `
  -alias documink-upload
```

It will prompt for: keystore password, key password (can match store password),
and a name/org ("CN", "O", etc. — any sensible values).

**Back this file up somewhere safe** (password manager / encrypted drive). If you
lose it before enrolling Play App Signing you cannot publish updates; after
enrolling, you can reset the upload key via Play support, but keep it safe anyway.

---

## 3. Create `android/key.properties` (for local release builds)

Only needed if you want to build a signed AAB **locally** (CI uses secrets, §4).

```powershell
# From the repo root. Escapes the backslashes in the path. Fill in YOUR passwords.
@"
storeFile=$($env:USERPROFILE -replace '\\','\\')\\documink-upload-keystore.jks
storePassword=YOUR_STORE_PASSWORD
keyAlias=documink-upload
keyPassword=YOUR_KEY_PASSWORD
"@ | Set-Content -Encoding ASCII android\key.properties
```

Then build locally:

```powershell
flutter build appbundle --flavor prod --release -t lib/main_prod.dart
# Output: build\app\outputs\bundle\prodRelease\app-prod-release.aab
```

`android/key.properties` and `*.jks` are gitignored — never commit them.

---

## 4. Add the 4 GitHub secrets (so CI signs releases)

Base64-encode the keystore, then add four repository secrets.

```powershell
# Produces keystore.b64.txt (gitignored). Copy its full contents.
[Convert]::ToBase64String([IO.File]::ReadAllBytes("$env:USERPROFILE\documink-upload-keystore.jks")) `
  | Set-Content -Encoding ASCII keystore.b64.txt
```

Add the secrets — **GitHub UI**: repo → Settings → Secrets and variables →
Actions → **New repository secret**, for each of:

| Secret name | Value |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | contents of `keystore.b64.txt` |
| `ANDROID_KEYSTORE_PASSWORD` | your keystore (store) password |
| `ANDROID_KEY_ALIAS` | `documink-upload` |
| `ANDROID_KEY_PASSWORD` | your key password |

**Or with the `gh` CLI:**

```powershell
gh secret set ANDROID_KEYSTORE_BASE64   < keystore.b64.txt
gh secret set ANDROID_KEYSTORE_PASSWORD --body "YOUR_STORE_PASSWORD"
gh secret set ANDROID_KEY_ALIAS         --body "documink-upload"
gh secret set ANDROID_KEY_PASSWORD      --body "YOUR_KEY_PASSWORD"
```

Then delete `keystore.b64.txt`.

---

## 5. Cut a signed release build

```powershell
# Version comes from pubspec.yaml `version:` (e.g. 1.0.0+1 → versionName 1.0.0, versionCode 1).
git tag v1.0.0-alpha.1
git push origin v1.0.0-alpha.1
```

This triggers the **Release (signed AAB)** workflow → download the
**`documink-prod-release-aab`** artifact from the run. (You can also run that
workflow manually from the Actions tab.)

> If the four secrets aren't set yet, the workflow still runs but produces a
> **debug-signed** AAB (Play will reject it). Set the secrets first.

---

## 6. Play Console — first upload & Play App Signing

1. Create the app in **Google Play Console** (you need a Play Developer account,
   one-time \$25). App name: DocuMink. Package name: **`ai.documink.app`**
   (must match `applicationId` — this is permanent).
2. Create an **Internal testing** release, upload the `.aab` from §5.
3. On first upload Play offers **Play App Signing** — **accept it**. Google then
   holds the app signing key; your `.jks` is only the *upload* key.
4. Add yourself as an internal tester → install via the opt-in link on your phone.

> Full store listing (screenshots, description, Data Safety form, privacy policy
> at documink.ai/privacy) is roadmap **Phase 17 (Launch prep)** — not needed for
> internal testing.

---

## 7. (Later) Automated Play upload

When you want pushes to a tag to upload straight to a Play track, create a Play
**service account** (Play Console → API access), grant it release permissions,
download its JSON, add it as secret `PLAY_SERVICE_ACCOUNT_JSON`, and tell the
agent — it will add an upload step (`r0adkll/upload-google-play`) to `release.yml`.
Not set up yet; ask when you're ready.

---

## 9. Verify the on-device AI engine (Gemma 4 E2B) — device session

The Tier-4 runtime (LiteRT via `flutter_gemma`) ships in the base APK, **arm64-only +
trimmed** (no dynamic feature module — see `docs/models.md` §2.4). The model is **downloaded
on demand**, not bundled. The agent built it behind seams + got CI green but **cannot build an
APK or run inference** — do this on your Windows laptop + an **arm64 Android phone** (≥ 4 GB RAM
for Standard tier). Report results so the agent can iterate.

1. **Toolchain:** `flutter --version` (3.38.6), `flutter doctor` (Android SDK/NDK OK), `flutter pub get`.
2. **Build the test APK** (arm64 prod release; debug-signed is fine for sideload):
   ```powershell
   flutter build apk --flavor prod --release -t lib/main_prod.dart
   # → build/app/outputs/flutter-apk/app-prod-release.apk
   ```
   Confirm size **< 200 MB**. Install: `adb install -r build/app/outputs/flutter-apk/app-prod-release.apk`.
3. **Host the model + fill the manifest** (one-time): obtain the Gemma 4 E2B file
   (`.task` `google/gemma-4-e2b-it-task`, or `.litertlm` `litert-community/gemma-4-E2B-it-litert-lm`
   — set `ModelFileType` to match in `FlutterGemmaLlmBackend`), host it at an HTTPS URL, then in
   `assets/model_manifest/manifest.json` set the Standard→Balanced variant's `url` + real `sha256`
   (`Get-FileHash -Algorithm SHA256 model.task`), re-sign with the **production** key
   (`dart run tool/scripts/sign_manifest.dart`), and pin the printed public key in `ManifestVerifier`.
   *(For a quick spike you can point `url` at the HuggingFace `resolve/main/...` file directly.)*
4. **On the phone:** unlock the vault → **Settings → On-device AI → Download & enable**. Watch the
   progress; it should reach **ready** (download + SHA-256 verify + load).
5. **Test inference:** type a prompt → **Run** → confirm a coherent response; try a few; watch for
   OOM / latency. If a native lib is missing (`UnsatisfiedLinkError` in `adb logcat`), tell the agent
   which `.so` — it'll drop that `excludes` entry in `android/app/build.gradle.kts`.
6. **Report:** APK size, download+verify result, a sample prompt/response, rough latency, and any
   crash logs. Tick the items in `VERIFICATION.md` → *Tier-4 on-device AI*.

> Secrets stay with you: the production manifest signing key and any model-hosting credentials are
> never held or committed by the agent.

## Versioning reference

`pubspec.yaml` → `version: 1.0.0+1`. The part before `+` is `versionName`
(user-visible), after `+` is `versionCode` (must increase every Play upload).
Bump it before each release.
