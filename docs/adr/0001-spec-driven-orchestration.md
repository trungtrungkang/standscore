# Spec-Driven Orchestration as the delivery model

We will build Sheet App primarily with AI coding agents under a human orchestrator, using Spec-Driven Orchestration (SDO): locked Feature Specs and ADRs before implementation, vertical slices, and mandatory human gates G0–G4.

**Status:** accepted

## Considered options

- **Scrum with AI as “team”** — rejected: ceremony assumes human developers; vague tickets cause agent thrash.
- **Big upfront waterfall PRD only** — rejected: audio/OMR/PDF realities will invalidate large frozen plans.
- **Shape Up alone** — rejected as sole model: good for shaping appetite, weak as an executable contract for agents.
- **SDO (specs + ADR gates + slices)** — accepted: matches AI strength (implementation) and human strength (decisions).

## Consequences

- No feature coding without an `accepted` Feature Spec (spikes excepted).
- Process docs live under `docs/process/`; agents must read `AGENTS.md`.
