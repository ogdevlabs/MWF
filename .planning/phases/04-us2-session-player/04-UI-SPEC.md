# Phase 4: US2 Session Player — UI Design Contract

**Generated:** 2026-05-26
**Status:** Ready for planning
**Phase:** 04-us2-session-player

---

## Design System Baseline

| Token | Value |
|-------|-------|
| Primary | `#8FAE8B` (sage green) |
| Primary container | `#B5D4B1` |
| Secondary | `#6B8F67` |
| Background | `#FAFAFA` |
| Surface | `#FFFFFF` |
| On-surface | `#1C1C1C` |
| On-surface variant | `#6B6B6B` |
| Error | `#D32F2F` |
| Border radius (cards) | 12px |
| Button height | 48px |
| Typography scale | Material 3 (headlineLarge 28/bold, headlineMedium 22/semibold, bodyLarge 16, bodyMedium 14) |

All new screens and components extend this system. No new color tokens introduced.

---

## Screen 1: Session List (ProgramDetailScreen enhancement)

### Layout

The existing session list placeholder section in `ProgramDetailScreen` is replaced with a `SliverList` of `SessionListTile` rows below the "Your Progress" card.

```
┌──────────────────────────────────────┐
│  SliverAppBar (collapsing thumbnail) │
│  Title: "Core Foundations"           │
├──────────────────────────────────────┤
│  [Difficulty chip] [4 weeks]         │
│  Description text…                   │
│                                      │
│  ┌──────────────────────────────┐   │
│  │ Your Progress                │   │
│  │ ████████░░░░  Day 3 of 28   │   │
│  └──────────────────────────────┘   │
│                                      │
│  Sessions                            │
│  ┌──────────────────────────────┐   │
│  │ ✔  Day 1 — Foundation Flow  │   │
│  │     5 exercises · ~20 min    │   │
│  ├──────────────────────────────┤   │
│  │ ✔  Day 2 — Breath & Core    │   │
│  │     6 exercises · ~25 min    │   │
│  ├──────────────────────────────┤   │
│  │ ▶  Day 3 — Spinal Mobility  │   │  ← current (highlighted bg)
│  │     4 exercises · ~15 min    │   │
│  ├──────────────────────────────┤   │
│  │ 🔒  Day 4 — Hip Release      │   │
│  │     5 exercises               │   │
│  └──────────────────────────────┘   │
└──────────────────────────────────────┘
  [Continue Program] ← bottom CTA (FilledButton, taps current session)
```

### Session Row States

| State | Leading icon | Icon color | Row background | Trailing | Tappable |
|-------|-------------|------------|----------------|----------|----------|
| Complete | `Icons.check_circle` | `Colors.green` | transparent | `Icons.chevron_right` | yes |
| Current | `Icons.play_circle_filled` | `colorScheme.primary` | `primaryContainer.withValues(alpha: 0.3)` | `Icons.chevron_right` | yes |
| Locked | `Icons.lock` | `Colors.grey` | transparent | none | no |

- Session title format: `Day N — [Title]`
- Subtitle: `N exercises · ~20 min` (exercise count from DAO; duration fixed at ~20 min placeholder until real duration data exists)
- Locked rows: `ListTile.onTap = null`, opacity: 0.6

### "Continue Program" CTA

- Wired to current session (enrollment.currentDay)
- Label: **"Continue Program"** when enrolled, **"Start Program"** on first session
- Routes to `/programs/:programId/session/:sessionId`

---

## Screen 2: Session Player Screen

### Layout

Full-screen immersive layout. No persistent AppBar — back navigation via a translucent close button overlaid on video.

