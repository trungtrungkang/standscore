# StageScore improvement roadmap (post–P2.15)

**Status:** accepted (Orchestrator 2026-07-26)  
**Date:** 2026-07-26  
**Basis:** Quality / UX review after ScorePDF PdfMode rows through P2.15; Phase A (0033 + 0030) done  

**Goal:** Make PdfMode honestly gig-ready before opening H3+ (ADR 0008), without inventing a second product.  
**Sequencing locked:** **A1 (0033) → A2 (0030) → B → C → D**.

---

## Principles

1. **Honesty over checklist green** — if a parity row is not usable on stage, reopen or annotate it.
2. **Artist first** — learners/teachers get polish that does not block SmartMode sequencing.
3. **One Spec = one vertical slice** — keep SDO gates (G3 → build → G4).
4. **Do not start SmartMode / Transport / OMR** until Orchestrator exits ADR 0008.

---

## Phase A — Honesty & last ScorePDF row (now)

| Order | Work | Parity / Spec | Outcome |
|------:|------|---------------|---------|
| A1 | **Gesture coexist:** pinch + double-tap when unlocked; PageTurn does not steal two-finger scale | **P0.7** / Spec **0033** — **done** | Musicians can zoom mid-piece; lock (0031) meaningful |
| A2 | **Metronome** tempo / meter / volume / mute-visual | **P2.13** / Spec **0030** — **done** | Last ScorePDF P2 row |
| A3 | Checklist hygiene: P0.7 note; P2.14 “no DPI”; P1.10 Jump Links list note | Docs only | Parity matches reality |

**Exit A:** Orchestrator would trust page turns + zoom + click track for a short practice/gig set.

**Suggested G3 for A1 (0033):**

- When unlocked: 2-finger pinch reaches scale; PageTurn swipe ignores multi-touch scale.
- Double-tap zoom: include this slice **or** cut explicitly and remove from P0.7 wording.
- Draw mode / JumpLink drag unchanged.
- No peek-then-snap while zoom-locked (keep 0031).

**Suggested G3 for A2 (0030)** — already drafted:

- Persist app-wide; entry ⋯ → Metronome…; tick + accent; mute / visual-only.

---

## Phase B — Stage chrome (after A)

| Order | Work | Suggested Spec | Outcome |
|------:|------|----------------|---------|
| B1 | **Performance mode:** hide AppBar + PageNav while viewing; one GestureMap / edge action to reveal | **0034** — **done** | Less “settings app” on stand |
| B2 | **PdfMode ⋯ IA:** group Navigate / Mark / Display / Advanced (or equivalent) | **0035** — **done** | Faster mid-gig settings |
| B3 | **Scale story copy:** Page scale vs pinch; “stage preset”; the page indicator 0034 deferred | **0036** — **done** | Lock/scale understandable; one action to get ready to play |

**Exit B:** First viewport in PdfMode feels performance-first; settings are findable without a wall of peers.

Phase B is complete (2026-07-26). **0041** ran unsequenced right after it — parity Q9, a UI/UX review of the six layout modes that the B3 device run made unavoidable: `pdfFitZoom` had just proved that which layout suits a screen is arithmetic, and the picker was still six equal chips. Phase C is next, starting at C1.

---

## Phase C — Teacher / library polish (parallel-safe after A2)

| Order | Work | Suggested Spec | Outcome |
|------:|------|----------------|---------|
| C1 | Duplicate Score (copy PDF + overlays option) | **0037** | Per-student copies |
| C2 | Share / export annotated PDF discoverability (Library + PdfMode) | Extend **0020** or **0038** | Teachers send marked parts easily |
| C3 | Light onboarding: first-run tips for pedal, half-page, Jump Links | **0039** | Hand tablet to student without a lecture |
| C4 | **Library Score row:** rename Score, first-page thumbnail + page count, relative dates, labels as chips, active filter visible | **0040** — **done** | Library readable before a session; share-in PDFs stop being `doc_2024-11-03` |

C4 ran first in this phase — rename was a debt from Spec 0002 ("rename can wait") that share-in (0029) made sharp, and C1 duplicate Score would have been unpleasant while no copy could be renamed.

**Exit C:** Teacher can prep a setlist + annotated PDF without workarounds.

---

## Phase D — ADR 0008 exit decision

Orchestrator gate (not a Spec):

- [x] A1 + A2 G4 pass  
- [x] Optional: B1 G4 if chrome still feels wrong on device — done (0034)  
- [ ] Explicit **go / hold** on opening H3 (SmartMode)

If **go** → first H3 Spec (Smart Score import / Verovio shell) per VISION.  
If **hold** → more Phase B/C only.

---

## Explicitly out of this roadmap

| Item | Where it lives |
|------|----------------|
| Max page DPI | Deferred with 0031; reopen only if sharpness blocks gigs |
| Cloud sync / multi-device | Later product decision |
| WaitMode / BackingTrack / OMR | H4–H6 after SmartMode |
| Monetization / ads parity | Not required for UX |

---

## Recommended next actions (Orchestrator)

1. Accept this roadmap (or cut B/C items).  
2. **G3 accept 0030** (metronome) **or** prioritize **0033** (zoom honesty) first — recommend **0033 then 0030** if stage trust matters more than practice click.  
3. Agent drafts Spec **0033** when A1 is chosen; build only after G3.

---

## Tracking

| Doc | Role |
|-----|------|
| [SCOREPDF-PARITY.md](./SCOREPDF-PARITY.md) | Checklist + polish appendix |
| [DECISIONS-LOG.md](./DECISIONS-LOG.md) | Soft choices / weekly notes |
| Specs `0030`, then `0033+` | Executable slices |
