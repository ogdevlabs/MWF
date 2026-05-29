---
phase: 08-us6-admin-panel
plan: 04
subsystem: ui, api
tags: [nextjs, supabase, mux, server-actions, zod, typescript, video-upload, shadcn]

# Dependency graph
requires:
  - phase: 08-us6-admin-panel/08-01
    provides: createServiceClient() service role client, admin shell layout, shadcn components, /api/mux-upload Route Handler
  - phase: 08-us6-admin-panel/08-02
    provides: programs CRUD, program-assets bucket, patterns for RSC pages with force-dynamic + Server Action binding

provides:
  - admin/app/actions/sessions.ts — createSession, updateSession, deleteSession server actions
  - admin/app/actions/exercises.ts — createExercise, updateExercise, deleteExercise, updateExerciseVideo (FR-019), uploadAsset server actions
  - sessions/new page for adding sessions to a program
  - sessions/[sessionId] page with edit form, exercises table with video status badges, Add Exercise link
  - exercises/new page with ExerciseForm (no upload widgets until exercise exists)
  - exercises/[exerciseId] page with ExerciseForm + VideoUploader + GlbUploader
  - VideoUploader client component wrapping @mux/mux-uploader-react
  - GlbUploader client component uploading .glb/.gltf to program-assets bucket
  - ExerciseForm client component with rep/time toggle, useActionState
  - SessionForm client component for create/edit sessions
  - supabase/functions/mux-webhook/index.ts — handles video.asset.ready, updates mux_playback_id + mux_download_url

affects:
  - mobile app (exercises now have video_version increment for cache invalidation, FR-019)
  - student offline sync (mux_download_url set by webhook, consumed by DownloadManifest)

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "SessionForm/ExerciseForm client components wrap useActionState — same pattern as ProgramForm in Plan 02"
    - "Server Action binding: createSession.bind(null, programId) for currying extra args into useActionState-compatible actions"
    - "VideoUploader fetches /api/mux-upload POST to get signed URL, then passes it as MuxUploader endpoint prop"
    - "GlbUploader calls uploadAsset server action directly (not via fetch) — server action can accept FormData"
    - "updateExerciseVideo fetches current video_version before incrementing — prevents race if field starts null"
    - "Webhook finds exercise via mux_asset_id=upload_id (not asset_id) — upload_id is what the admin sets, asset_id only known after processing"

key-files:
  created:
    - "admin/app/actions/sessions.ts"
    - "admin/app/actions/exercises.ts"
    - "admin/app/(admin)/programs/[id]/sessions/new/page.tsx"
    - "admin/app/(admin)/programs/[id]/sessions/[sessionId]/page.tsx"
    - "admin/app/(admin)/programs/[id]/sessions/[sessionId]/exercises/new/page.tsx"
    - "admin/app/(admin)/programs/[id]/sessions/[sessionId]/exercises/[exerciseId]/page.tsx"
    - "admin/components/video-uploader.tsx"
    - "admin/components/glb-uploader.tsx"
    - "admin/components/exercise-form.tsx"
    - "admin/components/session-form.tsx"
  modified:
    - "supabase/functions/mux-webhook/index.ts"

key-decisions:
  - "Mux webhook uses upload_id (not asset_id) to look up exercise — upload_id is what updateExerciseVideo stores in mux_asset_id; asset_id is only available after Mux processing"
  - "VideoUploader shown only in edit mode (exercise must exist) — exercise id required for updateExerciseVideo call"
  - "GlbUploader calls uploadAsset server action directly via FormData — avoids extra fetch round-trip"
  - "ExerciseForm uses radio toggle for rep-based vs time-based — empty string inputs converted to undefined before Zod parse to allow nullable optional coerce"

patterns-established:
  - "Pattern 7: Upload-only-in-edit: components that upload to storage require an existing record ID — render only when record exists"
  - "Pattern 8: Nullable coerce — strip empty string form fields to undefined before Zod parse when field is optional/nullable coerce number"

requirements-completed: [FR-016, FR-019]

# Metrics
duration: 3min
completed: 2026-05-29
---

# Phase 08 Plan 04: Sessions/Exercises + Video/GLB Upload Summary

**Full content creation pipeline: session/exercise CRUD with Mux Direct Upload video, GLB 3D asset upload to Supabase Storage, and webhook-driven playback ID population with video_version cache invalidation (FR-016, FR-019)**

## Performance

- **Duration:** ~3 min
- **Started:** 2026-05-29T22:39:22Z
- **Completed:** 2026-05-29T22:42:45Z
- **Tasks:** 2
- **Files modified:** 11

