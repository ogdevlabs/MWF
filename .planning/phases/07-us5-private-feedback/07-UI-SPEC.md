---
phase: 7
slug: us5-private-feedback
status: approved
reviewed_at: 2026-05-29
shadcn_initialized: false
preset: not applicable (Flutter)
created: 2026-05-29
---

# Phase 7 — UI Design Contract
## US5: Private Coach Chat (Premium DM)

> Visual and interaction contract for Phase 7. Generated from user decisions during /gsd:ui-phase session.

---

## Design System

| Property | Value |
|----------|-------|
| Tool | Flutter Material 3 (no shadcn — Flutter project) |
| Preset | not applicable |
| Component library | Material 3 widgets |
| Icon library | Material Icons |
| Font | System default (Material 3 typography scale) |

All tokens carry over from Phase 4 UI-SPEC. No new tokens introduced.

---

## Spacing Scale

Inherits from Phase 4. Declared values (multiples of 4):

| Token | Value | Usage |
|-------|-------|-------|
| xs | 4px | Icon gaps, inline padding |
| sm | 8px | Compact element spacing |
| md | 16px | Default element spacing |
| lg | 24px | Section padding |
| xl | 32px | Layout gaps |
| 2xl | 48px | Major section breaks |
| 3xl | 64px | Page-level spacing |

Exceptions:
- Chat bubble max-width: 72% of screen width
- Photo thumbnail in bubble: 160×120px
- Compose bar height: 56px minimum (SafeArea-aware)
- Minimum tap targets: 48×48px

---

## Typography

Inherits Material 3 scale from Phase 4. Declared values:

| Role | Size | Weight | Line Height |
|------|------|--------|-------------|
| Body (bodyLarge) | 16px | 400 | 1.5 |
| Label (bodyMedium) | 14px | 400 | 1.4 |
| Heading (headlineMedium) | 22px | 700 | 1.2 |
| Display (headlineLarge) | 28px | 700 | 1.2 |

Two weights only: `400` (body/label) and `700` (headings/display).

Chat-specific:
- Bubble text: bodyLarge (16px, 400)
- Timestamp: bodyMedium (14px, 400), onSurfaceVariant
- Chat screen title: headlineMedium (22px, 700)

---

## Color

Inherits from Phase 4:

| Role | Value | Usage |
|------|-------|-------|
| Dominant (60%) | `#FAFAFA` | Background, screen surfaces |
| Secondary (30%) | `#FFFFFF` | Cards, coach bubbles, surfaces |
| Accent (10%) | `#8FAE8B` (sage green) | Student bubbles, active Send button, upgrade CTA |
| Error/Destructive | `#D32F2F` | Error states only |

Accent reserved for:
- Student chat bubble background
- Active Send button (`FilledButton`)
- Upgrade to Premium CTA button
- Bottom nav active indicator on Coach tab

Additional chat-specific tokens:
- Coach bubble background: `colorScheme.surfaceContainerHighest` (~`#E8E8E8`)
- Student bubble background: `colorScheme.primaryContainer` (`#B5D4B1`)
- Paywall lock icon: `Colors.grey[500]`

---

## Screen 1: Coach Tab — Paywall (Non-Premium)

**Primary visual anchor:** "Upgrade to Premium" FilledButton CTA — largest interactive element, anchored to center of screen with lock icon + heading above it drawing the eye downward.

### Layout

Shown when subscription tier is `basic` (not `premium`). Coach tab is visible in bottom nav but shows a locked state.

```
┌──────────────────────────────────────┐
│  Coach                               │
├──────────────────────────────────────┤
│                                      │
│                                      │
│              🔒                      │
│                                      │
│       Coach Chat                     │  ← headlineMedium, 22px
│    Available on Premium              │  ← bodyLarge, onSurfaceVariant
│                                      │
│  Get direct feedback from your       │
│  coach after every session.          │  ← bodyMedium, onSurfaceVariant
│                                      │
│  ┌──────────────────────────────┐   │
│  │  [ Upgrade to Premium ]      │   │  ← FilledButton, primary (sage green)
│  └──────────────────────────────┘   │
│                                      │
└──────────────────────────────────────┘
```

### Details

- `🔒` icon: `Icons.lock_outline`, size 48, `Colors.grey[400]`
- "Coach Chat" heading: `headlineMedium`, `onSurface`
- "Available on Premium" subtitle: `bodyLarge`, `onSurfaceVariant`
- Description text: `bodyMedium`, `onSurfaceVariant`, 24px horizontal padding
- "Upgrade to Premium" button: `FilledButton`, `colorScheme.primary`, full-width with 24px padding, height 48px
- Routes to RevenueCat paywall (existing flow from Phase 3)

---

## Screen 2: Coach Chat Screen (Premium)

**Primary visual anchor:** The compose bar at the bottom — always visible and the action center of the screen. Latest messages naturally draw the eye upward from it.

Single conversation thread — 1-to-1 DM between student and coach. Always accessible from the Coach tab.

