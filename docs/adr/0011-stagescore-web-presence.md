# Where StageScore's own web presence lives

StageScore gets a **page on `backingscore.com`, not a site of its own** — for now. A subdomain or a dedicated domain stays open, and nothing in v1 forecloses either.

**Status:** accepted
**Decided by:** Human Orchestrator (2026-07-28) — the path, built immediately
**Relates to:** ADR 0009 (publisher identity), ADR 0010 (brand spelling), Spec 0042 (ecosystem messaging)

## Context

Spec 0042 put StageScore on the site as a section of `/about` and a block on `/support`. That was scoped to close R20 — "the site does not mention the app at all" — not to be the app's marketing home. The question is whether the app should get its own surface, and if so, where it lives.

What the ground looks like:

- **`stagescore.com` is taken.** Registered 2013, currently parked and **for sale** through Atom/UnifiedNames. Nobody is running a product on it, which is mildly reassuring for R5, but acquiring it means a broker negotiation at an unknown price.
- **The main site is a single Next.js app on Vercel** with next-intl `[locale]` routing and a middleware that already rewrites locale prefixes. A new path is one route file. A subdomain is a new DNS record, a new Vercel domain, and a middleware that now has to reason about host as well as locale.
- **`stage.`, `staging.` and `app.` are all unused** on the domain today; only `media.` is live. Staging runs on Vercel Preview URLs, so `stage.` collides with nothing that exists — but it is still the word most engineers read as *pre-production*, and that ambiguity is permanent. `stagescore.` says what it means.
- **The app has URLs baked into the binary.** `Brand.siteUrl` and `Brand.privacyUrl` point at `backingscore.com`. Changing them is two constants today and a new build plus a review cycle after submission.

## Considered options

- **A path, `backingscore.com/stagescore`** — accepted for now. One route in an app that already deploys, one privacy policy, one SEO surface, and it reads as "part of Backing & Score", which is the thing Spec 0042 was for.
- **A subdomain, `stagescore.backingscore.com`** — rejected for now, not on the merits but on the timing. It buys a separable surface we have no traffic to justify, and it costs middleware complexity against the existing locale rewriting. Worth revisiting when the app has users and the landing page has data.
- **`stage.backingscore.com`** — rejected on the name. To a musician "stage" is exactly right; to everyone who has ever deployed anything it reads as a staging environment, and we would be spending that confusion forever to save four characters.
- **A dedicated domain (`stagescore.com`, or `stagescore.app`)** — rejected for now. It is the option that most weakens the ecosystem story we just spent a Spec building, it needs a purchase, and it means a second privacy policy — which R22 just showed is the document you least want duplicated.

## Decision

For v1: **`backingscore.com/stagescore`**, growing out of the `/about` section rather than replacing it. The app keeps pointing `Brand.siteUrl` and `Brand.privacyUrl` at `backingscore.com`.

## Consequences

- The store listing's marketing URL becomes `backingscore.com/stagescore`; the support URL stays `backingscore.com/support`.
- **This does not block submission.** Whichever way a later ADR goes, `backingscore.com` keeps serving `/privacy` and `/support`, so the URLs already compiled into v1 stay valid and no rebuild is forced by a move.
- Moving later is a redirect, not a migration: a subdomain or a domain can 301 to the path, or take over from it, and there is no accumulated SEO to lose yet.
- One privacy policy remains the single source of truth, with StageScore as a scoped section (R22).
- If the Orchestrator wants the short URL anyway, the cheap version is buying a domain and **redirecting** it to the path — a brand asset with no second site to maintain.
