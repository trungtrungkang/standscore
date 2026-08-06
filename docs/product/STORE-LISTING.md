# Store listing copy (R12)

**Status:** copy **accepted** by the Orchestrator (2026-07-28, Spec 0042); store title settled 2026-07-31 (R5); logo locked (R6); **screenshots done 2026-08-01**
**Publisher name:** Backing & Score (ADR 0010) — check at submit that the store account name accepts an ampersand
**Category:** Music · **Age rating:** 4+ / Everyone · **Target audience: 13+** (a separate form — see below) · **Price:** free, **no in-app purchase in v1**

> ## Do not "update" this file for ads. It is correct as it stands.
>
> Ads and a `remove_ads` purchase are **1.1**, not v1 (ADR 0018 decision 10,
> settled 2026-07-30 after the decision moved to v1 and back). Every claim in
> this file describes the app that v1 actually is: free, no ads, nothing
> collected. **Once v1 is on the store, this text describes an app people are
> downloading right now** — editing it early makes it lie about that app.
>
> This is exactly the kind of thing someone fixes with good intentions three
> weeks from now, which is why the warning is at the top rather than in a
> changelog. The rewritten paragraph already exists, drafted and approved in
> ADR 0018 question 10, and it goes in **when the 1.1 build is ready to
> submit** — together with the other six statements in decision 8, in one pass,
> not one file at a time.
>
> One cheap thing to do now so 1.1 costs less: **frame the Library screenshot so
> that when a banner appears at the bottom in 1.1, only that one image needs
> reshooting** — not the whole set of six.

> **Age rating and target audience are two different forms** (Security Review
> S2). Play asks *Target audience and content* separately from the content
> rating, and the answer matters at 1.1 rather than v1: declaring an under-13
> audience puts the app under **Families policy**, where `AD_ID` must be removed
> from the manifest, only certified ad SDKs may be used, and ads cannot be
> served the way ADR 0018 designs them. A music app rated Everyone, filled in by
> someone thinking about students, is exactly where that wrong click happens.
> Answer **13+**, deliberately, from the first submission — changing a target
> audience later is a re-review. "Everyone" as a content rating does not
> contradict it; the two forms measure different things.

Every claim below is something the shipped build does. Nothing here promises
SmartMode, MusicXML, backing tracks, sync, or an account — the app has none of
them, and the ecosystem sentence names the web product as where those live
rather than implying StageScore does them.

---

## Names and short fields

Store title and installed name are **not the same field** (R5, 2026-07-31).
Both store consoles get **`StageScore — Sheet Music`**. The home-screen /
launcher label stays **`StageScore`** — already what the binary ships
(`CFBundleDisplayName`, `android:label`); do not change the binary to match
the store title.

Counted, not eyeballed — the short description shipped 4 characters over the
limit until 2026-08-04, because the table listed only the limit. The counts
below are measured on the exact strings in this table; recount whenever a value
changes.

| Field | Value | Chars / limit |
|-------|-------|---------------|
| App Store name | `StageScore — Sheet Music` | 24 / 30 |
| App Store subtitle | `Sheet music for the stand` | 25 / 30 |
| Play title | `StageScore — Sheet Music` | 24 / 30 |
| Installed name (home screen) | `StageScore` | — |
| Play short description | `PDF sheet music for the stand: reliable page turns, setlists, markup. Offline.` | 78 / 80 |
| Promotional text (iOS) | `A Backing & Score app. Your PDF charts on the stand — turn pages with a pedal, run a set without touching the screen, mark up anything.` | 135 / 170 |
| Keywords (iOS) | `sheet music,pdf,score,setlist,page turner,pedal,bluetooth,music stand,annotate,metronome,gig` | 92 / 100 |

## Full description

