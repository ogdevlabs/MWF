---
plan: 02-01
phase: 2
subsystem: infrastructure
tags: [flutter, supabase, cqrs, packages, migrations, edge-functions]
dependency_graph:
  requires: []
  provides:
    - connectivity_plus importable in mobile/
    - sign_in_with_apple importable in mobile/
    - google_sign_in importable in mobile/
    - crypto importable in mobile/
    - fake_async available for tests
    - 5 CQRS projection views in supabase/migrations/003_cqrs_read_models.sql
    - projection-refresh edge function stub
  affects:
    - All Phase 2 plans (T033-T039 can now import required packages)
    - T133-T136 (CQRS views ready as server-side read models)
tech_stack:
  added:
    - connectivity_plus 7.1.1
    - sign_in_with_apple 8.0.0
    - google_sign_in 7.2.0
    - crypto 3.0.7 (promoted from transitive to direct)
    - fake_async 1.3.3 (dev)
  patterns:
    - CQRS regular views with security_invoker=true (not materialized)
    - Deno.serve edge function pattern
key_files:
  created:
    - supabase/migrations/003_cqrs_read_models.sql
    - supabase/functions/projection-refresh/index.ts
  modified:
    - mobile/pubspec.yaml
    - mobile/pubspec.lock
decisions:
  - google_sign_in resolved to 7.2.0 instead of plan's ^8.0.0 (pub constraint resolution — not a deviation, plan notes "or resolved version")
  - fake_async resolved to 1.3.3 (was already transitive dependency, moved to dev direct)
  - crypto resolved to 3.0.7 (was already transitive dependency, moved to direct)
metrics:
  duration: "~8 minutes"
  completed: 2026-05-25
  tasks_completed: 3
  tasks_total: 3
  files_created: 2
  files_modified: 2
---

# Phase 2 Plan 01: Missing Packages + CQRS Schema + Projection-Refresh Edge Function Summary

Flutter packages required by all Phase 2 auth and connectivity tasks added via `flutter pub add`; 5 CQRS projection views created as regular views with `security_invoker=true`; `projection-refresh` edge function stub created following the `revenuecat-webhook` Deno.serve pattern.

## What Was Built

### Task 1: Flutter Package Additions

Added 4 runtime packages and 1 dev package to `mobile/pubspec.yaml` via `flutter pub add`:

| Package | Resolved Version | Purpose |
|---------|-----------------|---------|
| connectivity_plus | 7.1.1 | Network connectivity detection (T033) |
| sign_in_with_apple | 8.0.0 | Apple Sign-In (T034-T036) |
| google_sign_in | 7.2.0 | Google Sign-In (T034-T036) |
| crypto | 3.0.7 | Hashing/HMAC utilities |
| fake_async (dev) | 1.3.3 | Test time control |

`flutter pub get` exits 0. All packages resolve without conflict.

### Task 2: CQRS Projection Views Migration (`003_cqrs_read_models.sql`)

5 regular SQL views (NOT materialized) created with `WITH (security_invoker = true)` so `auth.uid()` evaluates per-request, preserving per-student RLS:

1. **program_catalog_view** — Published programs with enrollment and subscription overlay
2. **student_today_session_view** — Current session for the enrolled student's current day
3. **session_playback_view** — Ordered exercises with video/model readiness flags
4. **student_progress_dashboard_view** — Aggregated completion stats per program
5. **student_notifications_view** — Coach replies ordered by replied_at DESC

All 5 views carry `GRANT SELECT ON ... TO authenticated`. No MATERIALIZED keyword anywhere in the file.

### Task 3: projection-refresh Edge Function (`supabase/functions/projection-refresh/index.ts`)

Edge function created following the exact `revenuecat-webhook/index.ts` pattern:
- `import "@supabase/functions-js/edge-runtime.d.ts"` at top
- `Deno.serve(async (req) => { ... })` pattern
- Returns 405 for non-POST requests
- Parses `WebhookPayload` interface (`type`, `table`, `record`, `old_record`, `schema`)
- Returns `{ refreshed: true, table, type, timestamp }`
- Error handler returns 400 on bad JSON payload
- Comments document the manual Supabase Dashboard webhook configuration needed

## Deviations from Plan

### Version resolution (non-breaking)

- **google_sign_in** resolved to `7.2.0` not `^8.0.0` — pub constraint resolution decided the compatible version. The plan notes "or resolved version". No impact.
- **crypto** and **fake_async** were already transitive dependencies in the lock file; `flutter pub add` promoted them to direct dependencies without changing the resolved version. No impact.

## Verification Results

```
# Task 1 verification
$ cd mobile && grep -q "connectivity_plus" pubspec.yaml && grep -q "sign_in_with_apple" pubspec.yaml && grep -q "google_sign_in" pubspec.yaml && grep -q "crypto" pubspec.yaml && grep -q "fake_async" pubspec.yaml && echo "PASS"
PASS

$ flutter pub get
Got dependencies!
exit: 0

$ grep -c "connectivity_plus\|sign_in_with_apple\|google_sign_in\|crypto" mobile/pubspec.yaml
4

# Task 2 verification
$ grep -c "CREATE VIEW" supabase/migrations/003_cqrs_read_models.sql
5
$ grep -c "security_invoker = true" supabase/migrations/003_cqrs_read_models.sql
5
$ grep -c "GRANT SELECT" supabase/migrations/003_cqrs_read_models.sql
5
$ grep -c "MATERIALIZED" supabase/migrations/003_cqrs_read_models.sql
0

# Task 3 verification
$ test -f supabase/functions/projection-refresh/index.ts && grep -q 'Deno.serve' ... && grep -q '@supabase/functions-js/edge-runtime.d.ts' ... && echo "PASS"
PASS
```

## Known Stubs

The `projection-refresh` edge function is intentionally a logging stub — views are live (not materialized), so no actual refresh action is needed. Future plans may add cache invalidation logic here.

## Commits

| Hash | Task | Description |
|------|------|-------------|
| 0c22f6d | Task 1 | feat(02-01): add missing Flutter packages for Phase 2 |
| 2120ead | Task 2 | feat(02-01): add CQRS projection views migration (T131) |
| f8d85c5 | Task 3 | feat(02-01): add projection-refresh edge function (T132) |

## Self-Check: PASSED

- `mobile/pubspec.yaml` — modified, all 5 packages present
- `supabase/migrations/003_cqrs_read_models.sql` — created, 5 views, 5 security_invoker, 0 MATERIALIZED
- `supabase/functions/projection-refresh/index.ts` — created, Deno.serve pattern confirmed
- All 3 commits present in git log
