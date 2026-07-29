# Feature Spec template

Copy to `docs/specs/NNNN-short-slug.md`. Number sequentially.

```md
# NNNN — Title

- **Status:** proposed | accepted | done | rejected
- **Type:** feature | spike
- **Horizon:** H1 … H6 (see VISION)
- **Owner (human):** 
- **Depends on ADRs:** (e.g. 0002, 0003)
- **Depends on Specs:** (optional)

## Problem

Who hurts / what fails today? One short paragraph.

## Outcome

What becomes true when this slice is done? Observable by a musician or learner.

## In scope

- …

## Out of scope

- …

## Domain terms

Link or quote terms from `CONTEXT.md` used in this Spec.

## Acceptance criteria

Testable checklist (G4):

- [ ] …
- [ ] …

## UX notes (optional)

Only what the implementer must not invent wrongly (gestures, empty states).

## Technical constraints (optional)

Only constraints already implied by ADRs, or slice-local limits (e.g. “Android later”).

## Test plan

- Automated: …
- Manual demo: …

## Spike-only fields (if Type = spike)

- **Question:**
- **Time box:**
- **Success metric:**
- **Outputs:** (ADR draft / Spec update / discard)
```

## Rules

- One vertical slice per Spec  
- No coding until `accepted` (except the spike itself)  
- Prefer musician-visible outcomes over layer-shaped tasks (“build DB schema”)  
- **Write the Spec's content in Vietnamese (ADR 0015)** — a human accepts it at G3 and verifies it at G4. This template file itself stays English (it is scaffolding, not a document anyone accepts). Bilingual headings (`## Vấn đề (Problem)`), keep every domain term / identifier / file path / code symbol in English, and put every test value in backticks. Exception: Specs `0001`–`0042`, drafted before ADR 0015, stay English — do not retroactively translate them; a Spec is only translated when a decision is next needed from it (same rule ADR 0013 uses for renumbering).
