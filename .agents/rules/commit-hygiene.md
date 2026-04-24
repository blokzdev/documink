---
trigger: model_decision
description: Commit, PR, and git hygiene rules. Activate when preparing to commit, staging files, writing commit messages, or creating pull requests.
---

Commit and PR hygiene:

1. One feature or one phase per PR.
2. Reference the Roadmap phase in the commit message. Example: "V0 Phase 1: Flutter project scaffold".
3. Update spec docs in the same PR if the implementation revealed a spec-level issue.
4. Never commit secrets, keys, API tokens, credentials, or sample PII. The .gitignore excludes these paths by convention; do not bypass it.
5. Never commit generated build artifacts (build/, .dart_tool/, etc.).