# The brand a human reads is "Backing & Score"

StageScore's publisher is written **Backing & Score** wherever a person reads it. Identifiers keep the compressed spelling: the domain stays `backingscore.com` and the reverse-DNS root stays `com.backingscore`.

**Status:** accepted
**Decided by:** Human Orchestrator (2026-07-28)
**Amends:** ADR 0009 — only the human-readable spelling of the publisher. Every other row of 0009 stands.

## Context

ADR 0009 fixed the publisher as **BackingScore** and the bundle root as `com.backingscore.scoreapp`. The ecosystem's own product spells itself differently. In the Next.js app at `backing-and-score/apps/web`, every user-visible occurrence is **Backing & Score** — hero and About copy in all nine locales, the site footer, the verification and password-reset emails, the auth screens, the header, the share text. The one-word spelling appears nowhere in its `src/`.

StageScore's repo uses the one-word spelling in `AGENTS.md`, `CONTEXT.md`, `VISION.md`, both READMEs, the `pubspec.yaml` description, and the `O=` field of the upload certificate. None of it is visible to a musician today — which is exactly why settling this now is cheap. The store listing (R12) and an About screen are the first two places a human would read the publisher name, and neither is written yet.

## Considered options

- **Standardise on "BackingScore" and change the web app** — rejected. It is nine locales, the transactional emails, and the auth surface, and it changes the brand of the larger product to match the smaller one's internal docs.
- **Let each product spell it its own way** — rejected. The whole point of the change is that a musician should recognise the same publisher in both places; two spellings undercut it before it starts.
- **"Backing & Score" for humans, `backingscore` for identifiers** — accepted. It matches the shipped brand, costs a docs sweep, and touches nothing that is hard to reverse.

## Decision

| Field | Value |
|-------|-------|
| Brand as a human reads it | **Backing & Score** |
| Product name | StageScore *(unchanged)* |
| Publisher site | https://backingscore.com *(unchanged)* |
| Bundle / application ID | `com.backingscore.scoreapp` *(unchanged, ADR 0009)* |
| Android package | `com.backingscore.standscore` *(unchanged — renaming it is a new app to Play)* |
| Repo prose | "Backing & Score", except when quoting an identifier |

## Consequences

- Nothing shipped changes: no bundle ID, no package name, no on-device path, no keystore. The upload certificate's `O=BackingScore` stays as issued — reissuing a key to fix a cosmetic field would cost more than it buys, and Play shows the store listing's publisher name, not the certificate.
- Repo docs and the `pubspec.yaml` description get a one-pass sweep. It is prose only; no identifier moves.
- At submit, check whether the store account's publisher name accepts an ampersand. If a store rejects it, the store's rendering wins for that store only and this ADR is not reopened.
- Spec 0042 depends on this ADR: it cannot be accepted at G3 until the spelling is settled, because it is the Spec that first prints the name where a musician can see it.
