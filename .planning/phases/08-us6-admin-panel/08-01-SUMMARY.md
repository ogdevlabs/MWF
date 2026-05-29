---
phase: 08-us6-admin-panel
plan: 01
subsystem: auth, ui, api
tags: [nextjs, supabase-ssr, shadcn, mux, tailwind, typescript]

# Dependency graph
requires:
  - phase: 07-us5-private-feedback
    provides: feedback_threads table and RLS for coach replies

provides:
  - proxy.ts auth guard redirecting unauthenticated users to /login
  - lib/supabase/server.ts cookie-based Supabase client for Server Components
  - lib/supabase/service.ts service-role client bypassing RLS for coach writes
  - app/(auth)/login page with email/password Server Action
  - app/(admin)/layout.tsx admin shell with Programs and Feedback sidebar nav
  - app/api/mux-upload POST route returning {uploadId, url} for Mux Direct Upload
  - supabase/migrations/005_program_assets_bucket.sql for thumbnails and GLB storage
  - shadcn/ui components (button, input, card, table, dialog, select, textarea, badge, separator, label)
affects:
  - 08-02 (program CRUD pages need auth + admin shell)
  - 08-03 (session/exercise editor uses VideoUploader + mux-upload route)
  - 08-04 (feedback reply pages use admin shell + service client)

# Tech tracking
tech-stack:
  added:
    - "@radix-ui/react-dialog@1.1.15"
    - "@radix-ui/react-label@2.1.8"
    - "@radix-ui/react-select@2.2.6"
    - "@radix-ui/react-separator@1.1.8"
    - "@radix-ui/react-slot@1.2.4"
    - "lucide-react"
    - "class-variance-authority"
    - "tailwind-merge"
    - "shadcn/ui components (button, input, card, table, dialog, select, textarea, badge, separator, label)"
  patterns:
    - "Next.js 16 proxy.ts (NOT middleware.ts) for auth guard with getUser() (not getSession())"
    - "createSupabaseServerClient() awaits cookies() — required in Next.js 16"
    - "getAll/setAll cookie pattern for @supabase/ssr 0.10.3"
    - "Server Action with useActionState for login form (Next.js 16 pattern)"
    - "Service role client (createServiceClient) for all coach mutations bypassing RLS"

key-files:
  created:
    - "admin/proxy.ts"
    - "admin/lib/supabase/server.ts"
    - "admin/lib/supabase/service.ts"
    - "admin/lib/utils.ts"
    - "admin/app/(auth)/login/page.tsx"
    - "admin/app/(auth)/login/actions.ts"
    - "admin/app/(admin)/layout.tsx"
    - "admin/app/(admin)/programs/page.tsx"
    - "admin/components/nav-link.tsx"
    - "admin/app/api/mux-upload/route.ts"
    - "supabase/migrations/005_program_assets_bucket.sql"
    - "admin/components/ui/{button,input,card,table,dialog,select,textarea,badge,separator,label}.tsx"
  modified:
    - "admin/app/layout.tsx (title updated)"
    - "admin/package.json (new dependencies)"

key-decisions:
  - "Next.js 16 proxy.ts (not middleware.ts): file and exported function must both be named 'proxy'"
  - "getUser() (not getSession()) in every Server Action and Route Handler for verified auth"
  - "shadcn components install required lucide-react, class-variance-authority, tailwind-merge as manual installs (shadcn CLI didn't add to package.json)"
  - "Login page uses 'use client' + useActionState — required because useActionState is a React hook"
  - "program-assets bucket uses private mode with authenticated SELECT and service_role INSERT/ALL policies"

patterns-established:
  - "Pattern 1: proxy.ts auth guard — export async function proxy with getAll/setAll cookie pattern and getUser() verification"
  - "Pattern 2: createSupabaseServerClient() — always await cookies() first (Next.js 16 requirement)"
  - "Pattern 3: createServiceClient() — synchronous, no cookies, uses SUPABASE_SERVICE_ROLE_KEY"
  - "Pattern 4: useActionState(serverAction, undefined) for form submissions with error state"

requirements-completed: [FR-015, FR-016]

# Metrics
duration: 4min
completed: 2026-05-29
---

# Phase 08 Plan 01: Admin Panel Foundation Summary

**Next.js 16 admin panel foundation: proxy.ts auth guard, Supabase SSR clients, email/password login, shadcn/ui components, admin shell with sidebar nav, Mux Direct Upload route, and program-assets storage bucket migration**

## Performance

- **Duration:** ~4 min
- **Started:** 2026-05-29T18:54:33Z
- **Completed:** 2026-05-29T18:58:15Z
- **Tasks:** 2
- **Files modified:** 24

## Accomplishments
- Auth guard (proxy.ts) redirects unauthenticated users to /login using verified getUser() check
- Login page with email/password Server Action (signInWithPassword) using useActionState pattern
- Admin shell layout with sidebar nav linking to Programs and Feedback with active highlight
- Mux Direct Upload Route Handler creating signed upload URLs for authenticated coach only
- program-assets Supabase Storage bucket migration with service_role write + authenticated read policies
- shadcn/ui component set installed: button, input, card, table, dialog, select, textarea, badge, separator, label
- `npm run build` passes with zero TypeScript errors

