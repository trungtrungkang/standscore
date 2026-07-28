# Store listing copy (R12)

**Status:** copy **accepted** by the Orchestrator (2026-07-28, Spec 0042); screenshots outstanding
**Publisher name:** Backing & Score (ADR 0010) — check at submit that the store account name accepts an ampersand
**Category:** Music · **Age rating:** 4+ / Everyone · **Price:** free, no in-app purchase in v1 (R7 still open)

Every claim below is something the shipped build does. Nothing here promises
SmartMode, MusicXML, backing tracks, sync, or an account — the app has none of
them, and the ecosystem sentence names the web product as where those live
rather than implying StageScore does them.

---

## Names and short fields

| Field | Value | Limit |
|-------|-------|-------|
| App Store name | `StageScore` | 30 |
| App Store subtitle | `Sheet music for the stand` | 30 |
| Play title | `StageScore — Sheet Music` | 30 |
| Play short description | `PDF sheet music built for the stand: reliable page turns, setlists, markup. Offline.` | 80 |
| Promotional text (iOS) | `A Backing & Score app. Your PDF charts on the stand — turn pages with a pedal, run a set without touching the screen, mark up anything.` | 170 |
| Keywords (iOS) | `sheet music,pdf,score,setlist,page turner,pedal,bluetooth,music stand,annotate,metronome,gig` | 100 |

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
| Privacy policy | https://backingscore.com/privacy | live, but the **StageScore section is written and not yet deployed** (R22). Do not submit until it is: the old text claims play-logging and analytics that this app does not do |
| Support | support@backingscore.com | **receiving mail** since 2026-07-28 (Cloudflare Email Routing; MX verified) |
| Support page | https://backingscore.com/support | **written, awaiting deploy.** This is what goes in Apple's Support URL field; Play accepts the address alone |
| Marketing | https://backingscore.com/stagescore | the app's landing page (ADR 0011 — a path, not a subdomain). **Written, awaiting deploy.** This is what goes in the Marketing URL field, not the site root |

## Screenshots to shoot (R12)

Order matters: the first two are what a browsing musician actually sees.

1. A real chart in Performance mode on a tablet, chrome hidden — the product in one frame
2. Two-page spread with the page-turn tap zones called out
3. Setlist running, showing the next piece queued
4. Markup on a page: highlight, symbol stamp, and a jump link
5. Library with thumbnails, labels, and the search field
6. Metronome sheet open over a Score

Sizes: iPhone 6.9" and 6.5", iPad 13" and 12.9", plus Play's phone / 7" / 10"
tablet sets. Use the bundled sample Score or our own charts — nothing whose
rights we do not hold (R13).

## Data safety / App Privacy answers (R11)

Both forms answer the same way and must match the `PrivacyInfo.xcprivacy` files
from R2: **no data collected, no data shared, no tracking.** Files the musician
imports never leave the device; the only outbound traffic in the app is the
three links in About, which hand a URL to the system browser.
