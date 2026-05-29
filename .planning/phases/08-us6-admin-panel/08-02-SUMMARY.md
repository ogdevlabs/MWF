---
phase: 08-us6-admin-panel
plan: 02
subsystem: ui, api
tags: [nextjs, supabase, shadcn, server-actions, zod, typescript]

# Dependency graph
requires:
  - phase: 08-us6-admin-panel/08-01
    provides: createServiceClient() service role client, admin shell layout, shadcn components, proxy.ts auth guard

provides:
  - app/actions/programs.ts with createProgram, updateProgram, deleteProgram, publishProgram, unpublishProgram, uploadThumbnail server actions
  - programs list page with Table, Draft/Published Badge, Create button
  - programs/new page with ProgramForm + createProgram action
  - programs/[id] page with edit form, publish toggle, delete button, sessions list
  - ProgramForm client component with useActionState, Select, ThumbnailUploader in edit mode
  - ThumbnailUploader client component uploading to program-assets bucket
  - DeleteProgramButton client component with Dialog confirmation

affects:
  - 08-03 (session/exercise editor needs programs/[id] to have sessions section for navigation)
  - 08-04 (feedback reply pages use same admin shell pattern)

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "export const dynamic='force-dynamic' required on RSC pages calling createServiceClient() — env vars not available at build-time static prerender"
    - "updateProgram.bind(null, program.id) for currying programId into Server Action signature for useActionState compatibility"
    - "publishProgram/unpublishProgram called via form action={fn.bind(null, id)} in RSC for zero-JS publish toggle"

key-files:
  created:
    - "admin/app/actions/programs.ts"
    - "admin/app/(admin)/programs/new/page.tsx"
    - "admin/app/(admin)/programs/[id]/page.tsx"
    - "admin/components/program-form.tsx"
    - "admin/components/thumbnail-uploader.tsx"
    - "admin/components/delete-program-button.tsx"
  modified:
    - "admin/app/(admin)/programs/page.tsx"

key-decisions:
  - "export const dynamic='force-dynamic' on RSC pages using createServiceClient() — prevents Next.js from statically prerendering pages that require runtime env vars"
  - "publish/unpublish buttons use <form action={serverAction.bind(null, id)}> in RSC — no client component needed for simple toggle"
  - "ThumbnailUploader only shown in edit mode (program prop present) — program must exist before upload path can be determined"

patterns-established:
  - "Pattern 5: Server Action binding — updateProgram.bind(null, programId) for passing extra args to useActionState-compatible actions"
  - "Pattern 6: RSC pages with Supabase calls use export const dynamic='force-dynamic' to prevent prerender failure"

requirements-completed: [FR-015, FR-017]

# Metrics
duration: 3min
completed: 2026-05-29
---

# Phase 08 Plan 02: Program CRUD Summary

**Full program CRUD UI: server actions with Zod validation, programs list with Draft/Published badges, create/edit forms with ThumbnailUploader to program-assets bucket, publish toggle, and Dialog-confirmed delete**

## Performance

- **Duration:** ~3 min
- **Started:** 2026-05-29T22:29:55Z
- **Completed:** 2026-05-29T22:33:09Z
- **Tasks:** 2
- **Files modified:** 7

## Accomplishments
- Server actions file with 6 exports: createProgram, updateProgram, deleteProgram, publishProgram (sets published_at), unpublishProgram, uploadThumbnail to program-assets bucket
- Zod ProgramSchema validating title, description, difficulty enum, duration_weeks (coerce to int), thumbnail_url (optional)
- Programs list RSC with shadcn Table showing Title, Difficulty, Duration, Status badge, Edit link + Create Program button
- Edit page RSC with ProgramForm, publish/unpublish toggle via form actions, DeleteProgramButton, sessions list
- ProgramForm client component using useActionState with field-level error display, Select for difficulty, ThumbnailUploader in edit mode
- `npm run build` passes with zero errors

## Task Commits

Each task was committed atomically:

1. **Task 1: Program CRUD server actions** - `58dab62` (feat)
2. **Task 2: Program list, create, edit pages + thumbnail uploader** - `1b39d68` (feat)

**Plan metadata:** (docs commit follows)

## Files Created/Modified
- `admin/app/actions/programs.ts` - 'use server' — 6 server action exports with Zod validation + service role client
- `admin/app/(admin)/programs/page.tsx` - RSC program list with Table, status badges, Create button; dynamic
- `admin/app/(admin)/programs/new/page.tsx` - RSC with ProgramForm + createProgram action
- `admin/app/(admin)/programs/[id]/page.tsx` - RSC edit page with form, publish toggle, delete, sessions list; dynamic
- `admin/components/program-form.tsx` - 'use client' form with useActionState, Select, ThumbnailUploader in edit mode
- `admin/components/thumbnail-uploader.tsx` - 'use client' with file input accept=image/*, uploadThumbnail call
- `admin/components/delete-program-button.tsx` - 'use client' Dialog confirmation with useTransition

## Decisions Made
- Added `export const dynamic = 'force-dynamic'` to pages using `createServiceClient()` — Next.js attempted to statically prerender these pages at build time and failed because `NEXT_PUBLIC_SUPABASE_URL` is not available in the build environment
- `publish/unpublish` implemented as `<form action={serverAction.bind(null, id)}>` in RSC — avoids needing a separate client component for a simple toggle
- `ThumbnailUploader` rendered only in edit mode (when `program` prop is present) because the upload path uses `programId` which doesn't exist until after program creation

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Added export const dynamic='force-dynamic' to RSC pages with Supabase calls**
- **Found during:** Task 2 (build verification)
- **Issue:** `npm run build` failed with "supabaseUrl is required" because Next.js tried to statically prerender `/programs` at build time, but `createServiceClient()` throws when env vars are absent
- **Fix:** Added `export const dynamic = 'force-dynamic'` to `programs/page.tsx` and `programs/[id]/page.tsx` — forces server-render on demand instead of static generation
- **Files modified:** `admin/app/(admin)/programs/page.tsx`, `admin/app/(admin)/programs/[id]/page.tsx`
- **Verification:** `npm run build` passes; both routes show `ƒ (Dynamic)` in build output
- **Committed in:** `1b39d68` (Task 2 commit)

---

**Total deviations:** 1 auto-fixed (1 blocking)
**Impact on plan:** Auto-fix essential for build to pass. No scope creep — this is the correct pattern for any RSC page making authenticated Supabase calls.

## Issues Encountered
- Build-time static prerender attempted to run `createServiceClient()` without env vars — resolved with `dynamic = 'force-dynamic'` export

## User Setup Required
None - all code uses existing infrastructure from Plan 01 (service role client, program-assets bucket). No new env vars or external services introduced.

## Next Phase Readiness
- Program CRUD complete — Plan 03 (session/exercise editor) can build on `/programs/[id]` page which already shows the sessions list and links to `/programs/[id]/sessions/[sessionId]`
- ThumbnailUploader is wired end-to-end to program-assets bucket — thumbnail upload will work once bucket is deployed via migration 005_program_assets_bucket.sql
- Publish toggle correctly sets/clears `published_at` timestamp — student app can filter on `published = true`

---
*Phase: 08-us6-admin-panel*
*Completed: 2026-05-29*
