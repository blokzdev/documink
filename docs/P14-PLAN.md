# Phase 14 — Projects & templates: plan

> **Status:** ~80% shipped (14a–14c, PRs #60–#65) **before** the per-phase plan-doc convention;
> this doc is the retroactive design-of-record **plus** the forward plan for the remainder (14d).
> **Specs:** roadmap Phase 14 · blueprint §3 (schema), §6 (manifest §6.1, isolation §6.7,
> templates §6.4) · models.md §5 (Ed25519) · §15 #18/#19/#22.

## 1. What we're building

**Projects** partition a workspace: each carries a versioned **manifest** (permissions, default
policy, custom-entity seeds, Mink persona) and **isolates** its documents/chat/memory. **Templates**
seed a project — 8 Ed25519-signed **Verified** templates plus three creation paths (pick a template,
a blank wizard, or upload-and-let-Mink-scaffold).

## 2. Already shipped (14a–14c, merged on `main`, tested)

| Slice | PR | What |
|-------|----|----|
| **14a** | #60 | `ProjectManifest`/`ProjectPermissions` (deny-by-default) + `ToolPermissionRegistry`; `ProjectRepository` (`create`/`getById`/`listActive`/`updateManifest` w/ version bump/`setArchived`) + audit (`project_created/modified/archived`); custom-entity seeding (defensive validator/operator fallbacks); **repository-layer isolation** for documents/custom-entities/chat/memory with a §6.7 cross-project leakage test; `ActiveProjectProvider`. |
| **14b-1** | #61 | The 8 Verified templates as an Ed25519-signed bundled catalog; the shared `lib/features/security/signed_manifest.dart` (`verifyEd25519SignedManifest`) consumed by both `ManifestVerifier` (Phase 9) and `TemplateService`; `tool/scripts/sign_template_manifest.dart`. |
| **14b-2** | #62 | Template picker UI (**creation Path A**) + preview + create-from-template. |
| **14c-1** | #63 | Projects list + active-project switcher; persisted in `SettingsStore` (`active_project_id`). |
| **14c-2** | #64 | Project detail (documents + settings tabs) with live manifest editors (permissions/policy/persona → versioned + audited). |
| **14c-3** | #65 | Blank Wizard (**creation Path C**) — 4-step stepper + `composeBlankManifest`. |

`DomainInferenceService` (**creation Path B** logic, behind the `LlmBackend` seam) shipped in Phase
10a (#66) but is **not wired to any UI**.

## 3. Remaining work — **14d shipped** (#84 + UI PR)

### 14d-1 — headless core (merged #84)
- **`AiScaffoldOrchestrator`** (pure Dart, seam-injected): `analyzeUpload()` picks + ingests a PDF
  (via `InputIngestionService.importPdf`) and classifies a capped snippet through
  `DomainInferenceService.infer`, mapping the §6.2 branching to a sealed `UploadOutcome`:
  `StrongMatch(templateId)` / `WeakMatch([templateIds])` / `ScaffoldSuggested(domain?)` /
  `InferenceUnavailable`. `infer()==null` → unavailable (graceful fallback); a low-confidence
  suggestion (`SuggestionStrength.none`) → scaffold.
- **`composeScaffoldedManifest`**: conservative deny-by-default §6.1 manifest (`template_id:
  'ai_scaffolded'`; export off, decode biometric-gated, common PII → redact) for the no-match branch.
- **`PersonalTemplate` + `PersonalTemplateRepository`**: `vault_meta`-backed local store, one key per
  template (`personal_templates:<id>`, mirrors `ProfilerRepository`), audited
  (`personal_template_saved`/`_deleted`, id-only metadata). No drift schema change.

### 14d-2 — UI + personal-template surfaces (this PR)
- **`UploadScaffoldScreen`** (route `Routes.newProjectAiScaffold`): idle → analyzing → branch view.
  Strong confirms the matched Verified template; weak offers candidate cards; scaffold shows the
  **"AI-scaffolded — please review"** editable summary + badge and a **save-as-personal-template**
  prompt; unavailable links to the picker/wizard. After create it hands the uploaded text to the
  **redaction editor** (`context.go(Routes.paste)`), scoped to the now-active Project.
- **Template picker**: a **"Create from a document"** entry + a **"Yours"** section listing personal
  templates (create-from on tap).
- **Project detail**: an **AI-scaffolded badge** (`templateId == 'ai_scaffolded'`) + a
  **"Save as personal template"** settings action.
- **Document scoping fix**: `PasteEditorController.save` now passes `projectId:
  ref.read(activeProjectProvider)` so captured/imported documents land in the active Project (§6.7) —
  which is what makes the Path-B import (and the project Documents tab) actually populate.

### Correction to the original §6.2 reading
`ai_scaffolded` applies **only** to the no-match branch. Strong/weak keep the **verified** `template_id`
(AI merely pre-selects). The shipped `DomainInferenceService` emits `{domain, confidence,
candidateTemplateIds}` only, so the scaffold manifest is a **conservative editable** starting point —
fully generating `suggested_custom_entities[]` / `suggested_persona` per §6.2 is deferred (see below).

### Deferred & tracked (not built now — logged in DECISIONS + VERIFICATION + roadmap)
- **Richer scaffold generation** — extend `DomainInferenceService` to emit suggested custom entities
  + persona and fully populate the no-match manifest (§6.2). Needs prompt+eval work + a loaded model.
- **Remote signed-template refresh** (`documink.ai/templates/manifest.json`, weekly, Ed25519, offline
  last-known-good) — blocked on hosting that doesn't exist; the bundled signed asset is the fallback.
- **CRDT personal-template sync** (V3 sync transport).

## 4. Loose ends & quick wins (Phase-14 audit sweep)

An end-of-phase audit of the pre-built 14a–14c code runs alongside this plan. **Safe, low-risk fixes
ship in a separate polish PR** (kept out of this docs-only planning PR per commit-hygiene); anything
ambiguous or architectural is logged in `docs/DECISIONS.md` and folded into 14d. The audit focuses on:
localization coverage of the four project screens (whole-screen, per DocuMink convention), missing
empty/error/loading states, `context.mounted`-after-await correctness, dropped errors on
`create`/`updateManifest`, isolation consistency (is `cross_project_search` honored or inert?),
test gaps, and small refinements. Findings + their disposition are recorded in the polish PR.

## 5. Privacy / invariants

- **Isolation (§6.7):** every repo query filters `workspace_id`/`project_id`; cross-project access
  only via an audited path. Enforced + tested (14a); 14d adds no cross-project reads.
- **Ed25519 (§6.4 / architecture-invariants #4):** templates verified via the shared
  `signed_manifest.dart`; failure blocks use, never falls back to unsigned. (Personal templates are
  **local user data**, not signed Verified templates.)
- **No permission bypass (§15 #18):** creation/edit respects the deny-by-default manifest.
- **AI-scaffolded labeling (§15 #22):** scaffolded templates carry the badge, never Verified.
- **No PII in audit/manifest:** manifests hold config (types/policy/persona), not document values.

## 6. Verification

- **Headless (CI/here):** `flutter analyze --fatal-infos --fatal-warnings` clean; `flutter test`
  green (currently **473**, + new 14d/polish tests); scanners pass.
- **Device (`VERIFICATION.md`, added with 14d):** real on-device domain inference (Path B) quality and
  the strong/weak/none branching with a loaded Tier-4 model; the remote template fetch once
  `documink.ai/templates` hosting exists.
