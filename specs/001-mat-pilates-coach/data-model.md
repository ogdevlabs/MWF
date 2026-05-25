# Data Model: Mat Pilates Coach

**Branch**: `001-mat-pilates-coach-student-app` | **Date**: 2026-05-24

---

## Entity Relationship Diagram

```
students ────────────────────────────────────┐
   │                                         │
   ├──< enrollments >──< programs            │
   │         │               │               │
   │         │           sessions            │
   │         │               │               │
   │         │           exercises           │
   │         │                               │
   ├──< progress_records (per session)       │
   ├──< metric_logs                          │
   ├──< feedback_threads (student + coach reply) │
   ├──< subscriptions                        │
   └──< download_manifests ─────────────────-┘
```

---

## Supabase PostgreSQL Schema

### `students`

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| `id` | `uuid` | PK, default `gen_random_uuid()` | Mirrors `auth.users.id` |
| `email` | `text` | NOT NULL, UNIQUE | |
| `display_name` | `text` | | |
| `avatar_url` | `text` | | Supabase Storage path |
| `timezone` | `text` | NOT NULL, default `'UTC'` | IANA timezone string |
| `created_at` | `timestamptz` | NOT NULL, default `now()` | |
| `updated_at` | `timestamptz` | NOT NULL, default `now()` | |

RLS: Students can read/update only their own row.

---

### `subscriptions`

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| `id` | `uuid` | PK | |
| `student_id` | `uuid` | FK → `students.id`, NOT NULL | |
| `revenuecat_customer_id` | `text` | NOT NULL | |
| `plan_id` | `text` | NOT NULL | RevenueCat entitlement ID |
| `status` | `text` | NOT NULL | `active` \| `expired` \| `cancelled` \| `grace_period` |
| `valid_until` | `timestamptz` | | null = lifetime |
| `store` | `text` | NOT NULL | `app_store` \| `play_store` |
| `created_at` | `timestamptz` | NOT NULL, default `now()` | |
| `updated_at` | `timestamptz` | NOT NULL, default `now()` | |

RLS: Students read their own. Updated exclusively by RevenueCat webhook edge function.

---

### `programs`

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| `id` | `uuid` | PK | |
| `title` | `text` | NOT NULL | |
| `description` | `text` | | |
| `difficulty` | `text` | NOT NULL | `beginner` \| `intermediate` \| `advanced` |
| `duration_weeks` | `int` | NOT NULL | |
| `thumbnail_url` | `text` | | Supabase Storage path |
| `published` | `boolean` | NOT NULL, default `false` | |
| `published_at` | `timestamptz` | | Set when `published` flips to true |
| `created_by` | `uuid` | FK → `auth.users.id` | Coach user ID |
| `created_at` | `timestamptz` | NOT NULL, default `now()` | |
| `updated_at` | `timestamptz` | NOT NULL, default `now()` | |

RLS: Any authenticated student can read `published = true` programs.
Coach (service role) can write.

---

### `sessions`

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| `id` | `uuid` | PK | |
| `program_id` | `uuid` | FK → `programs.id`, NOT NULL | |
| `day_number` | `int` | NOT NULL | 1-based; unique within program |
| `title` | `text` | NOT NULL | |
| `description` | `text` | | |
| `created_at` | `timestamptz` | NOT NULL, default `now()` | |
| `updated_at` | `timestamptz` | NOT NULL, default `now()` | |

Unique constraint: `(program_id, day_number)`.
RLS: Readable by students enrolled in the parent program; writable by coach.

---

### `exercises`

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| `id` | `uuid` | PK | |
| `session_id` | `uuid` | FK → `sessions.id`, NOT NULL | |
| `display_order` | `int` | NOT NULL | 1-based; unique within session |
| `title` | `text` | NOT NULL | |
| `cue_text` | `text` | | Written instructions shown during exercise |
| `mux_asset_id` | `text` | | Mux asset ID; null until upload processed |
| `mux_playback_id` | `text` | | Mux playback ID for HLS URL construction |
| `mux_download_url` | `text` | | Signed Mux download URL (refreshed via edge fn) |
| `model_asset_url` | `text` | | Supabase Storage path for GLB file |
| `rep_count` | `int` | | null if duration-based |
| `duration_seconds` | `int` | | null if rep-based |
| `video_version` | `int` | NOT NULL, default `1` | Incremented on video replace |
| `created_at` | `timestamptz` | NOT NULL, default `now()` | |
| `updated_at` | `timestamptz` | NOT NULL, default `now()` | |

Unique constraint: `(session_id, display_order)`.
RLS: Readable by students enrolled in the parent program; writable by coach.

---

### `enrollments`

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| `id` | `uuid` | PK | |
| `student_id` | `uuid` | FK → `students.id`, NOT NULL | |
| `program_id` | `uuid` | FK → `programs.id`, NOT NULL | |
| `enrolled_at` | `timestamptz` | NOT NULL, default `now()` | |
| `current_day` | `int` | NOT NULL, default `1` | Next session to complete |

Unique constraint: `(student_id, program_id)`.

---

### `progress_records`

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| `id` | `uuid` | PK | |
| `student_id` | `uuid` | FK → `students.id`, NOT NULL | |
| `session_id` | `uuid` | FK → `sessions.id`, NOT NULL | |
| `completed_at` | `timestamptz` | NOT NULL | |
| `duration_seconds` | `int` | | Actual time taken |
| `synced_from_offline` | `boolean` | NOT NULL, default `false` | |
| `created_at` | `timestamptz` | NOT NULL, default `now()` | |

