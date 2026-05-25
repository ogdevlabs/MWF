#!/usr/bin/env bash
# run-mobile.sh — Install Flutter deps (if needed) and run the mobile app
#
# Usage:
#   ./local-dev/run-mobile.sh              — pick device interactively
#   ./local-dev/run-mobile.sh ios          — iOS Simulator
#   ./local-dev/run-mobile.sh android      — Android Emulator (Pixel 10 Pro)
#   ./local-dev/run-mobile.sh <device-id>  — specific device ID from `flutter devices`

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; CYAN='\033[0;36m'; NC='\033[0m'
step() { echo -e "\n${GREEN}▶ $*${NC}"; }
warn() { echo -e "${YELLOW}⚠  $*${NC}"; }
die()  { echo -e "${RED}✗  $*${NC}"; exit 1; }
info() { echo -e "${CYAN}   $*${NC}"; }

command -v flutter >/dev/null 2>&1 || die "Flutter not found. Run ./local-dev/install.sh first."

# ── resolve Supabase keys from running stack ──────────────────────────────────
SUPABASE_URL="${SUPABASE_URL:-http://localhost:54321}"
SUPABASE_ANON_KEY="${SUPABASE_ANON_KEY:-}"

if [[ -z "$SUPABASE_ANON_KEY" ]]; then
  # Try to extract from `supabase status` output
  STATUS_OUTPUT=$(npx supabase status 2>/dev/null || true)
  if [[ -n "$STATUS_OUTPUT" ]]; then
    SUPABASE_ANON_KEY=$(echo "$STATUS_OUTPUT" | grep -E "anon key" | awk '{print $NF}' | tr -d '[:space:]')
  fi
fi

if [[ -z "$SUPABASE_ANON_KEY" ]]; then
  warn "SUPABASE_ANON_KEY not set and local Supabase may not be running."
  warn "The app will start but Supabase calls will fail until Phase 2 wires them in."
  warn "To fix: ./local-dev/supabase.sh start, then export SUPABASE_ANON_KEY=<key>"
  SUPABASE_ANON_KEY="placeholder"
fi

# ── ensure deps are installed ─────────────────────────────────────────────────
step "Checking Flutter dependencies"
cd "$REPO_ROOT/mobile"
if [[ ! -f pubspec.lock ]] || [[ pubspec.yaml -nt pubspec.lock ]]; then
  echo "  pubspec.yaml changed — running flutter pub get"
  flutter pub get
else
  echo "  pubspec.lock is up to date — skipping pub get"
fi

# ── resolve target device ────────────────────────────────────────────────────
TARGET="${1:-}"

case "$TARGET" in
  ios|"")
    step "Launching iOS Simulator"
    flutter emulators --launch apple_ios_simulator 2>/dev/null || true
    sleep 3
    DEVICE_FLAG="-d apple_ios_simulator"
    ;;
  android)
    step "Launching Android Emulator (Pixel 10 Pro)"
    flutter emulators --launch Pixel_10_Pro 2>/dev/null || true
    sleep 5
    DEVICE_FLAG="-d Pixel_10_Pro"
    ;;
  list)
    flutter devices
    exit 0
    ;;
  *)
    # Treat as explicit device ID
    DEVICE_FLAG="-d $TARGET"
    ;;
esac

# ── run ───────────────────────────────────────────────────────────────────────
echo ""
info "SUPABASE_URL: $SUPABASE_URL"
info "Device:       ${TARGET:-ios (default)}"
echo ""

# shellcheck disable=SC2086
flutter run $DEVICE_FLAG \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY"
