# MWF — Move With Fergie

An offline-first Flutter mobile app (iOS + Android) where students follow
coach-designed multi-week Mat Pilates programs with video + 3D exercise playback,
subscription access, body metric tracking, and a coach feedback loop.

## Spec

This repository contains the full [Spec Kit](https://github.com/github/spec-kit)
specification for the project.

| Artifact | Description |
|----------|-------------|
| [specs/001-mat-pilates-coach/spec.md](specs/001-mat-pilates-coach/spec.md) | Requirements, 6 user stories, success criteria |
| [specs/001-mat-pilates-coach/plan.md](specs/001-mat-pilates-coach/plan.md) | Tech stack, architecture, project structure |
| [specs/001-mat-pilates-coach/data-model.md](specs/001-mat-pilates-coach/data-model.md) | Postgres + Drift SQLite schema, RLS policies |
| [specs/001-mat-pilates-coach/tasks.md](specs/001-mat-pilates-coach/tasks.md) | 121 implementation tasks across 9 phases |

## Tech Stack

| Layer | Choice |
|-------|--------|
| Mobile | Flutter 3.22 / Dart 3.4 (iOS + Android) |
| State | Riverpod 2.x |
| Local DB | Drift (SQLite, offline-first) |
| Backend | Supabase (Postgres, Auth, Storage, Realtime) |
| Video CDN | Mux (HLS streaming + offline download) |
| In-App Purchase | RevenueCat |
| 3D Rendering | model_viewer_plus (glTF/GLB) |
| Admin Panel | Next.js 15 (TypeScript) |

## MVP Scope (P1)

1. Student enrolls and subscribes via in-app purchase
2. Student follows a structured multi-week program session by session
3. Video + 3D animation exercise playback
4. Offline-first — pre-download sessions, sync progress on reconnect

## License

Private — © Ferere Labs
