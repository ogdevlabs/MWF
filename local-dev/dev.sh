#!/usr/bin/env bash
# dev.sh — Start the full local development environment in one command
#
# Starts (each in its own terminal tab / background process):
#   1. Local Supabase stack
#   2. Next.js admin panel (http://localhost:3555)
#   3. Flutter app on iOS Simulator
#
# Usage:
#   ./local-dev/dev.sh              — start everything (iOS + admin)
#   ./local-dev/dev.sh android      — use Android instead of iOS
#   ./local-dev/dev.sh admin-only   — skip Flutter (admin panel only)
#   ./local-dev/dev.sh mobile-only  — skip admin panel
#
# Press Ctrl+C to stop all processes.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPTS="$REPO_ROOT/local-dev"
cd "$REPO_ROOT"

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; BOLD='\033[1m'; NC='\033[0m'
step()  { echo -e "\n${GREEN}${BOLD}▶ $*${NC}"; }
warn()  { echo -e "${YELLOW}⚠  $*${NC}"; }
die()   { echo -e "${RED}✗  $*${NC}"; exit 1; }
banner() {
  echo -e "\n${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BOLD}  MWF — Local Dev${NC}"
  echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

TARGET="${1:-ios}"
PIDS=()

cleanup() {
  echo -e "\n${YELLOW}Shutting down...${NC}"
  for pid in "${PIDS[@]}"; do
    kill "$pid" 2>/dev/null || true
  done
  # Stop Supabase gracefully
  npx supabase stop 2>/dev/null || true
  echo -e "${GREEN}✓ All processes stopped.${NC}"
  exit 0
}
trap cleanup INT TERM

# ── preflight ─────────────────────────────────────────────────────────────────
command -v flutter >/dev/null 2>&1 || die "Flutter not found. Run ./local-dev/install.sh first."
command -v node    >/dev/null 2>&1 || die "Node.js not found. Run ./local-dev/install.sh first."

if ! docker info >/dev/null 2>&1; then
  die "Docker is not running. Start Docker Desktop, then retry."
fi

banner

# ── install deps ──────────────────────────────────────────────────────────────
step "Installing dependencies"
cd "$REPO_ROOT/mobile" && flutter pub get 2>&1 | grep -E "Changed|up to date|Resolving" || true
cd "$REPO_ROOT/admin"  && npm install --silent 2>/dev/null || npm install
cd "$REPO_ROOT"

# ── start Supabase ────────────────────────────────────────────────────────────
step "Starting local Supabase"
npx supabase start
npx supabase db push 2>/dev/null || warn "Migration push failed — DB may already be up to date."

# Extract anon key from supabase status
SUPABASE_URL="http://localhost:54321"
SUPABASE_ANON_KEY=$(npx supabase status 2>/dev/null \
  | grep -E "anon key" | awk '{print $NF}' | tr -d '[:space:]' || echo "")

if [[ -z "$SUPABASE_ANON_KEY" ]]; then
  warn "Could not read anon key from supabase status — Flutter will use placeholder."
  SUPABASE_ANON_KEY="placeholder"
fi

echo ""
echo "  Supabase Studio: http://localhost:54323"
echo "  API:             $SUPABASE_URL"

# ── ensure admin .env.local ───────────────────────────────────────────────────
if [[ ! -f admin/.env.local ]]; then
  cp admin/.env.local.example admin/.env.local
  warn "Created admin/.env.local — update NEXT_PUBLIC_SUPABASE_ANON_KEY with the key above."
fi

# ── start admin panel (background) ───────────────────────────────────────────
if [[ "$TARGET" != "mobile-only" ]]; then
  step "Starting Next.js admin panel (background)"
  cd "$REPO_ROOT/admin"
  npm run dev -- --port 3555 &>/tmp/mwf-admin.log &
  PIDS+=($!)
  echo "  Admin panel: http://localhost:3555  (logs: /tmp/mwf-admin.log)"
fi

# ── start Flutter app ─────────────────────────────────────────────────────────
if [[ "$TARGET" != "admin-only" ]]; then
  MOBILE_TARGET="ios"
  [[ "$TARGET" == "android" ]] && MOBILE_TARGET="android"

  step "Launching Flutter app ($MOBILE_TARGET)"
  cd "$REPO_ROOT"

  if [[ "$MOBILE_TARGET" == "ios" ]]; then
    flutter emulators --launch apple_ios_simulator 2>/dev/null || true
    sleep 3
    DEVICE_FLAG="-d apple_ios_simulator"
  else
    flutter emulators --launch Pixel_10_Pro 2>/dev/null || true
    sleep 5
    DEVICE_FLAG="-d Pixel_10_Pro"
  fi

  cd "$REPO_ROOT/mobile"
  # shellcheck disable=SC2086
  flutter run $DEVICE_FLAG \
    --dart-define=SUPABASE_URL="$SUPABASE_URL" \
    --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY" &
  PIDS+=($!)
fi

# ── wait ─────────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}✓ Dev environment running.${NC}"
echo ""
echo "  Press Ctrl+C to stop everything."
echo ""

wait
