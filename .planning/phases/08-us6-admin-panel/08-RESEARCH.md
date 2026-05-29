# Phase 8: US6 Admin Panel — Research

**Researched:** 2026-05-29
**Domain:** Next.js 16 App Router, Mux Direct Upload, Supabase SSR auth, shadcn/ui, FCM server-side push, Supabase Edge Functions
**Confidence:** HIGH

---

## Project Constraints (from CLAUDE.md)

No CONTEXT.md exists for this phase. Constraints come from CLAUDE.md and spec/data-model decisions locked in earlier phases.

### Locked Decisions
- Never push directly to `main`. Always branch + PR.
- Single coach (not multi-tenant). Auth complexity is Supabase login only.
- Video hosting via Mux ONLY — never Supabase Storage for video.
- 3D assets (GLB files) and thumbnails stored in Supabase Storage.
- CQRS: all writes go to normalized tables; reads from projection views.
- Coach writes use the Supabase **service role key** (bypasses RLS).
- Push notification triggered server-side (Supabase Edge Function) when coach writes `coach_reply` to `feedback_threads`.
- This is Next.js **16.2.6** — `middleware.ts` is deprecated and renamed to `proxy.ts`. Read node_modules/next/dist/docs/ before writing any code. Do NOT assume Next.js 15 or earlier conventions.

### Deferred Ideas (OUT OF SCOPE)
- Multi-tenant marketplace
- Community/public comments or cross-student visibility
- Direct payment processing

---

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| FR-015 | Coach MUST be able to create, edit, and delete programs with metadata (title, description, difficulty, thumbnail, duration) | Supabase service-role writes to `programs` table; `revalidatePath` after mutation; cascade delete already in schema |
| FR-016 | Coach MUST be able to add sessions to programs with ordered exercises, each having a video upload, 3D asset upload, rep/time config, and text cues | Mux Direct Upload flow (Route Handler creates upload URL, `MuxUploader` React component uploads from browser); Supabase Storage for GLB; `exercises` table already has all needed columns |
| FR-017 | Coach MUST be able to publish/unpublish programs; published programs appear in the student app within 60s | Toggle `programs.published` + `published_at`; CQRS views are regular views (not materialized) so change is instant; 60s well within reach |
| FR-018 | Coach MUST be able to view individual student feedback submissions and post private replies; each thread is scoped to a single student | `feedback_threads` read with service role key; `coach_reply` + `replied_at` + `notification_sent` update; FCM trigger via Supabase Edge Function |
| FR-019 | System MUST invalidate cached video assets on student devices when a video is updated by the coach | Increment `exercises.video_version` on video replace; mobile `download_manifest` uses version to detect stale; Mux webhook already stubbed for asset-ready updates |
</phase_requirements>

---

## Summary

Phase 8 builds a fully working admin panel on top of the existing Next.js 16 scaffold. The app at `admin/` has Next.js 16.2.6, Tailwind 4, shadcn/ui (configured but no components added yet), `@mux/mux-node@14.1.0`, `@mux/mux-uploader-react@1.5.0`, `@supabase/ssr@0.10.3`, `@supabase/supabase-js@2.106.2`, `react-hook-form@7.76.1`, and `zod@4.4.3`. The `admin/lib/cqrs/query-client.ts` already exists with service-role Supabase reads. There are no pages yet — only a placeholder `app/page.tsx`.

**Critical breaking change:** This version of Next.js has renamed `middleware.ts` to `proxy.ts` (v16.0.0 change). The exported function must be named `proxy`, not `middleware`. All session-guarded routes use `proxy.ts`. Never use `middleware.ts`.

**Primary recommendation:** Build the admin as a server-first Next.js 16 App Router app. Pages are React Server Components (RSC) that fetch via the existing `query-client.ts`. Mutations use Server Actions with `'use server'` directive. Auth is Supabase SSR (`createServerClient` with `getAll`/`setAll` cookie methods) in `proxy.ts`. The MuxUploader flow requires a Route Handler (`app/api/mux-upload/route.ts`) to vend a signed upload URL — the browser component cannot call `@mux/mux-node` directly. FCM push notifications are sent via a **new Supabase Edge Function** (`supabase/functions/send-fcm/`) triggered by the admin Server Action after writing `coach_reply`, not via `firebase-admin` in Next.js (firebase-admin is not installed and would add unnecessary complexity when a lightweight fetch to the FCM v1 REST API from an Edge Function is simpler and consistent with existing patterns).

---

## Standard Stack

