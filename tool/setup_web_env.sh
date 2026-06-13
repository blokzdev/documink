#!/usr/bin/env bash
# Provision the Flutter toolchain for DocuMink in a bare (web/remote) session.
#
# Idempotent, non-interactive, and safe to run manually on any Linux box.
# Degrades gracefully: if downloads are blocked by the environment's network
# policy, it logs a clear message and exits 0 so it never breaks a session --
# the gates simply remain unavailable (run them in CI or on the dev machine).
#
# Pinned to the reference toolchain (Flutter 3.38.6 / Dart 3.10.7). Do NOT bump
# the channel/version to work around codegen issues -- see .agents/rules/dart-toolchain.md.
set -uo pipefail

FLUTTER_VERSION="3.38.6"
FLUTTER_DIR="${FLUTTER_HOME:-$HOME/flutter}"
REPO_DIR="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

log() { echo "[setup_web_env] $*"; }

# --- 1. Flutter SDK (pinned) ------------------------------------------------
if command -v flutter >/dev/null 2>&1; then
  log "flutter already on PATH: $(command -v flutter)"
else
  if [ ! -x "$FLUTTER_DIR/bin/flutter" ]; then
    log "Cloning Flutter $FLUTTER_VERSION into $FLUTTER_DIR ..."
    if ! git clone --depth 1 -b "$FLUTTER_VERSION" https://github.com/flutter/flutter.git "$FLUTTER_DIR"; then
      log "WARNING: Flutter clone failed (network policy?). Toolchain NOT provisioned; gates unavailable."
      exit 0
    fi
  fi
  export PATH="$FLUTTER_DIR/bin:$PATH"
fi

# Persist PATH for the rest of the Claude Code session, if available.
if [ -n "${CLAUDE_ENV_FILE:-}" ]; then
  echo "export PATH=\"$FLUTTER_DIR/bin:\$PATH\"" >> "$CLAUDE_ENV_FILE"
fi

# --- 2. Warm the toolchain (first run fetches the Dart SDK + engine) --------
if ! flutter --version; then
  log "WARNING: 'flutter --version' failed (engine/Dart download blocked?). Gates unavailable."
  exit 0
fi
flutter config --no-analytics >/dev/null 2>&1 || true

# --- 3. Project dependencies ------------------------------------------------
if ! ( cd "$REPO_DIR" && flutter pub get ); then
  log "WARNING: 'flutter pub get' failed."
fi

# --- 4. Activate repo git hooks (pre-commit: dart format + flutter analyze) --
( cd "$REPO_DIR" && git config core.hooksPath .githooks ) || true

# --- 5. Best-effort Android SDK so 'flutter build apk' can run (non-fatal) ---
# analyze / test / scanners / build_runner all work WITHOUT this section.
if command -v sdkmanager >/dev/null 2>&1 || [ -n "${ANDROID_SDK_ROOT:-}${ANDROID_HOME:-}" ]; then
  log "Android SDK already present; 'flutter build apk' should be available."
else
  log "Android SDK not configured -- 'flutter build apk' will be unavailable in this session."
  log "      (analyze, test, scanners, and build_runner do not need it.)"
fi

log "Done. Toolchain ready: $(flutter --version 2>/dev/null | head -1)"
