---
trigger: always_on
---

Dart 3.10 + build_runner toolchain rule. Never violate without explicit user approval:

1. ALL `build_runner` invocations MUST use `--force-jit`.

   Correct:   dart run build_runner build --force-jit --delete-conflicting-outputs
   Correct:   dart run build_runner watch --force-jit
   Incorrect: dart run build_runner build --delete-conflicting-outputs

   Reason: `build_runner` defaults to AOT-precompiling its builder
   bundle. `dart compile` refuses to AOT-compile any project whose
   dependency tree contains Dart 3.10 Build Hooks packages. Our tree
   pulls hooks transitively via drift → sqlite3 → native_toolchain_c
   and will continue to as more ecosystem packages adopt hooks.
   `--force-jit` skips AOT precompile and uses JIT mode instead.

   Upstream bug: dart-lang/build#4343. When that issue is closed and
   a fixed build_runner is released, this rule can be relaxed.

2. If a code generation step fails with the exact message
   `'dart compile' does not support build hooks, use 'dart build'
   instead`, it is this issue. Add `--force-jit` and retry. Do not
   downgrade dependencies, do not pin versions, do not switch Dart
   or Flutter channels.

3. This rule applies to any codegen package — drift_dev today,
   freezed / json_serializable / riverpod_generator / etc. when
   added later.