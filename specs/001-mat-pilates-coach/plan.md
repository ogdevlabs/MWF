# Implementation Plan: Mat Pilates Coach — Student App

**Branch**: `001-mat-pilates-coach` | **Date**: 2026-05-24 | **Spec**: `spec.md`

---

## Summary

Build an offline-first Flutter mobile app (iOS + Android) where students follow
coach-designed multi-week Mat Pilates programs featuring video + 3D animation
exercise playback, subscription gating via in-app purchase, body metric tracking,
and a bidirectional coach feedback loop. A companion Next.js web admin panel allows
the coach to create/publish programs and respond to student feedback.

---

## Technical Context

**Language/Version**: Dart 3.4 / Flutter 3.22

**Primary Dependencies**:
- `flutter_riverpod 2.x` — state management (code generation with riverpod_generator)
- `drift` — SQLite ORM; offline-first local database
- `supabase_flutter` — auth (email/password, Apple, Google), real-time, remote API
- `video_player` + `chewie` — video playback
- `model_viewer_plus` — 3D glTF/GLB asset rendering (WebView-backed)
- `background_downloader` — background video/asset pre-download
- `purchases_flutter` — RevenueCat SDK; cross-platform in-app purchase
- `go_router` — declarative navigation with auth guards
- `dio` — HTTP client for Mux and custom endpoints
- `firebase_messaging` — FCM push notifications
- `flutter_local_notifications` — foreground notification display

**Storage**:
- **Supabase PostgreSQL** — all relational data (programs, sessions, exercises,
  progress, metrics, feedback)
- **Mux** — video hosting; HLS streaming + signed download URLs for offline
- **Supabase Storage** — 3D GLB assets, thumbnails, feedback photos
- **SQLite (Drift)** — local mirror of programs/sessions/exercises + progress queue

**Testing**: `flutter_test`, `mocktail`, `drift` in-memory DB, `fake_async`

**Target Platform**: iOS 16+ / Android 10+ (API 29+)

**Project Type**: Mobile app + Web admin panel

**Performance Goals**:
- Video playback starts ≤ 2 s (pre-downloaded) / ≤ 5 s (streaming on 4G)
- 3D model renders ≤ 1 s after screen open
- Offline progress syncs ≤ 10 s after reconnection

**Constraints**:
- Offline-first; app must be fully functional with no network after initial sync
- Apple Sign-In mandatory (App Store policy) when Google Sign-In is offered
- Subscription receipt validation delegated to RevenueCat; no raw StoreKit/Play
  Billing calls in app code
- Videos never stored in Supabase Storage (size/cost); Mux is the exclusive video
  CDN
- No PII logged to third-party analytics without explicit user consent

**Scale/Scope**: Single-coach brand; ~50 screens across mobile + ~20 admin pages

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────┐
│                  Flutter Mobile App                  │
│                                                     │
│  ┌─────────┐  ┌──────────┐  ┌──────────────────┐   │
│  │  Auth   │  │ Programs │  │ Session Player   │   │
│  │(Supabase│  │  Browse  │  │ video_player +   │   │
│  │ Auth)   │  │          │  │ model_viewer_plus│   │
│  └────┬────┘  └────┬─────┘  └────────┬─────────┘   │
│       │            │                  │             │
│  ┌────▼────────────▼──────────────────▼──────────┐  │
│  │            Riverpod State Layer                │  │
│  └────────────────────┬───────────────────────────┘  │
│                       │                             │
│  ┌────────────────────▼───────────────────────────┐  │
│  │         Core Services                          │  │
│  │  SyncService │ DownloadService │ OfflineQueue  │  │
│  └──────┬───────────────┬─────────────────────────┘  │
│         │               │                            │
│  ┌──────▼──────┐ ┌──────▼────────────────────────┐  │
│  │ Drift (SQLite│ │   background_downloader       │  │
│  │  local DB)  │ │   (video + GLB assets)        │  │
│  └─────────────┘ └───────────────────────────────┘  │
└──────────────────────────┬──────────────────────────┘
                           │ HTTPS
          ┌────────────────┼────────────────────┐
          │                │                    │
   ┌──────▼──────┐  ┌──────▼──────┐  ┌─────────▼──────┐
   │  Supabase   │  │    Mux      │  │  RevenueCat    │
   │  (Postgres  │  │  (Video     │  │  (IAP + Sub    │
   │   Auth      │  │   CDN +     │  │   management)  │
   │   Storage   │  │   HLS)      │  │                │
   │   Realtime) │  └─────────────┘  └────────────────┘
   └─────────────┘
          ▲
          │ Admin API calls
   ┌──────┴──────────────────────────────┐
   │       Next.js 15 Admin Panel        │
   │  (Coach content creation + feedback)│
   └─────────────────────────────────────┘
