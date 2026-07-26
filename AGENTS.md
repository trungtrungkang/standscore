# Agent instructions — StandScore

You are implementing **StandScore** (product of **BackingScore**, https://backingscore.com) under human orchestration. Read these before coding.

Application ID / bundle ID: **`com.backingscore.scoreapp`** (ADR 0009). Do not invent another reverse-DNS root.

## Source of truth (in order)

1. `docs/process/DEVELOPMENT-MODEL.md` — how we work  
2. `docs/product/VISION.md` — product intent and non-goals  
3. `CONTEXT.md` — domain words (use them; do not invent synonyms)  
4. `docs/adr/*.md` — accepted architecture decisions  
5. `docs/specs/<slice>.md` — **accepted** Feature Spec for the current slice  

If chat history conflicts with an accepted Spec/ADR, **Spec/ADR win**.

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

**Shell:** Flutter (ADR 0005). Specs **0005–0033** **done** (P2.13 metronome). Roadmap **accepted** — Phase A complete; next **Phase B** (Performance mode / Spec **0034**).

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

## Out of scope of this folder

`sheet-app/` is the StandScore product home (folder name may lag the brand). The parent repo may contain unrelated study projects (e.g. FITFR viewer). Do not mix their domain language or dependencies unless an ADR explicitly says so.