### Core (already installed)
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| next | 16.2.6 | App framework | Already installed; App Router + RSC + Server Actions |
| react | 19.2.4 | UI | Already installed |
| @supabase/ssr | 0.10.3 | Cookie-based auth for SSR | Required for Supabase auth in Next.js; replaces deprecated `auth-helpers-nextjs` |
| @supabase/supabase-js | 2.106.2 | DB reads/writes | Already used in `query-client.ts` |
| @mux/mux-node | 14.1.0 | Create Direct Upload URL server-side | Cannot call Mux API from browser; Route Handler pattern |
| @mux/mux-uploader-react | 1.5.0 | Browser-side resumable upload component | Mux-maintained component; handles resumable, progress, error states |
| react-hook-form | 7.76.1 | Form state management | Already installed; works well with Server Actions via `handleSubmit` |
| zod | 4.4.3 | Schema validation | Already installed; validate FormData in Server Actions |
| tailwindcss | 4.x | Styling | Already configured |

### Supporting (need to install)
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| shadcn/ui components | via CLI | Button, Input, Card, Table, Dialog, Select, Textarea, Badge, Separator | Install individual components via `npx shadcn@latest add <component>`; components.json already configured |
| lucide-react | (peer of shadcn) | Icons | Bundled with shadcn; icon library already set to `lucide` in components.json |

**Note:** `firebase-admin` must NOT be installed in the Next.js admin. FCM delivery is handled by a new Supabase Edge Function using the FCM v1 HTTP API with a service account key stored in Supabase Vault secrets. This is consistent with the existing Deno edge function pattern.

### Verified package versions
```bash
# Already in node_modules — no install needed:
# next@16.2.6, @mux/mux-node@14.1.0, @mux/mux-uploader-react@1.5.0
# @supabase/ssr@0.10.3, @supabase/supabase-js@2.106.2
# react-hook-form@7.76.1, zod@4.4.3

# Install shadcn components (each command adds to components/ui/):
npx shadcn@latest add button input card table dialog select textarea badge separator
```

---

## Architecture Patterns

### Recommended Project Structure
```
admin/
├── proxy.ts                      # Auth guard (NOT middleware.ts — renamed in Next.js 16)
├── app/
│   ├── (auth)/
│   │   └── login/page.tsx         # Supabase email/password login form
│   ├── (admin)/
│   │   ├── layout.tsx             # Admin shell with sidebar nav
│   │   ├── programs/
│   │   │   ├── page.tsx           # Program list (RSC)
│   │   │   ├── new/page.tsx       # Create program form
│   │   │   └── [id]/
│   │   │       ├── page.tsx       # Program detail / edit
│   │   │       └── sessions/
│   │   │           ├── new/page.tsx
│   │   │           └── [sessionId]/
│   │   │               ├── page.tsx        # Session detail
│   │   │               └── exercises/
│   │   │                   └── [exerciseId]/page.tsx
│   │   └── feedback/
│   │       ├── page.tsx           # All feedback threads list
│   │       └── [threadId]/page.tsx  # Individual thread + reply form
│   ├── api/
│   │   └── mux-upload/route.ts    # POST: creates Mux direct upload, returns {uploadId, url}
│   └── actions/
│       ├── programs.ts            # 'use server' — CRUD programs/sessions/exercises
│       └── feedback.ts            # 'use server' — post coach_reply + trigger FCM
├── components/
│   ├── ui/                        # shadcn/ui components (added via CLI)
│   ├── video-uploader.tsx         # 'use client' — wraps MuxUploader
│   ├── glb-uploader.tsx           # 'use client' — Supabase Storage upload for GLB
│   └── feedback-reply-form.tsx    # 'use client' — reply textarea + submit
├── lib/
│   ├── supabase/
│   │   ├── server.ts              # createServerClient factory (cookies)
│   │   └── service.ts             # createClient with SERVICE_ROLE_KEY (no cookies)
│   └── cqrs/
│       └── query-client.ts        # Already exists — service role reads
└── supabase/
    └── functions/
        └── send-fcm/
            └── index.ts           # New edge function: receives threadId, reads fcm_token, sends FCM
```

### Pattern 1: Auth Guard via proxy.ts (Next.js 16)

The file is `proxy.ts` at the project root (NOT `middleware.ts`). The exported function must be named `proxy`.

```typescript
// admin/proxy.ts
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'
import { createServerClient } from '@supabase/ssr'

export async function proxy(request: NextRequest) {
  let supabaseResponse = NextResponse.next({ request })

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY!,
    {
      cookies: {
        getAll() {
          return request.cookies.getAll()
        },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value }) =>
            request.cookies.set(name, value)
          )
          supabaseResponse = NextResponse.next({ request })
          cookiesToSet.forEach(({ name, value, options }) =>
            supabaseResponse.cookies.set(name, value, options)
          )
        },
      },
    }
  )

  // IMPORTANT: use getUser(), not getSession() — getSession() is unverified
  const { data: { user } } = await supabase.auth.getUser()

  if (!user && !request.nextUrl.pathname.startsWith('/login')) {
    return NextResponse.redirect(new URL('/login', request.url))
  }

  return supabaseResponse
}

export const config = {
  matcher: ['/((?!_next/static|_next/image|favicon.ico).*)'],
}
```

