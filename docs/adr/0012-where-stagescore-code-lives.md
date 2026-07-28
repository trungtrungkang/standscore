# StageScore keeps its own repo until v1 ships, then joins the monorepo

StageScore is a Backing & Score product and its code will live in the Backing & Score monorepo as **`apps/stagescore/`** — but not until v1 is on the store. Until then it stays in its own repo, and the two are held together by pointers rather than by git.

**Status:** accepted
**Decided by:** Human Orchestrator (2026-07-28)
**Relates to:** ADR 0009 (publisher identity), ADR 0010 (brand spelling), ADR 0011 (web presence), R17 and R20 in `docs/product/RELEASE-CHECKLIST.md`

## Context

The two halves of one product sit in two repos: this one (`trungtrungkang/standscore`, the Flutter app plus these docs) and `trungtrungkang/backing-score` (the Next.js site, the native and experimental apps, the shared packages).

R20 is what the split costs. Closing one checklist row meant writing a landing page in the web repo while the URLs it has to agree with — `Brand.siteUrl` and `Brand.privacyUrl` — are compiled into the Flutter binary from `lib/brand/brand.dart` in this one. Nothing links the two. No CI sees both. The only thing keeping them consistent is somebody remembering.

An audit on 2026-07-28 found the split had already quietly become a three-way one. The web repo was checked out twice:

- `~/projects/paperclip/lotusa/projects/backing-and-score` — current.
- `~/projects/jeff/backing-score` — **92 commits behind**, last commit 2026-06-08. It was missing `apps/android/`, `apps/ios/`, `apps/piano-utility/`, `apps/amt-mlops/`, and every piece of the StageScore web work from R20, R22 and R23. It held no commits, branches, tags or stashes of its own — only two untracked `scratch/` files. Anyone who opened it would have been reading a version of the product that stopped existing seven weeks ago.

So the question is not only "one repo or two", but "how many working copies is a solo maintainer allowed to have". The answer to the second is one per repo, and it does not depend on the first.

Against merging immediately, there is R17. Renaming this folder once already broke iOS release builds: `build/` and `.dart_tool/` had baked absolute paths to the pre-rename directory, so Xcode looked for `pdfium_flutter`'s XCFramework somewhere that no longer existed. No debug run caught it. `flutter clean` fixes it, but the cost is finding out — and a store submission is in flight.

## Considered options

- **Merge now** — rejected on timing, not on merit. It is the right end state, but it moves the Flutter directory during a submission, which is precisely the move that produced R17, and it would land while the release checklist still has open rows.
- **Two repos permanently** — rejected. It keeps R20-shaped work spread across two repos with nothing enforcing agreement, and it argues against ADR 0011, which just decided the app's public surface is a path on the Backing & Score site.
- **Merge after v1, hold it together with pointers until then** — accepted. The duplicate checkout is the part actually hurting today and it can be fixed in an afternoon with no build risk. The merge is the part with build risk and no deadline.

## Decision

**Now:**

| | |
|---|---|
| Canonical StageScore checkout | `~/projects/study/music/sheet-app` |
| Canonical Backing & Score checkout | `~/projects/paperclip/lotusa/projects/backing-and-score` |
| Duplicate checkouts | none — one working copy per repo |

The stale clone was moved to the Trash on 2026-07-28 after its two unique `scratch/` files were copied into the canonical checkout. Each repo's `AGENTS.md` names the other and says what couples them.

**After v1 is on the store:** this repo becomes `apps/stagescore/` in the monorepo and these docs become `docs/stagescore/`, brought over with `git subtree add` so all commits survive. The `standscore` repo is then archived, not deleted — the old name is referenced in on-device paths and backup files that R4 deliberately froze.

## Consequences

- Until the merge, a change touching both halves is still two commits in two repos. The pointers make that visible; they do not make it one commit. That is the accepted cost of the delay.
- The folder is not renamed now. `sheet-app/` keeps its lagging name for the moment, because renaming it is the R17 failure a second time and the directory moves at merge time regardless. One rename, not two.
- The GitHub repo rename `standscore` → `stagescore` is left as a manual step: the local `gh` token is expired. It is cosmetic and safe whenever it happens — GitHub redirects the old URL — and it is independent of the merge.
- Post-merge, Turbo and npm workspaces will not manage the Flutter app. `apps/stagescore/` will be a co-located directory with its own toolchain and its own CI workflow, sharing the repo but not the build graph. Co-location buys atomic cross-cutting commits and one place to look; it does not buy a unified build, and nothing here should be read as promising one.
- Whoever performs the merge runs `flutter clean` first, for the reason R17 documents.