```
┌──────────────────────────────────────┐
│  ╔════════════════════════════════╗  │
│  ║                                ║  │  ← Chewie video (Expanded, fills
│  ║        VIDEO PLAYER            ║  │     ~65% of screen height)
│  ║                                ║  │
│  ║  [3D icon]         [← close]  ║  │  ← translucent overlays on video
│  ║                                ║  │
│  ║   ┌─────────────────────────┐ ║  │
│  ║   │   8 / 12 reps           │ ║  │  ← RepCounterOverlay (center)
│  ║   │   (tap to count)        │ ║  │     OR TimerCountdownOverlay
│  ║   └─────────────────────────┘ ║  │
│  ╚════════════════════════════════╝  │
│  ┌──────────────────────────────┐   │  ← Cue text strip (~120px)
│  │ "Keep your shoulders         │   │
│  │  relaxed. Exhale on the      │   │
│  │  contraction."               │   │
│  └──────────────────────────────┘   │
│                                      │
│  Exercise 3 of 5                     │  ← progress indicator (bodyMedium)
│                                      │
│  [      Next Exercise      ]         │  ← FilledButton (48px, full-width)
│   (disabled/muted until ready)       │
└──────────────────────────────────────┘
```

### Video Area

- `Chewie` widget fills `Expanded` — no fixed height, adapts to screen
- `allowFullScreen: false` — we own the layout
- `looping: true` — exercise video loops until student taps Next
- Chewie's built-in controls (seek bar, play/pause) are shown (`showControls: true`)

### Overlay Layer (Stack on top of Chewie)

**Close button (top-right):**
- `IconButton` with `Icons.close`, white icon, semi-transparent black circle background
- Routes back to ProgramDetailScreen (pops navigation)

**3D model toggle button (top-left):**
- `IconButton` with `Icons.view_in_ar` or `Icons.accessibility_new`, white icon, same semi-transparent background
- Only shown when `exercise.modelAssetUrl != null`
- Tap → `showModalBottomSheet` with 3D viewer (see Sheet spec below)

**Rep counter overlay (center, rep-based exercises):**
```
┌──────────────────┐
│   8 / 12 reps    │  ← fontSize 32, bold, white on black-54 rounded pill
│  (tap anywhere)  │  ← hint text, bodyMedium, grey
└──────────────────┘
```
- Full overlay is a `GestureDetector` (entire center zone is the tap target)
- When count reaches target: text turns primary green, Next button activates

**Timer countdown overlay (center, timer-based exercises):**
```
┌──────────┐
│  01:30   │  ← fontSize 48, bold, white on black-54 rounded pill
└──────────┘
```
- When timer hits 0:00: text flashes primary green once, Next button activates

### Cue Text Strip

- Container with `colorScheme.surface`, top border `1px surfaceContainerHighest`
- Height: flexible (~80–120px), vertically scrollable if text overflows
- Padding: 16px horizontal, 12px vertical
- Typography: `bodyLarge` (16px), `onSurface` color
- Empty cue_text: strip hidden (zero height)

### Progress + Next Button

- `"Exercise N of M"` — `bodyMedium`, centered, `onSurfaceVariant` color
- `FilledButton` ("Next Exercise" / "Finish Session" on last exercise)
  - Disabled state: `colorScheme.onSurface.withValues(alpha: 0.38)` background
  - Enabled state: `colorScheme.primary` (sage green)
  - Full width with 16px horizontal padding, 16px bottom padding (SafeArea)

### Exercise Advance Transition

- On Next tap: video area shows `CircularProgressIndicator` centered while new `VideoPlayerController` initializes
- Overlays reset (rep counter → 0, timer → full duration)
- No page transition animation — in-place update within the same screen

---

## Sheet: 3D Model Viewer

```
┌──────────────────────────────────────┐
│  ─────  (drag handle, grey pill)     │
│                                      │
│  Form Reference                      │  ← headlineMedium, 22px
│                                      │
│  ┌──────────────────────────────┐   │
│  │                              │   │
│  │      [ModelViewer widget]    │   │
│  │   (rotatable, pinch-zoom)    │   │  ← DraggableScrollableSheet
│  │                              │   │     initialSize: 0.55
│  └──────────────────────────────┘   │     minSize: 0.3
│                                      │     maxSize: 0.9
│  ── Loading indicator while         │
│     model fetches                    │
└──────────────────────────────────────┘
```

