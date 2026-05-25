# local-dev/

Scripts for running the full MWF stack locally.

## Quick start

```bash
# 1. Install all dependencies (run once after cloning)
./local-dev/install.sh

# 2. Start everything — Supabase + admin panel + Flutter on iOS Simulator
./local-dev/dev.sh
```

## Scripts

| Script | What it does |
|--------|-------------|
| `install.sh` | Install Flutter + npm deps, accept Android licenses, create `.env.local` |
| `dev.sh` | Start full stack (Supabase + admin + Flutter). Ctrl+C stops all. |
| `run-mobile.sh [ios\|android\|<device-id>]` | Run Flutter app only |
| `run-admin.sh` | Run Next.js admin panel only (`http://localhost:3555`) |
| `supabase.sh <start\|stop\|reset\|status\|logs>` | Manage local Supabase stack |

## Options for dev.sh

```bash
./local-dev/dev.sh              # iOS Simulator + admin panel (default)
./local-dev/dev.sh android      # Android Emulator + admin panel
./local-dev/dev.sh admin-only   # admin panel + Supabase only (no Flutter)
./local-dev/dev.sh mobile-only  # Flutter only (no admin panel)
```

## Requirements

- Docker Desktop running (for local Supabase)
- Flutter 3.44+ on PATH
- Node.js 20.9+
- Xcode (iOS) or Android Studio (Android)

See `docs/local-development.md` for full setup guide.
