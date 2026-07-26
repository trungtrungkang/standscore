# Development Model: Spec-Driven Orchestration (SDO)

**Status:** Accepted  
**Audience:** Human orchestrator + AI coding agents  
**Goal:** Ship a complex multi-platform music app with AI doing most implementation, while a human owns direction, trade-offs, and acceptance.

---

## Why this model

Classic Scrum/Kanban assume a human team writing code daily. Here the bottleneck is **decision quality and spec clarity**, not typing speed.

| Model | Fit for AI-primary? | Problem |
|-------|---------------------|---------|
| Scrum (sprint ceremony-heavy) | Weak | Ceremony without a human team; vague backlog → AI thrash |
| Waterfall full upfront | Weak | Specs rot; OMR/audio reality will invalidate early guesses |
| Shape Up only | Partial | Good shaping, weak “executable acceptance” for agents |
| **Spec-Driven Orchestration** | **Strong** | Specs + ADRs are the contract; AI implements; human gates |

**SDO** = Spec-Driven Development + short vertical slices + hard human decision gates + domain language discipline.

It matches this repo’s agent skills: grilling, domain modeling (`CONTEXT.md` + ADRs), deep modules, review against spec.

---

## Roles

### Human Orchestrator (you)

- Product intent, scope cuts, “no”
- Accept / reject **ADRs** and **Feature Specs**
- Run or request **grill** sessions before locking a slice
- Acceptance: demo + spec checklist (not line-by-line code review of everything)
- Escalate only irreversible or surprising decisions

### AI Agent(s)

- Draft specs, ADRs, tests, and implementation
- Explore codebase, keep `CONTEXT.md` consistent
- Propose options with a **recommendation** — never silently pick lock-in tech
- Stop and ask when a Human Gate is required

### Optional later: Review Agent

- Spec compliance + standards review after a slice (see `.agents/skills/review`)

---

## Lifecycle (repeat per vertical slice)

```text
1. DISCOVER     Intent → grill → update CONTEXT.md
2. DECIDE       ADR if irreversible / surprising / trade-off
3. SPEC         Feature Spec (AI drafts → Human accepts)
4. BUILD        AI implements against locked Spec + tests
5. VERIFY       Automated tests + Human acceptance against Spec
6. LEARN        Tiny retro note in docs/product/DECISIONS-LOG.md
```

No coding for a slice until its **Feature Spec** is `accepted` (unless the slice is an explicit **Spike**).

---

## Artifact hierarchy

```text
VISION          Why / who / non-goals          (stable, rare edits)
    ↓
CONTEXT.md      Ubiquitous language            (living glossary)
    ↓
ADR             Hard-to-reverse decisions      (append-only)
    ↓
Feature Spec    One shippable slice            (accepted → build)
    ↓
Code + Tests    Implementation                 (AI-primary)
```

**Rule:** If it is not in VISION / CONTEXT / ADR / Spec, the agent must not invent product behavior.

---

## Human Gates (mandatory)

| Gate | When | Human action |
|------|------|--------------|
| **G0 Vision** | Project start / major pivot | Accept VISION |
| **G1 Language** | New domain term or conflict | Accept CONTEXT change |
| **G2 ADR** | Lock-in tech or architecture | Accept / request options |
| **G3 Spec** | Before build of a slice | Accept Feature Spec |
| **G4 Accept** | After build | Pass / fail vs Spec checklist |

Agents may prepare everything for a gate; they may not skip it.

---

## Slice sizing

Prefer **vertical slices** that a musician can feel:

- Good: “Import PDF → open viewer → tap right half turns page”
- Bad: “Build entire annotation system”

**Target:** 1–5 days of agent work per slice after Spec is locked.  
If larger, split Specs; do not enlarge the sprint.

### Spike slices

Allowed when uncertainty blocks a Spec (e.g. iOS native MIDI latency, Verovio playhead sync).

Spike Spec must define:

- Question to answer
- Time box
- Success criteria (measurement, not “feels ok”)
- Explicit **no production feature commitment**

Spike output → ADR or Spec update — then normal build.

---

## What the Human decides vs delegates

**You decide**

- Platforms & packaging (web / iOS / Android priority)
- PDF-first vs Smart-Score-first sequencing
- Capacitor vs Flutter vs hybrid shells
- Native audio ownership, OMR vendor vs self-host
- Monetization, privacy, offline guarantees
- Cut scope when schedule slips

**AI proposes + implements after accept**

- Module seams, APIs, file layout
- Test strategy within Spec constraints
- Refactors that do not change ADR/Spec
- Bugfixes inside accepted behavior

---

## Working agreement with AI

1. **Spec is law** for the slice. Ambiguity → ask, do not guess product intent.
2. **One ADR recommendation** per decision, with rejected alternatives named.
3. **Grill before G3** on any Spec that touches playback, OMR, or page-turn reliability.
4. **No drive-by features** outside the Spec.
5. **Update CONTEXT.md** when a term is resolved — same session.
6. **Deep modules** at seams (see codebase-design skill): small interface, large behavior.
7. Prefer **TDD** for domain/timeline/practice engines; UI may be characterization + checklist.

---

## Cadence (lightweight)

Not Scrum. Suggested rhythm for one orchestrator:

| Rhythm | Activity |
|--------|----------|
| Start of slice | Grill → Spec → G3 |
| During build | Agent reports blockers needing G2 only |
| End of slice | Demo + G4 checklist |
| Weekly | Re-order upcoming Spec backlog; at most one new ADR theme |

No story points. Backlog = ordered list of Feature Specs (`proposed` → `accepted` → `done`).

---

## Definition of Ready (Spec → Build)

- [ ] Problem and actor clear
- [ ] In scope / out of scope listed
- [ ] Acceptance criteria testable
- [ ] Domain terms match `CONTEXT.md`
- [ ] Dependent ADRs accepted (or Spec is a Spike)
- [ ] Human G3 accepted

## Definition of Done (Build → Done)

- [ ] Acceptance criteria met (demo or automated)
- [ ] Tests required by Spec pass
- [ ] No unexplained CONTEXT/ADR drift
- [ ] Human G4 passed
- [ ] Spec status → `done`

---

## Doc map

| Doc | Path |
|-----|------|
| This model | `docs/process/DEVELOPMENT-MODEL.md` |
| Agent instructions | `AGENTS.md` |
| Vision | `docs/product/VISION.md` |
| Language | `CONTEXT.md` |
| ADRs | `docs/adr/` |
| Specs | `docs/specs/` |
| Decision log (soft) | `docs/product/DECISIONS-LOG.md` |

---

## Anti-patterns

- Coding from chat memory without an accepted Spec
- One giant “build the app” Spec
- Accepting ADRs casually (“we’ll see”) for audio/OMR/shell
- Human reviewing every line instead of gating Spec + risky modules
- Letting AI expand scope mid-slice because “it was easy”