Unique constraint: `(student_id, session_id)` — one completion per session.

---

### `metric_logs`

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| `id` | `uuid` | PK | |
| `student_id` | `uuid` | FK → `students.id`, NOT NULL | |
| `metric_type` | `text` | NOT NULL | `weight` \| `measurement` \| `flexibility` |
| `metric_subtype` | `text` | | e.g., `waist`, `hip`, `shoulder_flexibility` |
| `value` | `numeric(7,2)` | NOT NULL | |
| `unit` | `text` | NOT NULL | `kg` \| `cm` \| `degrees` |
| `logged_at` | `date` | NOT NULL | User-selected date |
| `created_at` | `timestamptz` | NOT NULL, default `now()` | |

---

### `feedback_threads`

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| `id` | `uuid` | PK | |
| `student_id` | `uuid` | FK → `students.id`, NOT NULL | |
| `session_id` | `uuid` | FK → `sessions.id`, NOT NULL | |
| `student_message` | `text` | NOT NULL | |
| `photo_url` | `text` | | Supabase Storage path |
| `coach_reply` | `text` | | null until coach replies |
| `replied_at` | `timestamptz` | | |
| `notification_sent` | `boolean` | NOT NULL, default `false` | |
| `created_at` | `timestamptz` | NOT NULL, default `now()` | |
| `updated_at` | `timestamptz` | NOT NULL, default `now()` | |

One feedback thread per student per session (unique: `student_id, session_id`).
Realtime subscription on this table drives push notification trigger.

**Privacy**: This table implements strictly private 1-to-1 direct messaging between
each student and the coach. RLS ensures a student can only read rows where
`student_id = auth.uid()`. There is no community or public-facing query path; no
student can ever read another student's threads.

---

## Local SQLite Schema (Drift)

Drift mirrors a subset of the Supabase schema for offline-first operation.
All remote IDs are stored as `TEXT` (UUID strings).

### Local Tables

- `local_programs` — mirrors `programs` (published programs only)
- `local_sessions` — mirrors `sessions`
- `local_exercises` — mirrors `exercises` + `local_video_path TEXT` + `local_model_path TEXT`
- `local_enrollments` — mirrors `enrollments`
- `local_progress_records` — mirrors `progress_records`
- `local_metric_logs` — mirrors `metric_logs`
- `local_feedback_threads` — mirrors `feedback_threads`

### `sync_queue`

Stores pending write operations to replay when connectivity returns.

| Column | Type | Notes |
|--------|------|-------|
| `id` | `INTEGER` | PK autoincrement |
| `operation` | `TEXT` | `insert` \| `update` \| `delete` |
| `table_name` | `TEXT` | Target Supabase table |
| `payload` | `TEXT` | JSON-encoded row data |
| `created_at` | `INTEGER` | Unix timestamp |
| `retry_count` | `INTEGER` | Default 0 |
| `last_error` | `TEXT` | Last error message if any |

### `download_manifest`

Tracks which exercise media files have been downloaded.

| Column | Type | Notes |
|--------|------|-------|
| `exercise_id` | `TEXT` | PK |
| `video_version` | `INTEGER` | Matches `exercises.video_version`; stale if different |
| `video_local_path` | `TEXT` | |
| `model_local_path` | `TEXT` | |
| `download_status` | `TEXT` | `pending` \| `in_progress` \| `complete` \| `failed` |
| `downloaded_at` | `INTEGER` | Unix timestamp |

---

## Row-Level Security Summary

| Table | Student Read | Student Write | Coach |
|-------|-------------|---------------|-------|
| `students` | own row | own row | service role |
| `subscriptions` | own row | ✗ (webhook only) | service role |
| `programs` | published=true | ✗ | service role |
| `sessions` | via enrolled program | ✗ | service role |
| `exercises` | via enrolled program | ✗ | service role |
| `enrollments` | own rows | own insert | service role |
| `progress_records` | own rows | own rows | service role |
| `metric_logs` | own rows | own rows | ✗ |
| `feedback_threads` | own rows only (private DM — no cross-student access) | own insert | service role (reply only) |

---

## CQRS Persistence Model

### Command Side (Source of Truth)

Command handlers write only to normalized transactional tables:

- Content: `programs`, `sessions`, `exercises`
- Student lifecycle: `students`, `subscriptions`, `enrollments`
- Activity: `progress_records`, `metric_logs`, `feedback_threads`

All command writes are idempotent where possible and emit projection refresh
signals (trigger or edge function job).

### Query Side (Read Projections)

Read models are denormalized and optimized for UI rendering. Suggested objects:

- `program_catalog_view` (published programs + enrollment/subscription overlay)
- `student_today_session_view` (current day, next session, lock state)
- `session_playback_view` (ordered exercises + media readiness)
- `student_progress_dashboard_view` (streak snapshot + completion aggregates)
- `student_notifications_view` (coach replies ordered by replied_at)

Read models are eventually consistent with a target projection lag <= 5 seconds.

### Local Drift CQRS Alignment

- Local command queue: `sync_queue` remains append-only for pending commands.
- Local query projections: `local_programs`, `local_sessions`, `local_exercises`,
  and dashboard-oriented aggregates are treated as read models refreshed by sync.
