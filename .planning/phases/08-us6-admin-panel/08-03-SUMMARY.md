---
phase: 08-us6-admin-panel
plan: 03
subsystem: admin-ui, edge-functions, notifications
tags: [nextjs, supabase, fcm, edge-function, server-actions, shadcn]

# Dependency graph
requires:
  - phase: 08-01
    provides: createServiceClient, shadcn/ui components, admin shell

provides:
  - admin/app/actions/feedback.ts — postCoachReply server action
  - admin/app/(admin)/feedback/page.tsx — feedback thread list (pending/replied)
  - admin/app/(admin)/feedback/[threadId]/page.tsx — thread detail with reply form
  - admin/components/feedback-reply-form.tsx — client form with useActionState
  - supabase/functions/send-fcm/index.ts — FCM v1 push notification Edge Function

affects:
  - 08-04 (session/exercise editor — independent, no direct dependency)
  - 08-05 (polish — may reference feedback UI)

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "export const dynamic = 'force-dynamic' on RSC pages using createServiceClient() to prevent build-time prerender errors"
    - "postCoachReply.bind(null, threadId) pattern for useActionState with extra args"
    - "FCM v1 API with service account JWT: crypto.subtle RSASSA-PKCS1-v1_5 sign + OAuth2 token exchange"
    - "Non-fatal FCM: reply saved regardless of push delivery outcome"

key-files:
  created:
    - "admin/app/actions/feedback.ts"
    - "admin/app/(admin)/feedback/page.tsx"
    - "admin/app/(admin)/feedback/[threadId]/page.tsx"
    - "admin/components/feedback-reply-form.tsx"
    - "supabase/functions/send-fcm/index.ts"
  modified: []

key-decisions:
  - "export const dynamic = 'force-dynamic' on RSC pages calling createServiceClient() — Next.js 16 tries to prerender pages and throws 'supabaseUrl is required' without env vars at build time"
  - "FCM failure is non-fatal — coach_reply is committed to DB before push attempt; push failure only logged, not surfaced as error"
  - "send-fcm implements full FCM v1 flow with service account JWT using Deno's crypto.subtle (no external JWT library) for Deno edge runtime compatibility"
  - "FeedbackReplyForm is a named export (not default) to allow clean barrel imports"

requirements-completed: [FR-018]

# Metrics
duration: ~10min
completed: 2026-05-29T22:33:16Z
---

# Phase 08 Plan 03: Feedback Management Summary

**Feedback management interface + FCM v1 Edge Function: coach views pending/replied threads, posts replies via server action, and send-fcm Edge Function delivers push notifications using service account JWT auth**

## Performance

- **Duration:** ~10 min
- **Completed:** 2026-05-29T22:33:16Z
- **Tasks:** 2
- **Files created:** 5

## Accomplishments

- `postCoachReply` server action writes `coach_reply`, `replied_at` to `feedback_threads` then fires FCM push (non-fatal)
- Feedback list page groups threads into Pending (yellow badge) / Replied (green badge) sections ordered newest first
- Thread detail page shows: student name, session context breadcrumb, full message, attached photo (if any), existing reply (green card) or reply form
- `FeedbackReplyForm` client component uses `useActionState` with `postCoachReply.bind(null, threadId)`; shows success message after reply
- `send-fcm` Edge Function: fetches student's FCM token, obtains Google OAuth2 access token via RS256 JWT (service account, `crypto.subtle`), sends FCM v1 push notification, updates `notification_sent=true`
- `npm run build` passes with zero TypeScript errors; feedback routes are `force-dynamic`

## Task Commits

1. **Task 1: Feedback Server Action + send-fcm Edge Function** — `fb4beb3`
2. **Task 2: Feedback list + thread detail pages + reply form** — `bd8d86b`

## Files Created/Modified

- `admin/app/actions/feedback.ts` — `'use server'` action: validates reply (zod), updates feedback_threads, invokes send-fcm
- `admin/app/(admin)/feedback/page.tsx` — RSC list: Pending section first, then Replied; card shows student, session context, message preview
- `admin/app/(admin)/feedback/[threadId]/page.tsx` — RSC detail: full message, photo, reply card or FeedbackReplyForm
- `admin/components/feedback-reply-form.tsx` — `'use client'` with `useActionState`; textarea + submit button; success state shown inline
- `supabase/functions/send-fcm/index.ts` — Deno Edge Function: method guard, student fcm_token lookup, RS256 JWT + OAuth2 token exchange, FCM v1 messages:send, notification_sent update

## Decisions Made

- `export const dynamic = 'force-dynamic'` required on both feedback RSC pages — Next.js 16 build prerendering fails without runtime env vars; programs page is a stub so it didn't hit this yet
- FCM failure is non-fatal: the reply DB write succeeds unconditionally; push errors are logged to console but not returned as user-facing errors
- `send-fcm` uses `crypto.subtle` (no third-party JWT library) to remain compatible with the Deno edge runtime

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Added `export const dynamic = 'force-dynamic'` to RSC pages**
- **Found during:** Task 2 verification (`npm run build`)
- **Issue:** Next.js 16 attempted to prerender `/feedback` and `/feedback/[threadId]` at build time. Both call `createServiceClient()` which reads `process.env.NEXT_PUBLIC_SUPABASE_URL` — unavailable at build time, causing `Error: supabaseUrl is required`
- **Fix:** Added `export const dynamic = 'force-dynamic'` to both page files so they render on demand
- **Files modified:** `admin/app/(admin)/feedback/page.tsx`, `admin/app/(admin)/feedback/[threadId]/page.tsx`
- **Verification:** `npm run build` exits 0; both routes show as `ƒ (Dynamic)` in route table
- **Committed in:** `bd8d86b` (Task 2 commit)

**Total deviations:** 1 auto-fixed  
**Impact on plan:** Required for build to pass. No scope change. Pattern consistent with any future RSC page using createServiceClient().

## Known Stubs

None — all feedback management functionality is fully wired. The send-fcm Edge Function reads real environment variables at runtime (FIREBASE_SERVICE_ACCOUNT_JSON, FIREBASE_PROJECT_ID, SUPABASE_SERVICE_ROLE_KEY) which must be set in Supabase Vault before deployment.

## Next Phase Readiness

- Feedback CRUD fully implemented — Plan 08-04 (session/exercise editor) can proceed independently
- `send-fcm` Edge Function ready for deployment to Supabase; requires `FIREBASE_SERVICE_ACCOUNT_JSON`, `FIREBASE_PROJECT_ID` secrets in Supabase Vault

## Self-Check: PASSED

- FOUND: admin/app/actions/feedback.ts
- FOUND: supabase/functions/send-fcm/index.ts
- FOUND: admin/app/(admin)/feedback/page.tsx
- FOUND: admin/app/(admin)/feedback/[threadId]/page.tsx
- FOUND: admin/components/feedback-reply-form.tsx
- FOUND commit: fb4beb3 (Task 1)
- FOUND commit: bd8d86b (Task 2)
- FOUND commit: 3c5269c (metadata/docs)

---
*Phase: 08-us6-admin-panel*  
*Completed: 2026-05-29*
