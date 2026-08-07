# Agent instructions — StageScore

You are implementing **StageScore** (product of **Backing & Score**, https://backingscore.com) under human orchestration. Read these before coding.

The brand is written **Backing & Score** wherever a person reads it, and `backingscore` only inside identifiers — ADR 0010. Brand strings have one definition, `Brand` in `lib/brand/brand.dart`, and a test keeps them out of everything a musician can reach while playing.

The product was called **StandScore** until 2026-07-27. On-device paths (`<documents>/standscore/`) and the backup format id keep the old spelling on purpose — see the README in `stagescore/`. Do not "clean up" either one.

Application ID / bundle ID: **`com.backingscore.scoreapp`** (ADR 0009). Do not invent another reverse-DNS root.

## Source of truth (in order)

1. `docs/process/DEVELOPMENT-MODEL.md` — how we work  
2. `docs/product/VISION.md` — product intent and non-goals  
3. `CONTEXT.md` — domain words (use them; do not invent synonyms)  
4. `docs/adr/*.md` — accepted architecture decisions  
5. `docs/specs/<slice>.md` — **accepted** Feature Spec for the current slice  

If chat history conflicts with an accepted Spec/ADR, **Spec/ADR win**.

ADR 0013 extends the model rather than replacing it — tier **S** / **M** / **L** announced before working, routing to gates — and ADR 0016 routes models by phase with a floor that is never lowered. Both are operationalized in `.cursor/rules/ai-workflow.mdc`, which is always in context: the announcement line, model per phase and per logic type, the never-downgrade paths, the context budget, which commands an agent may run, and how to report evidence. Read it there instead of re-deriving the policy. One rule belongs here because it is a Spec rule, not a model rule: if a locked Spec needs the top-tier model to implement, the defect is in the Spec — go back to G3.

ADR 0014 keeps this repo's glossary exactly as it is: StageScore and the web app are two bounded contexts with two vocabularies, because StageScore descends from ScorePDF and the web app from Tomplay and FollowKeys. Do not "align" a term across the two. If you work across both, read the translation table in ADR 0014 rather than inventing a third name.

## Role split

- **Human:** Gates G0–G4, scope cuts, irreversible choices  
- **You:** Draft artifacts, implement against locked Spec, recommend options with rationale  

## Hard stops — ask the human

- New platform shell or audio ownership change  
- New OMR vendor / data leaving device  
- Behavior not covered by the current Spec  
- Changing an accepted ADR  
- Expanding slice scope “while we’re here”
- **Starting SmartMode / Transport / Backing / OMR work before ADR 0008 exit** (ScorePDF parity) unless the Orchestrator explicitly opens H3+

## Early phase constraint (ADR 0008)

Prefer Feature Specs that reference IDs in `docs/product/SCOREPDF-PARITY.md`.  
Do not implement Verovio, MIDI Transport, BackingTrack, or OMR unless a Spec with status `accepted` explicitly says so for that slice.

**Shell:** Flutter (ADR 0005), in `stagescore/`. All ScorePDF parity rows P0–P2 are **done** (Specs 0001–0041; fit height and max DPI are explicit cuts). Roadmap **accepted** — Phases A and B complete. Orchestrator chose to **ship v1 (`1.0.0+1`) before Phase C**, so the active track is `docs/product/RELEASE-CHECKLIST.md`; Phase C (**0037** duplicate Score, then 0038, 0039) becomes 1.1, and the Phase D go/hold on H3 follows it.

Release builds are signed from `android/key.properties`, which is gitignored and absent on a fresh clone — release builds there come out **unsigned by design**. Do not restore a debug-key fallback.

## Before writing code for a slice

1. Confirm Feature Spec status is `accepted` (or Spec type is `spike`)  
2. Confirm required ADRs are `accepted`  
3. Prefer TDD for Transport, PageOrder, WaitMode comparison logic  
4. Keep modules deep: small interface at seams (native↔webview, PdfMode↔SmartMode)

## Documentation hygiene

- Resolve a domain term → update `CONTEXT.md` same session  
- Hard-to-reverse trade-off → draft ADR (`proposed`) and wait for human  
- Soft choices / weekly notes → `docs/product/DECISIONS-LOG.md`  
- Do not put implementation detail in `CONTEXT.md`

**Language (ADR 0015):** write in the language of whoever reads the document to act on it. ADRs, Feature Specs, VISION, the release checklist and the decisions log are **Vietnamese**, because a human accepts or rejects them at a gate. `AGENTS.md`, `docs/engineering/`, code comments and commit messages stay **English**. `CONTEXT.md` keeps English term names with Vietnamese definitions. Three rules hold in both languages: never translate a domain term or identifier, never keep two language versions of one document, and write headings bilingually as `## Bối cảnh (Context)` with test values in backticks. Existing English documents are **not** translated retroactively — only when a decision is next needed from one.

## Out of scope of this folder

`sheet-app/` is the StageScore product home (folder name lags the brand); the Flutter app is `sheet-app/stagescore/`. The parent directory may contain unrelated study projects (e.g. FITFR viewer). Do not mix their domain language or dependencies unless an ADR explicitly says so.

## The other half of the product

Backing & Score's website and web app are a **separate repo**, `trungtrungkang/backing-score`, checked out at `~/projects/paperclip/lotusa/projects/backing-and-score`. That is the only working copy — a second, seven-weeks-stale clone was removed on 2026-07-28 (ADR 0012). If you find another, it is not a fork, it is a mistake.

Anything a musician can reach spans both repos, so a change to one of these is not finished until the other agrees:

| This repo | Web repo |
|-----------|----------|
| `Brand.siteUrl`, `Brand.privacyUrl` in `lib/brand/brand.dart` | the routes those URLs resolve to — `/privacy`, `/support` |
| `docs/product/STORE-LISTING.md` marketing URL | `apps/web/src/app/[locale]/stagescore/page.tsx` (ADR 0011) |
| What `PrivacyInfo.xcprivacy` declares the app collects | the StageScore section of `/privacy` (R22) |

Nothing enforces this — no shared CI, no shared types. ADR 0012 folds this repo into the monorepo as `apps/stagescore/` once v1 is on the store; until then the agreement is manual, so check it by hand.
