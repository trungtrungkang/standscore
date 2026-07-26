# StandScore identity under BackingScore

StandScore is a product of **BackingScore** ([backingscore.com](https://backingscore.com)). Mobile/web application identifiers use the BackingScore reverse-DNS namespace.

**Status:** accepted  
**Decided by:** Human Orchestrator (2026-07-22)

## Decision

| Field | Value |
|-------|--------|
| Publisher / company brand | BackingScore |
| Publisher site | https://backingscore.com |
| Product name | StandScore |
| Bundle ID / application ID | `com.backingscore.scoreapp` |

Same namespace pattern for related IDs unless a later ADR says otherwise (e.g. `com.backingscore.scoreapp.ios` only if store tooling forces a split — prefer one ID).

## Consequences

- Store listing publisher = BackingScore; product title = StandScore.
- Deep links, OAuth redirect URIs, push, and CI signing should stay under `com.backingscore.scoreapp` (and BackingScore Apple/Google developer accounts).
- Do not invent alternate bundle roots (`com.standscore…`) in scaffolds.
- Brand hierarchy in UI: BackingScore can appear in About / legal; StandScore is the app-facing name.
