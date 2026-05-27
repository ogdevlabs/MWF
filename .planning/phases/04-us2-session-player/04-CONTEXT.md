# Phase 4: US2 Session Player - Context

**Gathered:** 2026-05-26
**Status:** Ready for planning

<domain>
## Phase Boundary

A subscribed enrolled student opens their active program, sees the session list with
lock/complete/current state, launches today's session, plays through each exercise
(video + optional on-demand 3D companion), and reaches a motivational completion screen.

This phase does NOT include: offline download/sync (Phase 5), coach feedback submission
(Phase 7), body metric logging (Phase 6).

</domain>

<decisions>
## Implementation Decisions

### Video + 3D Companion Layout
- **D-01:** Video is the primary content, full-screen during playback. The 3D model is
  a secondary on-demand reference — not shown by default.
- **D-02:** A small icon button (e.g., a 3D/body-form icon) overlaid on the video player
  lets the student toggle the 3D model open. When tapped, the model opens as a
  bottom sheet or slide-up panel over the video. Tapping again closes it.
- **D-03:** The 3D model viewer uses `model_viewer_plus` (already in pubspec) with the
  GLB asset URL from `exercises.model_asset_url`.

### Exercise Navigation
- **D-04:** Navigation through exercises is **always manual** — the student taps a
  "Next Exercise" button when they are ready, for both rep-based and timer-based exercises.
- **D-05:** For timer-based exercises, the countdown reaching zero enables/highlights
  the Next button but does NOT auto-advance. Student still taps to continue.

### Rep Counter / Timer Overlay
- **D-06:** Rep-based exercises: large tap-target counter overlay. Each tap increments
  the count toward the target (e.g., "8 / 12 reps"). When target is reached, the
  Next button activates/highlights.
- **D-07:** Timer-based exercises: visible countdown timer overlay. Counts down to zero,
  then Next button activates. Student taps Next when ready.
- **D-08:** Exercise cue text (`exercises.cue_text`) is displayed as a persistent strip
  or card below the video/overlay area.

### Session List (Program Detail Screen)
- **D-09:** Replace the existing placeholder in `ProgramDetailScreen` with rich session
  rows showing: day number, session title, exercise count, estimated duration (~20 min),
  and a clear state indicator (✔ complete | ▶ current/today | 🔒 locked).
- **D-10:** "Today's session" row is highlighted (current day from `enrollment.current_day`).
  Past sessions show checkmark; future sessions show lock icon and are non-tappable.
- **D-11:** Tapping the current or any past (completed) session navigates to the session
  player screen via the existing `/programs/:programId/session/:sessionId` route.

### Completion Screen
- **D-12:** Full-screen motivational completion screen appears after the last exercise's
  Next button is tapped. Shows: session title, total duration, exercise count, current
  streak badge (from `FR-014`), and a prominent CTA to "Send Feedback to Coach"
  (routes to `/feedback/:sessionId` placeholder — Phase 7 will implement it).
- **D-13:** Completion records a `progress_record` (command), increments
  `enrollment.current_day` (command), and updates the streak counter.
- **D-14:** A secondary "Back to Program" button dismisses the completion screen and
  returns to `ProgramDetailScreen`.

### Session Resume
- **D-15:** Per `FR-013` and spec acceptance scenario US2-SC4: re-opening the app
  mid-session resumes from the last incomplete exercise. The current exercise index
  is persisted locally (Drift) as session progress state and cleared on completion.

### Claude's Discretion
- Exact split ratios / sizing of the video area and bottom cue strip within the player screen
- Specific animation or visual polish on the rep counter (e.g., pulse on tap)
- Icon choice for the 3D model toggle button
- Whether cue text scrolls or truncates with a "more" expand
- Confetti or animation style on the completion screen (keep it appropriate for a Pilates app — calm, not loud)

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Specification & Requirements
- `specs/001-mat-pilates-coach/spec.md` — User Story 2 (FR-004, FR-005, FR-012, FR-013, FR-014, SC-002, SC-003)
- `specs/001-mat-pilates-coach/data-model.md` — `sessions`, `exercises`, `progress_records`, `enrollments`, `download_manifest` tables; `session_playback_view` CQRS projection

### Existing Code (integration points)
- `mobile/lib/shared/router/app_router.dart` — `/programs/:programId/session/:sessionId` route placeholder to replace
- `mobile/lib/features/programs/presentation/program_detail_screen.dart` — session list placeholder and "Continue Program" CTA to wire up
- `mobile/lib/features/programs/domain/program_model.dart` — `ProgramModel`, `currentDay`, `isEnrolled` extensions
- `mobile/pubspec.yaml` — `video_player`, `chewie`, `model_viewer_plus`, `background_downloader` already declared

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `chewie` + `video_player`: HLS playback stack already in pubspec — use Chewie controller wrapping VideoPlayerController for the exercise video
- `model_viewer_plus`: GLB/glTF rendering already in pubspec — wire to `exercises.model_asset_url`
- `ProgramDetailScreen` (`_ProgramDetailBody`): session list placeholder section at line 131–147 is the exact spot to replace with real session rows
- `AppTheme`: sage-green Material 3 theme — use `colorScheme.primary` for progress/active states, Cards with `borderRadius: 12` established pattern
- `go_router` nested routes: session player route already declared at `/programs/:programId/session/:sessionId`

### Established Patterns
- Riverpod + Freezed for domain models and providers (all Phase 2/3 features follow this)
- CQRS: commands write to normalized tables, queries read from `*_view` projections via `QueryGateway`
- `ConsumerWidget` + `ref.watch(someProvider)` for reactive UI

### Integration Points
- `ProgramDetailScreen._buildCTA()` → replace `ScaffoldMessenger` placeholder with `context.goNamed('session-player', pathParameters: {...})`
- `_PlaceholderScreen` at `session-player` route → replace with real `SessionPlayerScreen`
- `progress_records` command write + `enrollment.current_day` increment on session complete
- `sync_queue` for offline-recorded completions (Phase 5 will handle sync; this phase writes to local Drift only)

</code_context>

<specifics>
## Specific Ideas

- The 3D model is purely a **form-reference helper** — it's secondary to the video. Most students will watch the video; the 3D model is for students who want to inspect body positioning from a different angle.
- The toggle icon should be subtle and non-intrusive (not a big button competing with video controls).
- Completion screen should feel **calm and accomplishing** — consistent with Pilates aesthetics (not gym-bro hype). Subtle animation is fine.

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>

---

*Phase: 04-us2-session-player*
*Context gathered: 2026-05-26*
