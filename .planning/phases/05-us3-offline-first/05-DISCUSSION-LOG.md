# Phase 5: US3 Offline-First - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-05-28
**Phase:** 05-us3-offline-first
**Mode:** --auto (all decisions auto-selected with recommended defaults)
**Areas discussed:** Download trigger, Wi-Fi gating, Download UI, Offline playback switching, Offline-unavailable state, Storage guard

---

## Download Trigger Strategy

| Option | Description | Selected |
|--------|-------------|----------|
| Auto on enrollment (Wi-Fi, background) | Enqueue all exercises when student enrolls | ✓ |
| Manual only (student taps download) | Student explicitly downloads each session | |
| Auto + manual fallback | Auto-enqueue on enrollment; manual per-session as fallback | ✓ (combined) |

**Auto-selected:** Auto-enqueue on enrollment as primary; per-session manual tap as fallback for
sessions missed (e.g., enrolled offline). Recommended default for offline-first apps.

---

## Wi-Fi Gating

| Option | Description | Selected |
|--------|-------------|----------|
| Wi-Fi only (requiresWiFi: true) | Downloads only on Wi-Fi, no user toggle | ✓ |
| User toggle (Wi-Fi only by default) | User can enable cellular in settings | |
| Always allow cellular | No restriction | |

**Auto-selected:** Wi-Fi only. Aligns with spec ("on Wi-Fi"), simplest in v1, no settings screen needed.

---

## Download UI

| Option | Description | Selected |
|--------|-------------|----------|
| Inline per-session badge | Icon/progress on session row | ✓ |
| Separate Downloads screen | Dedicated management page | |
| Both | Inline badge + downloads screen | |

**Auto-selected:** Inline per-session badge only. Separate screen deferred to Phase 9 polish.

---

## Offline Playback Switching

| Option | Description | Selected |
|--------|-------------|----------|
| Auto-detect at play time (check manifest) | Player checks local file first, falls back to HLS | ✓ |
| Explicit mode switch (online/offline toggle) | User or app toggles a mode | |
| Always stream (no local fallback) | Never use local files | |

**Auto-selected:** Auto-detect at play time. Transparent to student — no mode switching UX needed.

---

## Offline-Unavailable State

| Option | Description | Selected |
|--------|-------------|----------|
| Inline disabled state on session row | Row disabled, label "Not available offline" | ✓ |
| Navigate to player with error screen | Navigate, show download required screen | |
| Block at session row with modal | Show modal dialog | |

**Auto-selected:** Inline disabled state. Non-navigating, informational, not alarming.

---

## Storage Guard

| Option | Description | Selected |
|--------|-------------|----------|
| Silent skip + SnackBar | Skip enqueue silently, show one-time snackbar | ✓ |
| Modal alert | Block with dialog | |
| Strict block (no enqueue, no feedback) | Silent skip only | |

**Auto-selected:** Silent skip + dismissible SnackBar. Best UX — doesn't interrupt workout flow
but informs the student.

---

## Claude's Discretion

- Icon choice for download state badges
- Whether storage check uses `dart:io` StatFs or a `disk_space` package
- Exact snackbar copy for storage warning
- Animation style for inline progress indicator on session rows
- Whether to show total download size estimate on session card
