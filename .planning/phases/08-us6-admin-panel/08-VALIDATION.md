---
phase: 8
slug: us6-admin-panel
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-05-29
---

# Phase 8 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | TypeScript compiler + ESLint (no unit test framework — admin is a single-coach internal tool) |
| **Config file** | `admin/package.json` (build + lint scripts) |
| **Quick run command** | `cd admin && npm run build` |
| **Full suite command** | `cd admin && npm run build && npm run lint` |
| **Estimated runtime** | ~15 seconds |

No unit test framework is installed for the admin panel. TypeScript compilation is the primary automated gate. End-to-end flows are verified manually.

---

## Sampling Rate

- **After every task commit:** Run `cd admin && npm run build`
- **After every plan wave:** Run `cd admin && npm run build && npm run lint`
- **Before `/gsd:verify-work`:** Full build + lint must be green
- **Max feedback latency:** 15 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 08-W0-setup | 01 | 1 | FR-015 | build | `cd admin && npm run build` | ❌ W0 | ⬜ pending |
| 08-programs | TBD | 2 | FR-015 | build | `cd admin && npm run build` | ❌ W0 | ⬜ pending |
| 08-sessions | TBD | 2 | FR-016 | build | `cd admin && npm run build` | ❌ W0 | ⬜ pending |
| 08-video | TBD | 3 | FR-016 | build | `cd admin && npm run build` | ❌ W0 | ⬜ pending |
| 08-feedback | TBD | 3 | FR-018 | build | `cd admin && npm run build` | ❌ W0 | ⬜ pending |
| 08-fcm | TBD | 3 | FR-018 | manual | FCM delivery test with real device | N/A | ⬜ pending |
| 08-publish | TBD | 3 | FR-017 | build + manual | `cd admin && npm run build` | ❌ W0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `admin/proxy.ts` — Next.js 16 auth guard (replaces middleware.ts)
- [ ] `admin/lib/supabase/server.ts` — `createSupabaseServerClient()` factory
- [ ] `admin/app/(auth)/login/page.tsx` — login form
- [ ] `admin/app/(admin)/layout.tsx` — admin shell with sidebar
- [ ] `admin/app/api/mux-upload/route.ts` — Mux upload URL Route Handler
- [ ] `supabase/functions/send-fcm/index.ts` — FCM push Edge Function stub
- [ ] `supabase/migrations/005_program_assets_bucket.sql` — program-assets storage bucket
- [ ] `npx shadcn@latest add button input card table dialog select textarea badge separator`

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Publish program → student app shows within 60s | FR-017 | Requires mobile app running + Supabase Realtime | 1. Create + publish program in admin 2. Open Flutter app 3. Verify program appears in program list within 60s |
| Coach replies → student push notification delivered | FR-018 | Requires real Firebase config + real device | 1. Set up Firebase (docs/firebase-setup.md) 2. Reply to feedback in admin 3. Verify push notification appears on student device |
| Updated video invalidates mobile cache | FR-019 | Requires mobile app in airplane mode + reconnect | 1. Student downloads session 2. Coach uploads new video 3. Student reconnects — verify re-download is queued |
| Program delete cascades cleanly | FR-015 | Requires Supabase SQL verification | After delete: `SELECT COUNT(*) FROM sessions WHERE program_id = '<id>'` → 0 |
| Mux video appears in exercise player | FR-016 | Requires Mux webhook + real video | Complete Mux webhook setup; upload a real video; verify `mux_playback_id` populates on exercise row |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 15s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
