# Phase 13 — Proactive suggestions (V1 scoped) — plan

> **Status:** planning (this doc) → implementation in sub-PRs 13a–13d.
> **Specs:** PRD §5.2 (reactive proactive suggestions) · blueprint §5.5 + §15 #20/#21 · roadmap Phase 13.
> **Precedent patterns:** the `keep-original` opt-in toggle + one-time in-context hint card
> (`lib/features/documents/keep_original_setting.dart`, `lib/ui/screens/paste_editor_screen.dart`),
> the Mink seam/orchestrator style (`lib/features/mink/`), and `MinkTurnContext`
> (`lib/features/chat/chat_providers.dart`).

This is the first per-phase `Pxx-PLAN.md` (a new convention introduced at the maintainer's
request — DocuMink previously kept plans in README/roadmap/DECISIONS only). It is the design
of record for Phase 13; each sub-PR is planned in detail as it is built.

---

## 1. What we're building

After a user **completes an action**, DocuMink surfaces **one compact, in-context,
dismissible suggestion card** offering a relevant **one-tap follow-up** — the PRD's flagship
example: *"This document has 47 instances of <PERSON> — tokenize them all consistently?"*

Trigger moments (blueprint §5.5):
- **post-scan** completion (captured/OCR'd text lands in the editor and auto-detects),
- **post-detection** on pasted text,
- **post-redaction** application (save).

All three converge in the **paste-and-redact editor** flow, which is where the card renders.

V1 constraints (hard): in-context only (**never** a push notification), **no background
processing** (only on the awaited completion of a user action), dismissible, a Settings toggle
to disable entirely, and **audit-logged** when offered / actioned / dismissed.

## 2. Key decisions (maintainer-confirmed 2026-06-15)

1. **Initial state: ON (opt-out)** with a **one-time disclosure** rendered inside the first
   suggestion card ("Mink can offer follow-up tips — turn off in Settings"). This honors
   blueprint §15 #20's *non-intrusive* intent (the card is post-action, single, dismissible,
   never a notification) while matching PRD's "user setting to disable entirely" framing.
2. **Deterministic-first, two-layer engine.** A pure-Dart **deterministic rules engine**
   (Layer 1) leads and runs on **every tier — including below-floor / Minimum** where there is
   no LLM. An **optional LLM enrichment source** (Layer 2) adds context-aware suggestions only
   when the on-device model is available (Tier 2+). Both go through one `Suggestion` interface
   and the same action whitelist. (See §3 — refines blueprint §5.5/roadmap, which read
   "asks the LLM".)
3. **One-tap = real deterministic mutation** (not display-only). Accept performs the safe,
   bounded action — e.g. `PasteEditorController.setOperator(label, Operator.tokenRandom)`.

## 3. Spec refinement (surfaced per deviation-protocol)

blueprint §5.5 and roadmap Phase 13 describe the suggester as "asks the LLM …". The two-layer
design **supersets** that intent rather than contradicting it: most suggestions are produced by
a deterministic rules engine (broader device reach, zero latency, no hallucination, **no PII ever
entering a prompt**), and the LLM is retained as an optional enrichment layer that still satisfies
"asks the LLM". No privacy/security invariant is weakened — it is strengthened (the common path
touches no model). §5.5 and the roadmap bullets are updated in the same PR as this plan, and the
rationale is logged in `docs/DECISIONS.md`.

## 4. Design

### Models (`lib/features/suggestions/suggestion.dart`)
- `enum SuggestionTrigger { scanCompleted, detectionCompleted, redactionApplied }`
- `enum SuggestionActionKind { tokenizeLabelConsistently, applyOperatorToLabel }` — **closed**
  vocabulary; a source can never invent an action.
- `SuggestionAction { kind, String label /* entity TYPE only */, Operator operator }`
- `Suggestion { String title, String body, SuggestionAction action, SuggestionTrigger trigger }`
- `SuggestionSignal { trigger, Map<String,int> labelCounts, workspaceId, projectId?, tier,
  Map<String,Operator> currentOperators }` — **PII-safe by construction**: it carries entity
  **type → count** only, never span text.