**Critical:** Use `getAll`/`setAll` cookie methods (not the deprecated `get`/`set`/`remove`). Use `getUser()` (verified), not `getSession()` (unverified from cookie). Source: `@supabase/ssr` README — verified in node_modules.

### Pattern 2: Supabase Server Client (for Server Actions and Route Handlers)

```typescript
// admin/lib/supabase/server.ts
import { createServerClient } from '@supabase/ssr'
import { cookies } from 'next/headers'

export async function createSupabaseServerClient() {
  const cookieStore = await cookies()

  return createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY!,
    {
      cookies: {
        getAll() {
          return cookieStore.getAll()
        },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value, options }) =>
            cookieStore.set(name, value, options)
          )
        },
      },
    }
  )
}
```

For coach writes (bypassing RLS), use the existing `admin/lib/cqrs/query-client.ts` pattern which already uses `SUPABASE_SERVICE_ROLE_KEY`.

### Pattern 3: Mux Direct Upload (Route Handler + Client Component)

The flow has two parts: (1) a Route Handler that creates a signed upload URL server-side using `@mux/mux-node`; (2) a Client Component using `MuxUploader` that uploads to that URL.

```typescript
// admin/app/api/mux-upload/route.ts
import Mux from '@mux/mux-node'
import { createSupabaseServerClient } from '@/lib/supabase/server'

const mux = new Mux({
  tokenId: process.env.MUX_TOKEN_ID!,
  tokenSecret: process.env.MUX_TOKEN_SECRET!,
})

export async function POST(request: Request) {
  // Verify auth
  const supabase = await createSupabaseServerClient()
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) return new Response('Unauthorized', { status: 401 })

  const upload = await mux.video.uploads.create({
    cors_origin: process.env.NEXT_PUBLIC_APP_URL ?? '*',
    new_asset_settings: {
      playback_policies: ['public'],
    },
  })

  // Return the upload ID (to store in DB) and the signed upload URL
  return Response.json({ uploadId: upload.id, url: upload.url })
}
```

```tsx
// admin/components/video-uploader.tsx
'use client'
import MuxUploader from '@mux/mux-uploader-react'
import { useState } from 'react'

interface VideoUploaderProps {
  onUploadComplete: (uploadId: string) => void
}

export function VideoUploader({ onUploadComplete }: VideoUploaderProps) {
  const [uploadUrl, setUploadUrl] = useState<string | null>(null)
  const [uploadId, setUploadId] = useState<string | null>(null)

  async function initUpload() {
    const res = await fetch('/api/mux-upload', { method: 'POST' })
    const { uploadId, url } = await res.json()
    setUploadId(uploadId)
    setUploadUrl(url)
  }

  return (
    <div>
      {!uploadUrl && (
        <button onClick={initUpload}>Select Video</button>
      )}
      {uploadUrl && (
        <MuxUploader
          endpoint={uploadUrl}
          onSuccess={() => uploadId && onUploadComplete(uploadId)}
        />
      )}
    </div>
  )
}
```

**Key insight:** `MuxUploader` `endpoint` prop accepts the signed URL directly. The Mux webhook (already stubbed in `supabase/functions/mux-webhook/index.ts`) will be completed in this phase to write `mux_playback_id` and `mux_asset_id` back to the `exercises` table when Mux finishes processing.

### Pattern 4: Server Action for Content Writes

```typescript
// admin/app/actions/programs.ts
'use server'
import { createClient } from '@supabase/supabase-js'
import { revalidatePath } from 'next/cache'
import { redirect } from 'next/navigation'
import { z } from 'zod'

// Service role client — bypasses RLS
const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
)

const ProgramSchema = z.object({
  title: z.string().min(1),
  description: z.string().optional(),
  difficulty: z.enum(['beginner', 'intermediate', 'advanced']),
  duration_weeks: z.coerce.number().int().positive(),
})

export async function createProgram(formData: FormData) {
  const validated = ProgramSchema.parse(Object.fromEntries(formData))
  const { data, error } = await supabase
    .from('programs')
    .insert(validated)
    .select('id')
    .single()
  if (error) throw error
  revalidatePath('/programs')
  redirect(`/programs/${data.id}`)
}

export async function publishProgram(programId: string) {
  const { error } = await supabase
    .from('programs')
    .update({ published: true, published_at: new Date().toISOString() })
    .eq('id', programId)
  if (error) throw error
  revalidatePath('/programs')
  revalidatePath(`/programs/${programId}`)
}

export async function deleteProgram(programId: string) {
  // Cascade delete: sessions -> exercises -> progress_records -> enrollments
  // All ON DELETE CASCADE is already in the schema — a single delete suffices.
  const { error } = await supabase
    .from('programs')
    .delete()
    .eq('id', programId)
  if (error) throw error
  revalidatePath('/programs')
  redirect('/programs')
}
```