## Accomplishments
- Session server actions (createSession/updateSession/deleteSession) with Zod validation, redirect-on-create pattern
- Exercise server actions: createExercise/updateExercise/deleteExercise with rep-vs-time mutual exclusion; updateExerciseVideo increments video_version (FR-019) and clears mux_playback_id to signal processing state; uploadAsset handles .glb and thumbnail to program-assets bucket
- VideoUploader client component: fetches /api/mux-upload for signed URL, renders MuxUploader from @mux/mux-uploader-react with onSuccess callback
- GlbUploader client component: file input restricted to .glb/.gltf, calls uploadAsset server action, shows upload status
- ExerciseForm with rep/time radio toggle, VideoUploader + GlbUploader shown only in edit mode
- Session and exercise pages at all expected routes (new/edit); session detail page has exercises table with video status badges (Ready/Processing/No video) and Add Exercise link
- Mux webhook: handles video.asset.ready, finds exercise via upload_id stored in mux_asset_id, updates mux_playback_id and mux_download_url; MUX_WEBHOOK_SIGNING_SECRET wired for production hardening
- `npm run build` passes with zero errors; all 8 new routes show as Dynamic (ƒ)

## Task Commits

Each task was committed atomically:

1. **Task 1: Session and Exercise Server Actions** - `fc86abe` (feat)
2. **Task 2: Session/Exercise pages + Video/GLB uploaders + Mux webhook** - `92ccbcf` (feat)

**Plan metadata:** (docs commit follows)

## Files Created/Modified
- `admin/app/actions/sessions.ts` - createSession / updateSession / deleteSession with Zod SessionSchema
- `admin/app/actions/exercises.ts` - createExercise / updateExercise / deleteExercise / updateExerciseVideo (video_version++) / uploadAsset / deleteExercise
- `admin/app/(admin)/programs/[id]/sessions/new/page.tsx` - RSC; renders SessionForm with createSession.bind(null, programId)
- `admin/app/(admin)/programs/[id]/sessions/[sessionId]/page.tsx` - RSC; edit session form, exercises table with video badges, Add Exercise link, Delete Session button
- `admin/app/(admin)/programs/[id]/sessions/[sessionId]/exercises/new/page.tsx` - RSC; ExerciseForm with createExercise.bind(null, sessionId, programId); no upload widgets
- `admin/app/(admin)/programs/[id]/sessions/[sessionId]/exercises/[exerciseId]/page.tsx` - RSC; edit exercise form with VideoUploader + GlbUploader; Delete Exercise button
- `admin/components/video-uploader.tsx` - 'use client'; MuxUploader wrapper; idle/ready/uploading/complete state machine
- `admin/components/glb-uploader.tsx` - 'use client'; hidden file input, calls uploadAsset server action
- `admin/components/exercise-form.tsx` - 'use client'; rep/time toggle, VideoUploader + GlbUploader in edit mode
- `admin/components/session-form.tsx` - 'use client'; day_number + title + description with useActionState
- `supabase/functions/mux-webhook/index.ts` - handles video.asset.ready; upload_id lookup; updates mux_playback_id + mux_download_url

## Decisions Made
- Mux webhook uses `upload_id` (stored in `mux_asset_id`) to locate the exercise, not Mux's `asset_id` — the admin panel writes `upload_id` at upload time; `asset_id` is only known after Mux finishes processing
- VideoUploader and GlbUploader rendered only when editing an existing exercise (not on create page) — exercise ID is required for `updateExerciseVideo` and `uploadAsset` path construction
- Empty string coercion: FormData values for optional numeric fields (rep_count, duration_seconds) are set to `undefined` before Zod parse to allow nullable coerce to work correctly

## Deviations from Plan

None — plan executed exactly as written.

## Issues Encountered
None

## User Setup Required
None — uses existing infrastructure (service role client, program-assets bucket, /api/mux-upload). The `MUX_WEBHOOK_SIGNING_SECRET` env var must be set in Supabase Function secrets for production webhook signature verification.

## Next Phase Readiness
- Full content creation pipeline is complete: coach can create programs → add sessions → add exercises → upload video + GLB 3D assets
- Mux webhook correctly populates `mux_playback_id` when video processing completes — student app can start HLS playback
- `video_version` incremented on video replace — student offline cache invalidation (FR-019) is wired end-to-end
- Admin panel Phase 8 feature work is complete; remaining work is integration testing and deployment

---
*Phase: 08-us6-admin-panel*
*Completed: 2026-05-29*
