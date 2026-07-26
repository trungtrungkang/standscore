# StageScore identity under BackingScore

StageScore is a product of **BackingScore** ([backingscore.com](https://backingscore.com)). Mobile/web application identifiers use the BackingScore reverse-DNS namespace.

**Status:** accepted  
**Decided by:** Human Orchestrator (2026-07-22)

## Decision

| Field | Value |
|-------|--------|
| Publisher / company brand | BackingScore |
| Publisher site | https://backingscore.com |
| Product name | StageScore |
| Bundle ID / application ID | `com.backingscore.scoreapp` |

Same namespace pattern for related IDs unless a later ADR says otherwise (e.g. `com.backingscore.scoreapp.ios` only if store tooling forces a split — prefer one ID).

## Consequences

- Store listing publisher = BackingScore; product title = StageScore.
- Deep links, OAuth redirect URIs, push, and CI signing should stay under `com.backingscore.scoreapp` (and BackingScore Apple/Google developer accounts).
- Do not invent alternate bundle roots (`com.stagescore…`) in scaffolds.
- Brand hierarchy in UI: BackingScore can appear in About / legal; StageScore is the app-facing name.