### Layout

```
┌──────────────────────────────────────┐
│ ← Coach                              │  ← AppBar, title "Coach", back nav
├──────────────────────────────────────┤
│                                      │
│  [Coach] 9:00 AM                     │  ← sender label + timestamp, bodyMedium 14px
│  ┌──────────────────────────────┐   │  ← coach bubble (left-aligned)
│  │ Hi! Complete a session and   │   │
│  │ send me a note — I'd love    │   │
│  │ to hear how it went. 🌿     │   │
│  └──────────────────────────────┘   │
│                                      │
│                         9:14 AM [You]│  ← right-aligned sender/timestamp
│       ┌──────────────────────────┐  │  ← student bubble (right-aligned)
│       │ ┌──────────────────────┐ │  │  ← photo thumbnail (if attached)
│       │ │   [photo: 160×120]   │ │  │
│       │ └──────────────────────┘ │  │
│       │ Felt strong today but    │  │
│       │ left hip tight again.   │  │
│       └──────────────────────────┘  │
│                                      │
│  [Coach] 2:30 PM                     │
│  ┌──────────────────────────────┐   │
│  │ Try adding the hip release   │   │
│  │ stretch after the session.   │   │
│  └──────────────────────────────┘   │
│                                      │
├──────────────────────────────────────┤
│ ┌────────────────────────────┐ [📷] │  ← compose bar
│ │ Message coach…             │      │
│ └────────────────────────────┘ [▶] │  ← Send button (FilledButton icon)
└──────────────────────────────────────┘
```

### Chat Bubble Specs

| Property | Coach Bubble | Student Bubble |
|----------|-------------|----------------|
| Alignment | Left | Right |
| Background | `colorScheme.surfaceContainerHighest` | `colorScheme.primaryContainer` (`#B5D4B1`) |
| Border radius | 12px (all corners except top-left = 4px) | 12px (all except top-right = 4px) |
| Padding | 12px horizontal, 8px vertical | 12px horizontal, 8px vertical |
| Max width | 72% of screen width | 72% of screen width |
| Text color | `onSurface` | `onSurface` |
| Font | bodyLarge, 16px, 400 | bodyLarge, 16px, 400 |

### Sender Label + Timestamp

- Coach messages: `"[Coach] HH:MM AM/PM"` — `bodyMedium` 14px, `onSurfaceVariant`, left-aligned, 4px below bubble top
- Student messages: `"HH:MM AM/PM [You]"` — same style, right-aligned

### Photo Thumbnail (in student bubble)

- Displayed above text when photo is attached
- Size: 160×120px, `borderRadius: 8px`
- Tap → `showDialog` with full-size image viewer (`InteractiveViewer`)
- Loading: `CircularProgressIndicator` placeholder while loading from Supabase Storage
- If photo only (no text): bubble contains thumbnail only

### Welcome Message (empty state)

- Pre-seeded coach message: `"Hi! Complete a session and send me a note — I'd love to hear how it went. 🌿"`
- Stored as a system message in the local DB (not from Supabase) — shown only when no real messages exist
- Appears as a standard coach bubble — no special treatment

### Compose Bar

- Always visible at the bottom (not session-gated)
- `TextField` with hint text: `"Message coach…"`, `bodyLarge`, `onSurfaceVariant`
- Border: `OutlineInputBorder`, `borderRadius: 24px`, `colorScheme.outline`
- `[📷]` icon button: `Icons.photo_camera_outlined`, opens image picker
- `[▶]` Send button: `FilledButton` with `Icons.send`, 44×44px, disabled when text empty and no photo
- Camera and Send icons follow universal chat iconography convention — no visible text label required; semanticLabels cover accessibility
- Send button disabled state: `colorScheme.onSurface.withValues(alpha: 0.38)`
- Send button enabled state: `colorScheme.primary` (sage green)
- Compose bar background: `colorScheme.surface`, top border 1px `colorScheme.outlineVariant`
- Keyboard-aware: wraps in `Padding` with `MediaQuery.viewInsets.bottom`

---

## Bottom Sheet: Feedback Compose (from Session Completion)

Triggered from the "Send Feedback to Coach" button on `SessionCompletionScreen`.

### Layout

```
┌──────────────────────────────────────┐
│  ──  (drag handle, grey pill, 32×4)  │
│                                      │
│  Send Feedback to Coach              │  ← headlineMedium, 22px
│  Session: Day 3 — Core Foundations  │  ← bodyMedium, onSurfaceVariant, 1 line
│                                      │
│ ┌──────────────────────────────────┐ │
│ │ Write a note to your coach…      │ │  ← multiline TextField, min 4 lines
│ │                                  │ │
│ │                                  │ │
│ └──────────────────────────────────┘ │
│                                      │
│ [📷 Attach Photo]  (optional badge)  │  ← TextButton with icon, left-aligned
│                                      │
│ [          Send Note          ]      │  ← FilledButton, full-width, 48px
└──────────────────────────────────────┘
```

