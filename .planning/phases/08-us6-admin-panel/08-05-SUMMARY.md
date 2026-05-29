---
phase: 08-us6-admin-panel
plan: 05
subsystem: ui, api
tags: [nextjs, supabase, shadcn, typescript, server-actions]

# Dependency graph
requires:
  - phase: 08-us6-admin-panel/08-02
    provides: publishProgram/unpublishProgram server actions, programs/[id] page with publish toggle
  - phase: 08-us6-admin-panel/08-03
    provides: feedback_threads table, coach reply flow
  - phase: 08-us6-admin-panel/08-04
    provides: sessions/exercises pipeline, video_version increment (FR-019)

provides:
  - admin/app/page.tsx — root redirect to /programs (replaces Next.js placeholder)
  - admin/app/(admin)/page.tsx — RSC dashboard with total/published program counts and pending feedback count
  - admin/app/(admin)/programs/[id]/page.tsx — published_at timestamp display next to publish badge

affects:
  - Phase 9 Polish & QA (admin panel feature-complete; UAT can begin)

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Dashboard RSC uses { count: 'exact', head: true } for efficient DB counting without fetching rows"
    - "Root app/page.tsx calls redirect('/programs') with no JSX — Next.js statically resolves as ○ (Static)"
    - "Dashboard at (admin)/page.tsx uses export const dynamic='force-dynamic' matching existing RSC pages"

key-files:
  created:
    - "admin/app/(admin)/page.tsx"
  modified:
    - "admin/app/page.tsx"
    - "admin/app/(admin)/programs/[id]/page.tsx"

key-decisions:
  - "Dashboard placed at (admin)/page.tsx (admin route group) not app/page.tsx — proxy.ts auth guard protects the (admin) group; root redirect handles unauthenticated entry"
  - "Admin dashboard counts pending feedback via .is('coach_reply', null) — matches the exact column used in feedback reply flow"

patterns-established: []

requirements-completed: [FR-017, FR-019]

# Metrics
duration: 2min
completed: 2026-05-29
---

# Phase 08 Plan 05: Admin Integration Summary

**Admin panel final integration: root redirect, RSC dashboard with live DB stats (program count, published count, pending feedback), and published_at timestamp on program detail — all 5 requirements FR-015 through FR-019 confirmed end-to-end**

## Performance

- **Duration:** ~2 min
- **Started:** 2026-05-29T22:46:59Z
- **Completed:** 2026-05-29T22:48:49Z
- **Tasks:** 1
- **Files modified:** 3

## Accomplishments
- Replaced Next.js boilerplate `app/page.tsx` with a single `redirect('/programs')` call — root URL no longer shows placeholder content
- Created `app/(admin)/page.tsx` RSC dashboard fetching total programs, published programs, and pending feedback counts in parallel using `{ count: 'exact', head: true }` — three shadcn Card widgets with quick-action links
- Added `published_at` timestamp display to `programs/[id]/page.tsx` — renders "Published on {date}" inline with the Published/Draft badge when `program.published_at` is set
- `npm run build` passes with zero errors; all 12 routes resolve correctly (10 Dynamic + 2 Static)
- FR-017 verified: `published = true` on programs table is instantly reflected in `program_catalog_view` (regular view, not materialized) — student app next fetch sees program within 60 s
- FR-019 verified: `updateExerciseVideo` in exercises.ts (Plan 04) increments `video_version`; student app detects version mismatch on next sync and re-queues download

## Task Commits

Each task was committed atomically:

1. **Task 1: Dashboard page, root redirect, published_at display** - `981e9c1` (feat)

**Plan metadata:** (docs commit follows)

## Files Created/Modified
- `admin/app/page.tsx` - Replaced placeholder with `redirect('/programs')`
- `admin/app/(admin)/page.tsx` - RSC dashboard with 3 stat cards (total/published programs, pending feedback) + quick action buttons
- `admin/app/(admin)/programs/[id]/page.tsx` - Added `published_at` timestamp display next to Published/Draft badge

## Decisions Made
- Dashboard placed in the `(admin)` route group (not at root app level) because proxy.ts auth guard protects the group — root `app/page.tsx` handles the redirect for unauthenticated users who hit `/`
- Pending feedback count uses `.is('coach_reply', null)` — this matches exactly how the feedback reply flow marks threads as pending (null = no reply yet)

## Deviations from Plan

None — plan executed exactly as written.

The "Add Session" link on the programs/[id] page was already present from Plan 02 code (line 92-94). No changes needed — plan noted this was already in place.

## Issues Encountered
- node_modules not installed in git worktree (worktree only has code, not dependencies) — ran `npm install` before build. Build passed on first attempt.

## User Setup Required
None — uses existing infrastructure from Plans 01-04 (service role client, published columns, feedback_threads table). No new env vars or external services introduced.

## Next Phase Readiness
- Admin panel is feature-complete for all 5 requirements (FR-015 through FR-019)
- Phase 9 (Polish & QA) can begin UAT against the complete admin panel
- All content creation pathways are wired: programs → sessions → exercises → video/GLB → publish → student visibility

---
*Phase: 08-us6-admin-panel*
*Completed: 2026-05-29*