### Engine
- **Layer 1 — `deterministic_suggestion_rules.dart`** (pure function `Suggestion? evaluate(signal)`).
  Flagship rule: on `detectionCompleted`/`scanCompleted`, choose the highest-count label with
  `count >= 2` whose current operator is the default `redact`, and propose **tokenize-consistently**
  with `Operator.tokenRandom` (reversible **and** consistent — same value → same token, true to
  DocuMink's reversible philosophy). The rule catalog is extensible; `redactionApplied` may yield
  null in V1.
- **Orchestrator — `proactive_suggester.dart`** composes an ordered list of suggestion **sources**
  (Layer 1 rules first; Layer 2 LLM appended in 13d). `Future<Suggestion?> suggest(signal, {required
  bool enabled})`: short-circuit on `!enabled` / empty-or-zero counts; **validate** any source's
  output against the whitelist (kind known · `label ∈ labelCounts` · `operator ∈ editorOperators` ·
  not a no-op); on a valid suggestion, **audit `suggestion_offered`** and return it.
- **Layer 2 — `llm_suggestion_source.dart`** (13d) wraps `LlmBackend`, consulted only when
  `MinkTurnContext.available`. Prompt is built from `labelCounts` + trigger **only** (never raw
  spans); strict JSON contract parsed via a `parseSuggestion` helper mirroring
  `mink_tools.dart parseToolInvocation`; same whitelist validation; any error → null (best-effort,
  never user-visible).

### Settings (`lib/features/suggestions/proactive_suggestions_setting.dart`)
`ProactiveSuggestionsController extends Notifier<bool>` mirroring `KeepOriginalController`
(key `proactive_suggestions_enabled`, **default ON** via `getString(key) != 'false'`), plus a
`proactiveSuggestionsDisclosureSeenProvider` (key `seen_proactive_suggestions_disclosure`)
mirroring `keepOriginalHintSeenProvider`.

### UI controller (`lib/features/suggestions/suggestion_controller.dart`)
`SuggestionController extends Notifier<SuggestionState>` (`idle/loading/ready/dismissed` +
`lastTriggerKey` dedupe). `maybeOffer(trigger)`: gate on toggle → build the signal from
`editor.spans` (count per `label`, **drop `.text`**) + `MinkTurnContext` (scope/tier/availability)
→ dedupe → call the suggester → flip to `ready` on a non-null result. `accept()` →
`pasteEditorController.setOperator(label, operator)` + audit `suggestion_actioned` + mark disclosure
seen + clear. `dismiss()` → audit `suggestion_dismissed` + mark seen + clear. Generation runs
**after** the awaited `detect()`/`save()` — it never blocks the editor's critical path, and
`PasteEditorController`/`PasteEditorState` are **not modified**.

### Card (`lib/ui/screens/paste_editor_screen.dart`)
Clones the `keep-original-hint` Card (`Key('proactive-suggestion-card')`): title/body + a "Dismiss"
TextButton and a one-tap action FilledButton, shown when `status == ready`, with the first-offer
disclosure preface gated by the disclosure-seen flag.

### Audit (event types already defined in `audit_event_type.dart:18`)
`suggestion_offered` (in the suggester), `suggestion_actioned` / `suggestion_dismissed` (in the
controller). Metadata is **type + count only** — `{trigger, action, label /* type */, count[, operator]}`
— mirroring the `mink_tool_call` "name + decision only" precedent. `workspaceId`/`projectId` are
threaded from `MinkTurnContext` for project isolation.

## 5. Sub-PR breakdown

| PR | Scope | Ships |
|----|-------|-------|
| **13a** | Deterministic rules engine + models + orchestrator + `suggestion_offered` audit + providers. Pure Dart, all tiers. | Unit-tested core; no UI. |
| **13b** | Settings toggle (default ON) + one-time disclosure flag + the Privacy-section `SwitchListTile`. | Controller + settings widget tests. |
| **13c** | Paste-editor integration: card, the three trigger calls, one-tap real mutation, dismiss; `suggestion_actioned`/`dismissed` audit. | Widget tests (fake suggester). |
| **13d** | Optional LLM enrichment source (Tier 2+) — satisfies the spec's "asks the LLM". May ship in-phase or, if needed, defer to V1.x (logged). | Fake-`LlmBackend` tests; prompt-has-no-PII assertion. |

Each PR is headless-shippable, `flutter analyze --fatal-infos --fatal-warnings` clean, and
`flutter test` green.

## 6. Privacy / invariant checklist

- **No cloud / on-device only** — Layer 2 uses only `LlmBackend`; Layer 1 uses no model.
- **No raw PII in prompts or audit** — type+count only, enforced at the type level; a test asserts
  no span value reaches any prompt or audit row.
- **Project isolation** — scope threaded from `MinkTurnContext` into the signal and every audit row.
- **No background work** — fires only on awaited user-action completion.
- **Deny / degrade safely** — any failure ⇒ no card, never a user-visible error.

## 7. Verification

- **Headless (CI/here):** analyze clean; `flutter test` green (rules/orchestrator unit tests,
  settings + paste-editor widget tests with a fake suggester); license/analytics/codegen scanners pass.
- **Device (`VERIFICATION.md`, added in 13c/13d):** real card rendering + one-tap mutation on
  Android; (13d) real on-device Gemma generating suggestions, latency, and prompt quality.
- **Manual loop:** paste text with a recurring name → detect → confirm the "tokenize all N
  consistently" card → one-tap → preview shows consistent tokens; toggle off → no card; audit log
  shows offered/actioned (or dismissed) with type+count metadata only.