**Note on `refresh()` vs `revalidatePath()`:** The Next.js 16 docs show `refresh()` from `next/cache` for router refresh. However `revalidatePath()` is still the standard for cache invalidation after mutations. Use `revalidatePath` for data; `refresh()` if you need a full router rerender without cache invalidation.

### Pattern 5: FCM Push via Supabase Edge Function

When the coach posts a `coach_reply`, the Server Action calls the Supabase Edge Function synchronously via `fetch`. The Edge Function reads the student's `fcm_token` from the `students` table and POSTs to the FCM v1 HTTP API.

```typescript
// admin/app/actions/feedback.ts
'use server'
import { createClient } from '@supabase/supabase-js'
import { revalidatePath } from 'next/cache'

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
)

export async function postCoachReply(threadId: string, replyText: string) {
  const { data: thread, error } = await supabase
    .from('feedback_threads')
    .update({
      coach_reply: replyText,
      replied_at: new Date().toISOString(),
      notification_sent: false,
    })
    .eq('id', threadId)
    .select('student_id')
    .single()
  if (error) throw error

  // Trigger FCM push via Edge Function (fire-and-forget is acceptable; 
  // notification_sent=false ensures the mobile client can poll on next sync)
  await fetch(
    `${process.env.NEXT_PUBLIC_SUPABASE_URL}/functions/v1/send-fcm`,
    {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${process.env.SUPABASE_SERVICE_ROLE_KEY}`,
      },
      body: JSON.stringify({ threadId, studentId: thread.student_id }),
    }
  )

  revalidatePath('/feedback')
  revalidatePath(`/feedback/${threadId}`)
}
```

```typescript
// supabase/functions/send-fcm/index.ts
import "@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

