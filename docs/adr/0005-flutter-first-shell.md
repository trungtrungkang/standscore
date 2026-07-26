# Application shell: Flutter-first (PDF & annotation)

Given early-phase **ScorePDF parity** (ADR 0008) and the requirement that **PDF viewing and annotation must feel good on device**, the app shell is **Flutter** for iOS/Android (and Flutter Web as a secondary target). SmartMode (Verovio) will later run in an embedded **WebView** inside the same Flutter shell.

**Status:** accepted  
**Decided by:** Human Orchestrator (2026-07-22)

## Decision

| Layer | Choice |
|-------|--------|
| UI shell (PdfMode, library, setlist, settings) | **Flutter** |
| PDF render | **PDFium** via maintained Flutter binding (e.g. `pdfrx` or equivalent — confirm in spike) |
| Annotation | Flutter canvas overlay in **page coordinate space** |
| Stylus | Flutter pointer + platform pencil APIs |
| SmartMode later | `webview_flutter` hosting Verovio WASM (ADR 0003) |
| Transport later | Native audio plugins / FFI (ADR 0004, 0007) |
| Bundle ID | `com.backingscore.scoreapp` (ADR 0009) |

## Considered options

| Option | Verdict |
|--------|---------|
| **A. React + Capacitor everywhere** | Rejected — PDF/annotation UX is a hard requirement |
| **B. Flutter shell + WebView for Verovio later** | **Accepted** |
| **C. Pure native PdfMode + WebView SmartMode** | Rejected for now — dual UI fights AI-primary delivery |
| Commercial PDF SDK in RN | Not chosen; revisit only if Flutter spike fails |

## Consequences

- Early Feature Specs (P0–P2) are Flutter-only.
- Module seam: `PdfMode` (Flutter) vs future `SmartModeHost` (WebView).
- Flutter Web PDF parity is not a blocker for mobile.
- Next: Spec **0001** PDF+annotate spike must pass before product P0 Specs scale up.