### Details

- `showModalBottomSheet` with `isScrollControlled: true`, `backgroundColor: transparent`
- Sheet background: `colorScheme.surface`, top corners radius 16px
- Drag handle: 32×4px, `colorScheme.outlineVariant`, centered, 8px top padding
- "Send Feedback to Coach" title: `headlineMedium`, 22px, 700, `onSurface`
- Session subtitle: `bodyMedium`, 14px, `onSurfaceVariant` — format: `"Session: Day N — [Program Name]"`
- `TextField`: `OutlineInputBorder`, `borderRadius: 8px`, `minLines: 4`, `maxLines: null`
- "Attach Photo" button: `TextButton` with `Icons.photo_camera_outlined` leading icon, `onSurfaceVariant` color
  - When photo attached: show thumbnail preview (80×60px) with ✕ remove button overlay
- "Send Note" button: `FilledButton`, `colorScheme.primary`, full-width, height 48px, 16px bottom padding (SafeArea)
  - Disabled when text empty AND no photo attached
- On send success: sheet dismisses, `SnackBar` confirmation: `"Note sent to coach"`
- On send error: `SnackBar` error: `"Failed to send — tap to retry"`
- Sheet resizes with keyboard (`Padding` + `MediaQuery.viewInsets`)

---

## Push Notification

| Property | Value |
|----------|-------|
| Trigger | Coach replies to any student message |
| Title | Coach's display name (from Supabase profile) |
| Body | First 100 chars of reply text |
| Deep link | `/coach-chat` — opens Coach tab chat screen |
| Delivery | Firebase Cloud Messaging (FCM) |
| Target SLA | Reply notification within 60s of coach sending |
| In-app badge | None — OS notification only |

---

## Navigation Flow

```
Bottom Nav: [Home] [Programs] [Progress] [Coach 💬]
                                                │
                               ┌────────────────┴────────────────┐
                               │ Premium student                  │ Basic student
                               ▼                                  ▼
                    CoachChatScreen                    CoachPaywallScreen
                         │                              [Upgrade to Premium]
                         │                                        │
                         └────────────────────────────────────────┘
                                       RevenueCat paywall

SessionCompletionScreen
    │
    └── [Send Feedback to Coach]
            │
            ▼
    FeedbackComposeBottomSheet
    (session-linked message pre-filled with session context,
     posts to same chat thread → CoachChatScreen)
```

---

## Offline Behavior

- Messages composed offline are saved to Drift local DB with `status: pending`
- Visual indicator on pending messages: clock icon (`Icons.schedule`, 12px) beside timestamp
- On reconnect: SyncQueue dispatches pending messages
- On sync success: status updates to `sent`, clock icon disappears
- Photo attachments: upload to Supabase Storage on send; if offline, upload queued

---

## Copywriting Contract

| Element | Copy |
|---------|------|
| Coach tab label | "Coach" |
| Paywall heading | "Coach Chat" |
| Paywall subheading | "Available on Premium" |
| Paywall description | "Get direct feedback from your coach after every session." |
| Paywall CTA | "Upgrade to Premium" |
| Welcome message | "Hi! Complete a session and send me a note — I'd love to hear how it went. 🌿" |
| Compose hint | "Message coach…" |
| Sheet compose hint | "Write a note to your coach…" |
| Sheet title | "Send Feedback to Coach" |
| Sheet send CTA | "Send Note" |
| Attach photo label | "Attach Photo" |
| Send success snackbar | "Note sent to coach" |
| Send error snackbar | "Failed to send — tap to retry" |
| Offline pending indicator | (clock icon only — no text) |

---

## Accessibility

- All icon buttons have `semanticLabel` set
- Chat bubbles: `Semantics(label: "[Coach/You] at [time]: [message text]")`
- Photo thumbnail: `Semantics(label: "Attached photo, tap to view full size")`
- Compose `TextField`: `textInputAction: TextInputAction.newline`
- Paywall lock icon: `ExcludeSemantics` (decorative)
- Paywall CTA: `semanticLabel: "Upgrade to Premium subscription"`
- Minimum tap targets: 48×48px on all interactive elements

---

## Registry Safety

| Registry | Blocks Used | Safety Gate |
|----------|-------------|-------------|
| Flutter pub.dev | `flutter_local_notifications`, `firebase_messaging`, `image_picker` | pub.dev verified — standard packages |

No shadcn/third-party web registries (Flutter project).

---

## Checker Sign-Off

- [ ] Dimension 1 Copywriting: PASS
- [ ] Dimension 2 Visuals: PASS
- [ ] Dimension 3 Color: PASS
- [ ] Dimension 4 Typography: PASS
- [ ] Dimension 5 Spacing: PASS
- [ ] Dimension 6 Registry Safety: PASS

**Approval:** approved 2026-05-29

---

*UI contract for Phase 07-us5-private-feedback*
*Author: Claude (UI researcher mode) — 2026-05-29*
*Decisions source: user interview (6 questions)*