Deno.serve(async (req) => {
  if (req.method !== 'POST') return new Response('Method not allowed', { status: 405 })

  const { threadId, studentId } = await req.json()

  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  )

  const { data: student } = await supabase
    .from('students')
    .select('fcm_token')
    .eq('id', studentId)
    .single()

  if (!student?.fcm_token) {
    return Response.json({ sent: false, reason: 'no_token' })
  }

  // FCM v1 HTTP API — uses a service account key stored in Supabase Vault
  const fcmProjectId = Deno.env.get('FIREBASE_PROJECT_ID')!
  const fcmResponse = await fetch(
    `https://fcm.googleapis.com/v1/projects/${fcmProjectId}/messages:send`,
    {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${await getFcmAccessToken()}`,
      },
      body: JSON.stringify({
        message: {
          token: student.fcm_token,
          notification: {
            title: 'Coach replied',
            body: 'Your coach has replied to your feedback.',
          },
          data: {
            type: 'coach_reply',
            threadId,
          },
        },
      }),
    }
  )

  // Mark notification sent
  if (fcmResponse.ok) {
    await supabase
      .from('feedback_threads')
      .update({ notification_sent: true })
      .eq('id', threadId)
  }

  return Response.json({ sent: fcmResponse.ok, status: fcmResponse.status })
})
```

**Note on `getFcmAccessToken()`:** FCM v1 requires a Google OAuth2 access token. The simplest server-side pattern in Deno is to use a Google service account JWT to exchange for a short-lived access token. Store the service account JSON in Supabase Vault as `FIREBASE_SERVICE_ACCOUNT_JSON`. The access token fetch is ~15 lines using the `crypto` Deno global. This is a LOW-complexity implementation detail the planner should include as a single task.

### Pattern 6: Supabase Storage Upload for GLB and Thumbnails

New migration needed for `program-assets` bucket (thumbnails and GLB files). Upload via `@supabase/supabase-js` service role client in Server Action.

```typescript
// In a Server Action (for GLB and thumbnail uploads)
export async function uploadAsset(formData: FormData) {
  const file = formData.get('file') as File
  const type = formData.get('type') as 'thumbnail' | 'glb'
  const programId = formData.get('programId') as string

  const supabase = createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY!
  )

  const path = `${type}/${programId}/${file.name}`
  const { error } = await supabase.storage
    .from('program-assets')
    .upload(path, file, { upsert: true })

  if (error) throw error
  return path  // store this in programs.thumbnail_url or exercises.model_asset_url
}
```

### Anti-Patterns to Avoid
- **Using `middleware.ts` instead of `proxy.ts`:** Next.js 16 deprecated `middleware`. Always use `proxy.ts` with exported function named `proxy`.
- **Using `getSession()` for auth decisions:** `getSession()` returns unverified cookie data. Use `getUser()` in every Server Action and Route Handler.
- **Calling Mux API from a Client Component:** `@mux/mux-node` requires server credentials. Always create upload URLs via a Route Handler, then pass the URL to `MuxUploader`.
- **Using materialized views:** Existing CQRS views are regular views (`security_invoker=true`). Materializing them breaks RLS. Do not change this.
- **Installing `firebase-admin` in Next.js:** Adds ~20MB to cold start, requires credential management in Next.js env. Use the Deno Edge Function + FCM v1 REST API pattern already established in this project.
- **Forgetting `revalidatePath` after mutations:** Server Actions mutate Supabase data but Next.js caches RSC output. Always call `revalidatePath` for the affected path(s).
- **Incorrect cascade assumption:** `progress_records` has `session_id FK ON DELETE CASCADE`. Sessions cascade from programs. A program delete cascades: programs -> sessions -> exercises AND programs -> sessions -> progress_records. Enrollments also cascade from programs. This is all already wired — no extra migration needed.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Resumable video upload | Custom chunked upload | `@mux/mux-uploader-react` | Handles retry, progress, resume, error states; already installed |
| Form validation | Manual FormData checks | `zod` schemas in Server Actions | Type-safe; already installed |
| Auth-protected routes | Custom session check | `proxy.ts` + `@supabase/ssr` `createServerClient` | Handles token refresh, cookie sync; critical edge cases documented in README |
| Supabase cookie auth | Custom JWT storage | `@supabase/ssr` `getAll`/`setAll` pattern | Deprecated `get`/`set`/`remove` misses concurrent refresh edge cases |
| FCM token lifecycle | Custom Firebase SDK | FCM v1 HTTP API (Deno fetch) | No firebase-admin needed; consistent with existing Edge Function pattern |
| GLB/thumbnail upload | Custom multipart | `supabase-js` `storage.from().upload()` | Authenticated, handles CORS, returns path |
| Program delete cascade | Manual deletes of sessions/exercises | Single `DELETE FROM programs WHERE id=X` | `ON DELETE CASCADE` already in schema; one delete is sufficient |

**Key insight:** Everything needed for this phase is either already installed or achievable with what exists. The one missing piece is `shadcn/ui` components (installed via CLI) and the new `send-fcm` Edge Function.

---

## Common Pitfalls

### Pitfall 1: Using `middleware.ts` in Next.js 16
**What goes wrong:** File named `middleware.ts` is silently ignored or throws. All routes are unprotected.
**Why it happens:** Next.js 16 (v16.0.0) renamed `middleware` to `proxy`. Training data knows only `middleware.ts`.
**How to avoid:** File must be `proxy.ts` at project root. Exported function must be named `proxy` (or default export named `proxy`). Confirmed via `node_modules/next/dist/docs/01-app/03-api-reference/03-file-conventions/proxy.md`.
**Warning signs:** No auth redirect happening when visiting `/programs` without login.

### Pitfall 2: `getSession()` vs `getUser()` for Authorization
**What goes wrong:** `getSession()` returns data from the cookie without network verification. A malicious client could forge a session cookie.
**Why it happens:** `getSession()` looks like the right call; `getUser()` sounds like it fetches extra data.
**How to avoid:** Use `getUser()` in every Server Action and Route Handler. Use `getSession()` only when you need the tokens themselves (e.g., to extract claims for display), never for access control. Source: `@supabase/ssr` README — verified in node_modules.
**Warning signs:** Linting or security review flags `getSession()` in auth checks.

### Pitfall 3: Mux Webhook Updates mux_playback_id, Not the Upload Flow
**What goes wrong:** Exercise is created with `mux_asset_id` (upload ID) but `mux_playback_id` is null — video never plays.
**Why it happens:** `mux.video.uploads.create()` returns an `uploadId` (the upload object ID), not the asset ID. The asset is created asynchronously after upload completes. `mux_playback_id` is only available after the `video.asset.ready` Mux webhook fires.
**How to avoid:** Store `mux_asset_id` in `exercises` immediately after the coach submits. Complete the `mux-webhook` Edge Function stub (already in `supabase/functions/mux-webhook/index.ts`) to update `exercises.mux_playback_id` and `mux_download_url` when Mux fires `video.asset.ready`. The mobile app already checks `video_ready = mux_playback_id IS NOT NULL`.
**Warning signs:** `session_playback_view.video_ready` is false even after upload.

### Pitfall 4: Mux Webhook Signature Validation
**What goes wrong:** Anyone can POST fake events to the Mux webhook endpoint.
**Why it happens:** The stub was left without signature validation (`TODO Phase 8` comment is in the code).
**How to avoid:** Validate the `Mux-Signature` header using `MUX_WEBHOOK_SIGNING_SECRET`. The `@mux/mux-node` SDK provides `mux.webhooks.verifySignature(body, headers, secret)`. Set `MUX_WEBHOOK_SIGNING_SECRET` in Supabase Edge Function secrets.
**Warning signs:** Fake events update the wrong exercise data.

### Pitfall 5: Supabase Storage Bucket Missing for Program Assets
**What goes wrong:** Thumbnail and GLB uploads fail with "bucket not found".
**Why it happens:** The `program-assets` bucket was never created. Only `feedback-photos` was created in Phase 7. The initial schema has no storage bucket for program content.
**How to avoid:** Phase 8 must create a new Supabase migration for `program-assets` bucket with appropriate RLS (service role can write; authenticated students can read — or use signed URLs).
**Warning signs:** Upload throws a Supabase Storage 404 error.

### Pitfall 6: FCM Access Token for v1 API
**What goes wrong:** FCM v1 API returns 401 Unauthorized.
**Why it happens:** FCM v1 (not the deprecated legacy API) requires a Google OAuth2 access token, not just the server key. Must generate a short-lived JWT from the service account and exchange it for a bearer token.
**How to avoid:** Store the Firebase service account JSON in Supabase Vault (`FIREBASE_SERVICE_ACCOUNT_JSON`). In the `send-fcm` Edge Function, implement a Google JWT -> access token exchange using Deno's native `crypto` and `fetch`. This is ~20 lines, fully doable without firebase-admin.
**Warning signs:** FCM API returns `{"error": {"code": 401, "status": "UNAUTHENTICATED"}}`.

### Pitfall 7: video_version Must Be Incremented on Video Replace
**What goes wrong:** Student app does not re-download updated video — serves stale cached version.
**Why it happens:** The mobile `download_manifest` uses `video_version` to detect staleness. If the coach replaces a video but `video_version` is not incremented, the mobile client thinks the cached version is current.
**How to avoid:** When the coach saves an exercise with a new `mux_asset_id`, increment `exercises.video_version`. A Server Action `updateExerciseVideo` must include `video_version: supabase.rpc('increment', ...)` or a simple `{ video_version: currentVersion + 1 }`.
**Warning signs:** Students play old video after coach updates it; `download_manifest.video_version` matches stale value.

---

## Code Examples

### Creating a Supabase Server Client (verified pattern)
```typescript
// Source: @supabase/ssr README — verified in node_modules/0.10.3
import { createServerClient } from '@supabase/ssr'
import { cookies } from 'next/headers'

export async function createSupabaseServerClient() {
  const cookieStore = await cookies()
  return createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY!,
    {
      cookies: {
        getAll() { return cookieStore.getAll() },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value, options }) =>
            cookieStore.set(name, value, options))
        },
      },
    }
  )
}
```

### Server Action with useActionState (Next.js 16 pattern)
```typescript
// Source: node_modules/next/dist/docs/01-app/01-getting-started/07-mutating-data.md
'use client'
import { useActionState } from 'react'
import { createProgram } from '@/app/actions/programs'

export function CreateProgramForm() {
  const [state, action, pending] = useActionState(createProgram, undefined)
  return (
    <form action={action}>
      <input name="title" required />
      {state?.errors?.title && <p>{state.errors.title}</p>}
      <button disabled={pending}>Create</button>
    </form>
  )
}
```

### Mux Upload URL creation (verified from @mux/mux-node@14.1.0 source)
```typescript
// Source: node_modules/@mux/mux-node/src/resources/video/uploads.ts
const upload = await mux.video.uploads.create({
  cors_origin: 'https://admin.example.com',
  new_asset_settings: { playback_policies: ['public'] },
})
// upload.id = the upload ID (store as mux_asset_id in exercises)
// upload.url = the signed GCS URL for MuxUploader endpoint prop
```

### Cascade delete (verified from schema)
```typescript
// Source: supabase/migrations/001_initial_schema.sql
// programs.id ON DELETE CASCADE -> sessions -> exercises
// programs.id ON DELETE CASCADE -> enrollments
// sessions.id ON DELETE CASCADE -> progress_records
// sessions.id ON DELETE CASCADE -> feedback_threads
// A single delete from 'programs' cascades all child records.
await supabase.from('programs').delete().eq('id', programId)
```

---

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `middleware.ts` | `proxy.ts` (exported `proxy` function) | Next.js v16.0.0 | Must rename file and function — old name silently ignored |
| `@supabase/auth-helpers-nextjs` | `@supabase/ssr` with `getAll`/`setAll` | Deprecated | Already correct (`@supabase/ssr@0.10.3` installed) |
| `getSession()` for auth | `getUser()` for auth decisions | @supabase/ssr readme | `getSession()` is unverified; never use for access control |
| FCM legacy HTTP API | FCM v1 HTTP API with OAuth2 bearer token | 2023 (legacy deprecated) | Must generate access token from service account JSON |
| Materialized views | Regular views with `security_invoker=true` | Phase 2 decision | Materialized views break RLS — already correctly implemented |
| `revalidatePath` only | `refresh()` from `next/cache` for router refresh | Next.js 16 | Use `refresh()` for full router rerender; `revalidatePath` for cache tag invalidation |

**Deprecated/outdated:**
- `middleware.ts`: Renamed to `proxy.ts` in Next.js 16. Codemod: `npx @next/codemod@canary middleware-to-proxy .`
- `@supabase/auth-helpers-nextjs`: Consolidated into `@supabase/ssr`. Already migrated.
- FCM legacy API (`https://fcm.googleapis.com/fcm/send`): Deprecated. Must use v1 (`/v1/projects/{projectId}/messages:send`).

---

## Runtime State Inventory

> This is a content creation phase, not a rename/refactor phase. No existing runtime state needs migration.

| Category | Items Found | Action Required |
|----------|-------------|------------------|
| Stored data | No existing content in `programs`, `sessions`, `exercises` tables (these are empty until the admin panel populates them) | None |
| Live service config | Supabase Edge Functions `mux-webhook` and `projection-refresh` already deployed (stub). The `send-fcm` function does not yet exist. | Create `send-fcm` edge function; complete `mux-webhook` stub |
| OS-registered state | None | None |
| Secrets/env vars | `MUX_TOKEN_ID`, `MUX_TOKEN_SECRET` in `.env.local`; `FIREBASE_SERVICE_ACCOUNT_JSON` and `FIREBASE_PROJECT_ID` need to be added to Supabase Vault for `send-fcm` edge function; `MUX_WEBHOOK_SIGNING_SECRET` needs to be added to Supabase Vault for `mux-webhook` | Add secrets to Supabase Vault (manual step) |
| Build artifacts | `admin/lib/cqrs/query-client.ts` exists and is correct — no rebuild needed | None |

---

## Open Questions

1. **Firebase service account credentials**
   - What we know: `FIREBASE_PROJECT_ID` and a service account JSON are needed for FCM v1 in the `send-fcm` Edge Function.
   - What's unclear: Whether the coach has already run `flutterfire configure` and has a real Firebase project set up (Phase 7 verification noted `firebase_options.dart` is still a placeholder).
   - Recommendation: The planner should include a Wave 0 task for the coach to: (a) run `flutterfire configure`, (b) download service account JSON from Firebase Console, (c) store it in Supabase Vault as `FIREBASE_SERVICE_ACCOUNT_JSON`. The plan should proceed assuming credentials will exist; the automated test can verify token storage but not actual FCM delivery (human UAT item).

2. **Mux Webhook Signing Secret**
   - What we know: `TODO Phase 8` comment exists in `mux-webhook/index.ts` to validate `Mux-Signature`.
   - What's unclear: Whether the Mux webhook URL has been registered in the Mux dashboard.
   - Recommendation: The planner should include a task to: (a) register the Supabase Edge Function URL as a Mux webhook in the Mux dashboard, (b) copy the signing secret to Supabase Vault.

3. **Admin login email**
   - What we know: The admin panel has one coach. Auth is Supabase email/password. There's no user creation UI in the plan.
   - What's unclear: Whether the coach user account already exists in Supabase Auth.
   - Recommendation: The plan should note that the coach user must be created manually in the Supabase dashboard (or via Supabase CLI `supabase auth user create`). The login page will use existing Supabase credentials.

4. **`NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY` vs `NEXT_PUBLIC_SUPABASE_ANON_KEY`**
   - What we know: The `.env.local.example` uses `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY`.
   - What's unclear: The `@supabase/ssr` README examples use `NEXT_PUBLIC_SUPABASE_ANON_KEY`.
   - Recommendation: These are the same key (Supabase rebranded it). The existing `.env.local.example` variable name takes precedence — use `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY` throughout.

---

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Node.js | All Next.js operations | ✓ | 22.22.3 | — |
| npm | Package install | ✓ | 10.9.8 | — |
| next@16.2.6 | Admin panel | ✓ | 16.2.6 | — |
| @mux/mux-node@14.1.0 | Upload URL generation | ✓ | 14.1.0 | — |
| @mux/mux-uploader-react@1.5.0 | Browser video upload | ✓ | 1.5.0 | — |
| @supabase/ssr@0.10.3 | Auth SSR | ✓ | 0.10.3 | — |
| @supabase/supabase-js@2.106.2 | DB writes | ✓ | 2.106.2 | — |
| react-hook-form@7.76.1 | Forms | ✓ | 7.76.1 | — |
| zod@4.4.3 | Validation | ✓ | 4.4.3 | — |
| shadcn/ui components | UI components | ✗ (not added yet) | via CLI | Must run `npx shadcn@latest add ...` |
| firebase-admin | FCM push | ✗ (not installed) | — | Use Supabase Edge Function + FCM v1 REST API |
| Supabase Edge Functions runtime | FCM send, Mux webhook | ✓ | Deno 2 | — |
| Firebase project credentials | FCM delivery | ? (placeholder) | — | Human step: `flutterfire configure` |
| Mux API credentials | Video uploads | ✓ (in .env.local.example) | — | Real credentials needed in .env.local |

**Missing dependencies with no fallback:**
- Real Firebase project credentials (`firebase_options.dart` is a placeholder stub) — required for FCM delivery. Manual human step before push notifications work end-to-end.
- Real Mux API credentials in `.env.local` — required for video upload. Manual setup.

**Missing dependencies with fallback:**
- `shadcn/ui` components — install via `npx shadcn@latest add button input card table dialog select textarea badge separator` in Wave 0.

---

## Validation Architecture

> `workflow.nyquist_validation` is not set in `.planning/config.json` — treating as enabled.

### Test Framework
| Property | Value |
|----------|-------|
| Framework | None installed (no jest, vitest, playwright in admin/) |
| Config file | None — must be added in Wave 0 if automated admin tests are desired |
| Quick run command | `npm run build` (type-check only; no unit tests configured) |
| Full suite command | `npm run build && npm run lint` |

**Note:** The admin panel has no test infrastructure. Given the coach is a single user and the panel is purely internal, the validation strategy should be:
- TypeScript compilation (`npm run build`) as the primary automated gate.
- Manual UAT checklist for end-to-end flows (video upload, feedback reply, push notification).
- No unit tests for this phase (consistent with prior admin work — all test work has been Flutter-side).

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| FR-015 | Program CRUD pages render; form submits without TS errors | build | `npm run build` | ❌ Wave 0: create pages |
| FR-016 | Session/exercise editor with video upload UI renders | build | `npm run build` | ❌ Wave 0: create pages |
| FR-017 | Publish/unpublish toggle changes `programs.published` | manual | — | Manual UAT |
| FR-018 | Feedback list shows threads; reply form submits | build | `npm run build` | ❌ Wave 0: create pages |
| FR-019 | Video replace increments `video_version` | manual | — | Manual UAT + mobile sync test |

### Wave 0 Gaps
- [ ] `admin/proxy.ts` — auth guard for all admin routes
- [ ] `admin/lib/supabase/server.ts` — `createSupabaseServerClient()` factory
- [ ] `admin/app/(auth)/login/page.tsx` — login form
- [ ] `admin/app/(admin)/layout.tsx` — admin shell with sidebar
- [ ] `admin/app/api/mux-upload/route.ts` — Mux upload URL endpoint
- [ ] `supabase/functions/send-fcm/index.ts` — FCM push edge function
- [ ] Supabase migration for `program-assets` storage bucket
- [ ] shadcn components: `npx shadcn@latest add button input card table dialog select textarea badge separator`

---

## Sources

### Primary (HIGH confidence)
- `admin/node_modules/next/dist/docs/01-app/03-api-reference/03-file-conventions/proxy.md` — proxy.ts breaking change, migration from middleware.ts
- `admin/node_modules/next/dist/docs/01-app/01-getting-started/07-mutating-data.md` — Server Actions, useActionState, revalidatePath, refresh()
- `admin/node_modules/next/dist/docs/01-app/02-guides/authentication.md` — auth guard pattern, getUser() vs getSession()
- `admin/node_modules/@supabase/ssr/README.md` — getAll/setAll cookie pattern, getUser() requirement
- `admin/node_modules/@mux/mux-node/src/resources/video/uploads.ts` — Direct Upload API shape, Upload interface
- `admin/node_modules/@mux/mux-uploader-react/README.md` — MuxUploader endpoint prop
- `admin/lib/cqrs/query-client.ts` — existing service role pattern
- `supabase/migrations/001_initial_schema.sql` — cascade delete chain, existing columns
- `supabase/migrations/004_fcm_token.sql` — fcm_token column on students
- `.planning/phases/07-us5-private-feedback/07-VERIFICATION.md` — confirmation that FCM server-side trigger is Phase 8 scope
- `admin/package.json` — actual installed package versions

### Secondary (MEDIUM confidence)
- `admin/node_modules/next/dist/docs/01-app/01-getting-started/15-route-handlers.md` — Route Handler pattern for Mux upload URL
- `admin/AGENTS.md` / `admin/CLAUDE.md` — breaking changes warning confirmed
- `supabase/config.toml` — Deno 2 edge runtime version

### Tertiary (LOW confidence — verify before implementing)
- FCM v1 HTTP API service account JWT pattern — not verified against official docs; verify against `https://firebase.google.com/docs/cloud-messaging/auth-server` before implementing the `getFcmAccessToken()` helper in the Edge Function.

---

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — verified all versions from actual node_modules
- Architecture: HIGH — proxy.ts breaking change confirmed from local docs; patterns derived from actual installed library versions
- Pitfalls: HIGH — cascade delete verified from schema; proxy.ts rename verified from docs; Mux webhook pattern confirmed from existing stub
- FCM push approach: MEDIUM — Edge Function pattern is consistent with existing codebase; FCM v1 service account JWT detail is LOW (needs verification vs official docs)

**Research date:** 2026-05-29
**Valid until:** 2026-06-29 (Next.js moves fast; re-verify proxy.ts if upgrading beyond 16.2.6)
