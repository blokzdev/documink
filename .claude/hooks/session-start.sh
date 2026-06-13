#!/bin/bash
# SessionStart hook: provision the Flutter toolchain in Claude Code web sessions
# so analyze / test / scanners / build_runner / apk-build can run.
#
# Only runs in remote (web) sessions; local developers use their own installed
# toolchain. The heavy lifting lives in tool/setup_web_env.sh (also runnable by
# hand) and degrades gracefully if downloads are blocked.
set -uo pipefail

# Local sessions already have a toolchain -- do nothing.
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

REPO_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
bash "$REPO_DIR/tool/setup_web_env.sh"