```

---

## Project Structure

### Documentation

```text
specs/001-mat-pilates-coach/
├── spec.md          ← requirements & user stories
├── plan.md          ← this file
├── data-model.md    ← DB schema & entity relationships
└── tasks.md         ← implementation task list
```

### Source Code

```text
mobile/                          # Flutter app
├── lib/
│   ├── core/
│   │   ├── auth/
│   │   │   ├── auth_provider.dart
│   │   │   └── auth_repository.dart
│   │   ├── database/
│   │   │   ├── app_database.dart         # Drift database definition
│   │   │   ├── tables/                   # Drift table definitions
│   │   │   └── daos/                     # Drift DAOs per entity
│   │   ├── network/
│   │   │   ├── supabase_client.dart
│   │   │   └── mux_client.dart
│   │   ├── sync/
│   │   │   ├── sync_service.dart         # Offline→remote sync
│   │   │   └── sync_queue.dart           # Local pending-operations queue
│   │   └── downloads/
│   │       └── download_service.dart     # background_downloader wrapper
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │       ├── login_screen.dart
│   │   │       ├── signup_screen.dart
│   │   │       └── onboarding_screen.dart
│   │   ├── programs/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │       ├── program_list_screen.dart
│   │   │       ├── program_detail_screen.dart
│   │   │       └── paywall_screen.dart
│   │   ├── session/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │       ├── session_player_screen.dart
│   │   │       ├── exercise_card.dart
│   │   │       ├── video_player_widget.dart
│   │   │       └── model_viewer_widget.dart
│   │   ├── progress/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │       ├── progress_dashboard_screen.dart
│   │   │       ├── metric_log_screen.dart
│   │   │       └── streak_widget.dart
│   │   └── feedback/
│   │       ├── data/
│   │       ├── domain/
│   │       └── presentation/
│   │           ├── feedback_thread_screen.dart
│   │           └── notifications_screen.dart
│   ├── shared/
│   │   ├── widgets/
│   │   ├── theme/
│   │   │   └── app_theme.dart
│   │   └── router/
│   │       └── app_router.dart           # go_router config
│   └── main.dart
├── test/
│   ├── unit/
│   ├── integration/
│   └── widget/
└── pubspec.yaml

admin/                           # Next.js 15 admin panel
├── app/
│   ├── (auth)/
│   │   └── login/page.tsx
│   ├── programs/
│   │   ├── page.tsx             # Program list
│   │   ├── new/page.tsx
│   │   └── [id]/
│   │       ├── page.tsx         # Program detail / edit
│   │       └── sessions/
│   │           └── [sessionId]/page.tsx
│   ├── students/
│   │   └── [id]/
│   │       └── feedback/page.tsx
│   └── layout.tsx
├── components/
│   ├── video-uploader.tsx       # Mux direct upload
│   ├── asset-uploader.tsx       # GLB upload to Supabase Storage
│   ├── exercise-editor.tsx
│   └── feedback-reply.tsx
├── lib/
│   ├── supabase.ts
│   └── mux.ts
└── package.json

supabase/
├── migrations/                  # SQL migration files
└── functions/                   # Edge functions
    ├── revenuecat-webhook/      # Sync subscription status
    └── mux-webhook/             # Asset ready → update DB
```

---

## Key Technical Decisions

### Why Supabase over Firebase
Supabase provides a relational PostgreSQL model which maps cleanly to the
program → session → exercise hierarchy with proper foreign keys and joins.
Firebase Firestore's document model requires denormalization that would complicate
the coach admin panel queries. Supabase Auth also supports Apple Sign-In natively.

### Why Mux for Video
Mux handles adaptive HLS streaming, mobile-optimized transcoding, and signed
download URLs for offline playback. Supabase Storage is unsuitable for large video
files at scale (egress cost, no adaptive bitrate). Mux webhooks notify the backend
when an asset finishes processing so the DB record can be updated automatically.

### Why RevenueCat
RevenueCat abstracts App Store and Google Play billing into a single SDK, provides
a webhook to sync subscription status to Supabase, and eliminates receipt validation
server code entirely.

### Offline Strategy
- **Read path**: All content (programs, sessions, exercises, metadata) is mirrored
  to the local Drift SQLite database on first access and refreshed on sync.
- **Write path**: All mutations (completions, metrics, feedback drafts) are written
  to a local `sync_queue` table first, then replayed to Supabase when online.
- **Media path**: Videos and GLB assets are downloaded via `background_downloader`
  to the app's documents directory; Drift stores local file paths.

### Why Riverpod (not Bloc/Provider)
Riverpod's compile-time safety, AsyncNotifier pattern, and first-class support for
code generation (`riverpod_generator`) reduce boilerplate while keeping state
testable in isolation. It integrates cleanly with Drift streams for reactive UI.

---

## Phase Breakdown

| Phase | User Stories | Deliverable |
|-------|--------------|-------------|
| 0 — Setup | — | Flutter + Next.js scaffolds, CI, Supabase project |
| 1 — Foundation | — | Auth, local DB, sync engine, router guards |
| 2 — US1 | Enroll & Access | Signup, subscription, program browse, paywall |
| 3 — US2 | Daily Session | Session player, video + 3D, completion |
| 4 — US3 | Offline-First | Background download, offline queue, sync |
| 5 — US4 | Metrics | Metric logging, charts, progress dashboard |
| 6 — US5 | Coach Feedback | Feedback threads, push notifications |
| 7 — US6 | Admin Panel | Program/session/exercise CRUD, video upload |
| 8 — Polish | — | Accessibility, error states, edge cases |

---

## Complexity Tracking

No constitution violations identified. Architecture uses:
- 2 projects (mobile + admin) — justified by separate user personas and tech stacks
- External services (Supabase, Mux, RevenueCat) — each replaces a non-trivial
  subsystem that would otherwise require custom server infrastructure