## Task Commits

Each task was committed atomically:

1. **Task 1: Auth infrastructure + login page + admin shell + shadcn install** - `9513753` (feat)
2. **Task 2: Mux upload Route Handler + program-assets bucket migration** - `c0bc30c` (feat)

**Plan metadata:** (docs commit follows)

## Files Created/Modified
- `admin/proxy.ts` - Auth guard with getUser() redirecting unauthenticated to /login
- `admin/lib/supabase/server.ts` - createSupabaseServerClient() with getAll/setAll cookies
- `admin/lib/supabase/service.ts` - createServiceClient() with SUPABASE_SERVICE_ROLE_KEY
- `admin/lib/utils.ts` - cn() helper using clsx + tailwind-merge
- `admin/app/(auth)/login/page.tsx` - Login form using useActionState + shadcn Card/Input/Label/Button
- `admin/app/(auth)/login/actions.ts` - 'use server' login action calling signInWithPassword
- `admin/app/(admin)/layout.tsx` - Admin shell with w-64 sidebar and Programs/Feedback NavLinks
- `admin/app/(admin)/programs/page.tsx` - Placeholder Programs RSC (fleshed out in Plan 02)
- `admin/components/nav-link.tsx` - Client component with usePathname for active link highlight
- `admin/app/api/mux-upload/route.ts` - POST handler verifying auth then calling mux.video.uploads.create()
- `supabase/migrations/005_program_assets_bucket.sql` - program-assets bucket + RLS policies
- `admin/components/ui/*.tsx` - shadcn components (10 files)
- `admin/app/layout.tsx` - Updated metadata title to "Move With Fergie Admin"
- `admin/package.json` - Added radix-ui peers, lucide-react, class-variance-authority, tailwind-merge

## Decisions Made
- Next.js 16 renames `middleware.ts` to `proxy.ts` and requires the exported function be named `proxy` — confirmed from `node_modules/next/dist/docs/01-app/03-api-reference/03-file-conventions/proxy.md`
- Login page must be `'use client'` because `useActionState` is a React hook (cannot be used in RSC)
- shadcn CLI installed components but did not add `class-variance-authority`, `tailwind-merge`, and `lucide-react` to package.json — added these manually
- `program-assets` bucket is private (not public) — thumbnails are served via authenticated read, not public CDN URLs

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Installed missing lucide-react, class-variance-authority, tailwind-merge**
- **Found during:** Task 1 (shadcn component install)
- **Issue:** `npm run build` failed with "Cannot find module 'lucide-react'" because shadcn CLI installed radix-ui peers but not lucide-react, class-variance-authority, or tailwind-merge
- **Fix:** Ran `npm install lucide-react class-variance-authority tailwind-merge`; created `lib/utils.ts` manually since shadcn didn't create it
- **Files modified:** admin/package.json, admin/package-lock.json, admin/lib/utils.ts
- **Verification:** `npm run build` passes after install
- **Committed in:** 9513753 (Task 1 commit)

**2. [Rule 2 - Missing Critical] Login page made 'use client' for useActionState hook**
- **Found during:** Task 1 (login page creation)
- **Issue:** Plan called for a Server Component login page but `useActionState` (used by Next.js 16 Server Action pattern) is a React hook that requires 'use client'
- **Fix:** Added `'use client'` directive to login page — the Server Action in actions.ts remains server-only
- **Files modified:** admin/app/(auth)/login/page.tsx
- **Verification:** `npm run build` passes with no "hooks in RSC" error
- **Committed in:** 9513753 (Task 1 commit)

---

**Total deviations:** 2 auto-fixed (1 blocking dependency, 1 missing critical)
**Impact on plan:** Both auto-fixes necessary for build to pass and for correct Next.js 16 Server Action pattern. No scope creep.

## Issues Encountered
- shadcn CLI did not create `lib/utils.ts` automatically — created manually with standard clsx + tailwind-merge cn() helper

## User Setup Required
None - no external service configuration required for this plan. The Mux credentials (MUX_TOKEN_ID, MUX_TOKEN_SECRET) and Supabase service role key (SUPABASE_SERVICE_ROLE_KEY) must exist in `.env.local` for the upload route to function at runtime, but no new credentials were introduced.

## Next Phase Readiness
- Auth guard, Supabase clients, login page, and admin shell are all in place — Plan 02 (program CRUD) can proceed immediately
- Mux Direct Upload endpoint ready to be consumed by VideoUploader client component in Plan 03
- program-assets bucket migration ready to deploy to Supabase before thumbnail/GLB uploads are used
- shadcn component library installed — all Plans 02-05 can use components without additional installs

---
*Phase: 08-us6-admin-panel*
*Completed: 2026-05-29*