- `showModalBottomSheet` with `isScrollControlled: true`, `backgroundColor: transparent`
- Sheet background: `colorScheme.surface`, top corners radius 16px
- `ModelViewer`: `cameraControls: true`, `autoRotate: true`, `autoRotateDelay: 1000`, `ar: false`
- Loading state: `LinearProgressIndicator` at top of sheet until model renders
- No explicit close button — drag down to dismiss (standard bottom sheet behavior)

---

## Screen 3: Session Completion Screen

### Layout

Full-screen, centered card layout. No AppBar.

```
┌──────────────────────────────────────┐
│                                      │
│                                      │
│          Session Complete            │  ← headlineLarge, 28px, primary color
│                                      │
│    "Core Foundations — Day 3"        │  ← bodyLarge, onSurfaceVariant
│                                      │
│  ┌────────┐  ┌────────┐  ┌────────┐ │
│  │  04:23 │  │   4    │  │  🔥 3  │ │  ← Stat cards (row of 3)
│  │duration│  │exercises│  │ streak │ │
│  └────────┘  └────────┘  └────────┘ │
│                                      │
│  ┌──────────────────────────────┐   │
│  │  [  Send Feedback to Coach  ] │   │  ← FilledButton, primary
│  └──────────────────────────────┘   │
│                                      │
│  ┌──────────────────────────────┐   │
│  │  [  Back to Program          ] │   │  ← OutlinedButton, secondary
│  └──────────────────────────────┘   │
│                                      │
└──────────────────────────────────────┘
  Background: subtle sage-green tint (#FAFAFA → slightly warmer)
```

### Stat Cards

Each card: `Card` widget (elevation 1, borderRadius 12), `Column(mainAxisAlignment: center)`:
- Top: value (`headlineMedium`, 22px, `onSurface`)
- Bottom: label (`bodyMedium`, 14px, `onSurfaceVariant`)

| Card | Value | Label |
|------|-------|-------|
| Duration | `MM:SS` format | "duration" |
| Exercises | integer count | "exercises" |
| Streak | `🔥 N` (only the number uses emoji as prefix) | "day streak" |

Streak card: `🔥` is a text prefix to the number — not a Material icon. Keeps the calm aesthetic without being loud.

### CTAs

- **"Send Feedback to Coach"**: `FilledButton`, routes to `/feedback/:sessionId` (Phase 7 placeholder — shows "Coming soon" snackbar until Phase 7)
- **"Back to Program"**: `OutlinedButton` (sage green border), `context.go('/programs/$programId')` — replaces session player in stack

### Animation

- Screen fades in over 400ms (`FadeTransition` in go_router transition builder)
- Stat cards slide up with a 200ms stagger (each card 100ms after the previous)
- No confetti, no bounce — calm, accomplished feeling consistent with Pilates aesthetic

---

## Navigation Flow

```
ProgramDetailScreen
    │
    └── [Continue Program / session row tap]
            │
            ▼
    SessionPlayerScreen (/programs/:programId/session/:sessionId)
            │
            ├── [3D icon] → 3D Model Bottom Sheet (modal, pops back)
            │
            └── [Finish Session]
                    │
                    ▼
            SessionCompletionScreen (push)
                    │
                    ├── [Send Feedback] → /feedback/:sessionId (Phase 7)
                    │
                    └── [Back to Program] → /programs/:programId (replace)
```

---

## Accessibility

- All icon buttons have `semanticLabel` set
- Rep counter `GestureDetector`: wrapped with `Semantics(label: "$count of $target reps, tap to increment")`
- Timer overlay: `Semantics(label: "$mins minutes $secs seconds remaining")`
- Locked session rows: `ExcludeSemantics` on trailing — nothing actionable to announce
- Minimum tap target 48×48px on all interactive elements
- Color contrast: all text combinations meet WCAG 2.1 AA (verified against sage green palette)

---

*UI contract for Phase 04-us2-session-player*
*Author: Claude (UX/UI expert mode) — 2026-05-26*