> StageScore is the sheet-music reader from **Backing & Score** — built for the
> moment you are actually playing, not for browsing a library.
>
> Import your PDF charts and StageScore turns a tablet into a music stand that
> behaves. Pages turn from a tap, a swipe, or a Bluetooth pedal, with the delay
> and animation you choose. Build a setlist and the whole set plays through
> without going back to a menu. Reorder pages to follow repeats and codas, so
> a D.S. al Coda stops being a scramble.
>
> **On the stand**
> • Page turns by tap zone, swipe, or Bluetooth pedal / keyboard
> • Performance mode hides everything but the music until you ask for it
> • Layouts for one page, two-page spreads, and half-page peeks
> • Page order for repeats and jumps, and jump links you tap on the page itself
> • Bookmarks by name, and a page scrubber for the rest
> • Pinch to zoom, or lock zoom so nothing moves mid-piece
>
> **Before the gig**
> • Setlists that run in order
> • Draw, highlight, and stamp musical symbols on any page; hide the markup or
>   share the marked-up PDF
> • Labels, search across titles and bookmarks, and sorting by what you played
>   last
> • A metronome with tempo, meter, accent, and a visual-only mode
> • Backup and restore your whole library as a single file
>
> **Yours, on the device**
> Everything lives on your device. StageScore works with no network at all: no
> account, no sign-in, no ads, and nothing collected about you or your music.
>
> **Part of Backing & Score**
> Interactive sheet music, play-along backing tracks and live classes are at
> backingscore.com. StageScore is the part that comes to the gig.

## Required URLs (R10)

| Field | Value | State |
|-------|-------|-------|
| Privacy policy | https://backingscore.com/privacy | **live and verified `200` on 2026-07-30**, with the rewritten StageScore section (R22). This row said "not yet deployed" until that check; it was stale |
| Support | support@backingscore.com | **receiving mail** since 2026-07-28 (Cloudflare Email Routing; MX verified) |
| Support page | https://backingscore.com/support | **live and verified `200` on 2026-07-30.** This is what goes in Apple's Support URL field; Play accepts the address alone |
| Marketing | https://backingscore.com/stagescore | the app's landing page (ADR 0011 — a path, not a subdomain). **Live and verified `200` on 2026-07-30.** This is what goes in the Marketing URL field, not the site root. **Fill this field at v1 even though nothing in v1 needs it.** At 1.1, AdMob finds `app-ads.txt` by crawling the *hostname* of the developer website in the store listing (Marketing URL on Apple, App support on Play), and it can only do that once the app is published. The hostname here is `backingscore.com`, which is where `app-ads.txt` will live, so this path is fine — but an empty field at v1 means the 1.1 clock does not even start, with no warning anywhere (R26, ADR 0018 decision 13) |

## Screenshots to shoot (R12)

Logo locked (R6, 2026-07-31) — shoot from the current build; no icon regen
waiting. Order matters: the first two are what a browsing musician actually sees.

1. A real chart in Performance mode on a tablet, chrome hidden — the product in one frame
2. Two-page spread with the page-turn tap zones called out
3. Setlist running, showing the next piece queued
4. Markup on a page: highlight, symbol stamp, and a jump link
5. Library with thumbnails, labels, and the search field — v1 has no ads, so
   nothing to avoid here; **frame it so a bottom banner in 1.1 costs one reshoot
   rather than six** (ADR 0018 question 9). At 1.1 this shot is taken in the
   purchased, ad-free state, since store screenshots may not show third-party ads
6. Metronome sheet open over a Score

Sizes: iPhone 6.9" and 6.5", iPad 13" and 12.9", plus Play's phone / 7" / 10"
tablet sets. Use the bundled sample Score or our own charts — nothing whose
rights we do not hold (R13).

## Data safety / App Privacy answers (R11)

Both forms answer the same way and must match the `PrivacyInfo.xcprivacy` files
from R2: **no data collected, no data shared, no tracking.** Files the musician
imports never leave the device; the only outbound traffic in the app is the
three links in About, which hand a URL to the system browser.

**This answer is true of v1 and stops being true at 1.1.** When ads ship, both
forms gain the advertising ID (non-personalised ads still use it for frequency
capping — on Android that is why `AD_ID` joins the manifest), purchase history
from RevenueCat, whatever the two SDK privacy manifests list, and Play's
**"Contains ads"** label. `NSPrivacyTracking` stays `false` even then, because
declaring tracking would require an ATT prompt that ADR 0018 forbids. Do not
pre-fill any of that: the forms are answered per submission, and answering them
early makes v1's declaration wrong.
