#!/usr/bin/env bash
# dev.sh — Start the Flutter app (and optionally admin panel)
#
# Supports two modes, chosen automatically from local-dev/.env:
#
#   HOSTED mode  (SUPABASE_URL set to https://... in .env)
#     → Skips Docker / local Supabase entirely
#     → Uses SUPABASE_URL + SUPABASE_PUBLISHABLE_KEY from .env
#
#   LOCAL mode   (SUPABASE_URL absent or http://localhost in .env)
#     → Starts local Docker Supabase stack
#     → Reads keys from `supabase status`
#
# Usage:
#   ./local-dev/dev.sh              — iOS + admin panel
#   ./local-dev/dev.sh android      — Android + admin panel
#   ./local-dev/dev.sh mobile-only  — Flutter only, no admin panel
#   ./local-dev/dev.sh admin-only   — admin panel only
#
# Press Ctrl+C to stop all processes.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Load local credentials (gitignored — never committed)
# shellcheck source=/dev/null
[[ -f "$REPO_ROOT/local-dev/.env" ]] && source "$REPO_ROOT/local-dev/.env"
cd "$REPO_ROOT"

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'
step()  { echo -e "\n${GREEN}${BOLD}▶ $*${NC}"; }
warn()  { echo -e "${YELLOW}⚠  $*${NC}"; }
info()  { echo -e "${CYAN}   $*${NC}"; }
die()   { echo -e "${RED}✗  $*${NC}"; exit 1; }
banner() {
  echo -e "\n${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BOLD}  MWF Dev${NC}"
  echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

TARGET="${1:-ios}"
PIDS=()
USE_LOCAL_SUPABASE=false

cleanup() {
  echo -e "\n${YELLOW}Shutting down...${NC}"
  for pid in "${PIDS[@]}"; do
    kill "$pid" 2>/dev/null || true
  done
  if [[ "$USE_LOCAL_SUPABASE" == "true" ]]; then
    npx supabase stop 2>/dev/null || true
  fi
  echo -e "${GREEN}✓ All processes stopped.${NC}"
  exit 0
}
trap cleanup INT TERM

# ── preflight ─────────────────────────────────────────────────────────────────
command -v flutter >/dev/null 2>&1 || die "Flutter not found. Run ./local-dev/install.sh first."
command -v node    >/dev/null 2>&1 || die "Node.js not found. Run ./local-dev/install.sh first."

banner

# ── detect hosted vs local Supabase ──────────────────────────────────────────
SUPABASE_URL="${SUPABASE_URL:-}"
SUPABASE_PUBLISHABLE_KEY="${SUPABASE_PUBLISHABLE_KEY:-}"

if [[ -n "$SUPABASE_URL" ]] && [[ "$SUPABASE_URL" == https://* ]]; then
  # ── HOSTED MODE ──────────────────────────────────────────────────────────
  echo ""
  echo -e "  ${GREEN}${BOLD}Mode: HOSTED Supabase${NC}"
  info "URL: $SUPABASE_URL"

  if [[ -z "$SUPABASE_PUBLISHABLE_KEY" ]] || [[ "$SUPABASE_PUBLISHABLE_KEY" == "PASTE_YOUR_ANON_KEY_HERE" ]]; then
    echo ""
    echo -e "${RED}${BOLD}✗  SUPABASE_PUBLISHABLE_KEY not set.${NC}"
    echo ""
    echo "  1. Go to: https://supabase.com/dashboard/project/rlcgtqagfdweisnxrasn/settings/api"
    echo "  2. Copy the 'anon public' key (starts with eyJ...)"
    echo "  3. Paste it in local-dev/.env:"
    echo "     SUPABASE_PUBLISHABLE_KEY=eyJ..."
    echo ""
    exit 1
  fi
  info "Anon key: ${SUPABASE_PUBLISHABLE_KEY:0:20}..."
  echo ""
else
  # ── LOCAL MODE ───────────────────────────────────────────────────────────
  echo ""
  echo -e "  ${CYAN}${BOLD}Mode: LOCAL Supabase (Docker)${NC}"

  if ! docker info >/dev/null 2>&1; then
    die "Docker is not running. Start Docker Desktop then retry, or set SUPABASE_URL=https://... in local-dev/.env to use hosted Supabase."
  fi

  USE_LOCAL_SUPABASE=true

  step "Starting local Supabase"
  npx supabase start
  npx supabase db push 2>/dev/null || warn "Migration push — DB may already be up to date."

  SUPABASE_URL="http://localhost:54321"
  SUPABASE_PUBLISHABLE_KEY=$(npx supabase status 2>/dev/null \
    | grep -E "publishable key" | awk '{print $NF}' | tr -d '[:space:]' || echo "")

  if [[ -z "$SUPABASE_PUBLISHABLE_KEY" ]]; then
    warn "Could not read publishable key — Flutter will use placeholder."
    SUPABASE_PUBLISHABLE_KEY="placeholder"
  fi

  info "Supabase Studio: http://localhost:54323"
  info "API:             $SUPABASE_URL"
fi

# ── install deps ──────────────────────────────────────────────────────────────
step "Installing dependencies"
cd "$REPO_ROOT/mobile" && flutter pub get 2>&1 | grep -E "Changed|up to date|Resolving" || true
if [[ "$TARGET" != "mobile-only" ]]; then
  cd "$REPO_ROOT/admin" && npm install --silent 2>/dev/null || npm install
fi
cd "$REPO_ROOT"

# ── Patch iOS URL scheme ──────────────────────────────────────────────────────
GOOGLE_WEB_CLIENT_ID="${GOOGLE_WEB_CLIENT_ID:-}"
GOOGLE_IOS_CLIENT_ID="${GOOGLE_IOS_CLIENT_ID:-}"
INFO_PLIST="$REPO_ROOT/mobile/ios/Runner/Info.plist"
if [[ "$TARGET" != "android" ]] && [[ -n "$GOOGLE_IOS_CLIENT_ID" ]]; then
  IOS_URL_SCHEME="com.googleusercontent.apps.${GOOGLE_IOS_CLIENT_ID%.apps.googleusercontent.com}"
  sed -i '' "s|GOOGLE_IOS_URL_SCHEME_PLACEHOLDER|$IOS_URL_SCHEME|g" "$INFO_PLIST"
  sed -i '' "s|com\.googleusercontent\.apps\.[^<]*|$IOS_URL_SCHEME|g" "$INFO_PLIST"
  info "Google iOS URL scheme: $IOS_URL_SCHEME"
fi

# ── iOS CocoaPods ─────────────────────────────────────────────────────────────
if [[ "$TARGET" != "android" ]] && command -v pod >/dev/null 2>&1; then
  step "Running pod install (iOS)"
  cd "$REPO_ROOT/mobile/ios"
  pod install --repo-update 2>&1 | grep -E "Installing|Updating|error:|warning:" || true
  cd "$REPO_ROOT"
fi

# ── ensure admin .env.local ───────────────────────────────────────────────────
if [[ "$TARGET" != "mobile-only" ]] && [[ ! -f admin/.env.local ]]; then
  cat > admin/.env.local << EOF
NEXT_PUBLIC_SUPABASE_URL=$SUPABASE_URL
NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY=$SUPABASE_PUBLISHABLE_KEY
SUPABASE_SERVICE_ROLE_KEY=placeholder
MUX_TOKEN_ID=placeholder
MUX_TOKEN_SECRET=placeholder
EOF
  warn "Created admin/.env.local — update SUPABASE_SERVICE_ROLE_KEY for admin queries."
fi

# ── start admin panel (background) ───────────────────────────────────────────
if [[ "$TARGET" != "mobile-only" ]]; then
  step "Starting Next.js admin panel (background)"
  cd "$REPO_ROOT/admin"
  npm run dev -- --port 3555 &>/tmp/mwf-admin.log &
  PIDS+=($!)
  info "Admin panel: http://localhost:3555  (logs: /tmp/mwf-admin.log)"
fi

# ── device discovery ──────────────────────────────────────────────────────────
find_ios_device() {
  local udid
  udid=$(xcrun simctl list devices available 2>/dev/null \
    | grep -E "iPhone" | grep "Booted" | head -1 | grep -oE '[A-F0-9-]{36}')
  if [[ -n "$udid" ]]; then echo "$udid"; return; fi
  xcrun simctl list devices available 2>/dev/null \
    | grep -E "iPhone" | grep -v "unavailable" | head -1 | grep -oE '[A-F0-9-]{36}'
}

find_android_device() {
  flutter emulators 2>/dev/null \
    | grep -E "android|pixel|nexus|galaxy" -i | awk '{print $1}' | head -1
}

# ── start Flutter app ─────────────────────────────────────────────────────────
if [[ "$TARGET" != "admin-only" ]]; then
  MOBILE_TARGET="ios"
  [[ "$TARGET" == "android" ]] && MOBILE_TARGET="android"

  step "Launching Flutter ($MOBILE_TARGET)"
  echo ""
  info "SUPABASE_URL:   $SUPABASE_URL"
  info "ANON KEY:       ${SUPABASE_PUBLISHABLE_KEY:0:20}..."
  [[ -z "$GOOGLE_WEB_CLIENT_ID" ]] && warn "GOOGLE_WEB_CLIENT_ID not set — Google Sign-In will fail."
  echo ""

  DEVICE_FLAG=""

  if [[ "$MOBILE_TARGET" == "ios" ]]; then
    IOS_UDID=$(find_ios_device)
    if [[ -n "$IOS_UDID" ]]; then
      DEVICE_NAME=$(xcrun simctl list devices available 2>/dev/null \
        | grep "$IOS_UDID" | sed 's/ (.*//; s/^[[:space:]]*//')
      info "Simulator: $DEVICE_NAME ($IOS_UDID)"
      xcrun simctl boot "$IOS_UDID" 2>/dev/null || true
      open -a Simulator 2>/dev/null || true
      sleep 2
      DEVICE_FLAG="-d $IOS_UDID"
    else
      warn "No iPhone simulator found — skipping Flutter launch."
    fi
  else
    ANDROID_ID=$(find_android_device)
    if [[ -n "$ANDROID_ID" ]]; then
      info "Emulator: $ANDROID_ID"
      flutter emulators --launch "$ANDROID_ID" 2>/dev/null || true
      sleep 5
      DEVICE_FLAG="-d $ANDROID_ID"
    else
      warn "No Android emulator found — skipping Flutter launch."
    fi
  fi

  if [[ -n "$DEVICE_FLAG" ]]; then
    cd "$REPO_ROOT/mobile"
    # shellcheck disable=SC2086
    flutter run $DEVICE_FLAG \
      --dart-define=SUPABASE_URL="$SUPABASE_URL" \
      --dart-define=SUPABASE_PUBLISHABLE_KEY="$SUPABASE_PUBLISHABLE_KEY" \
      --dart-define=GOOGLE_WEB_CLIENT_ID="$GOOGLE_WEB_CLIENT_ID" \
      --dart-define=GOOGLE_IOS_CLIENT_ID="$GOOGLE_IOS_CLIENT_ID" \
      --dart-define=GOOGLE_IOS_URL_SCHEME="${GOOGLE_IOS_CLIENT_ID:+com.googleusercontent.apps.${GOOGLE_IOS_CLIENT_ID%.apps.googleusercontent.com}}" &
    PIDS+=($!)
  fi
fi

# ── wait ─────────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}✓ Dev environment running. Press Ctrl+C to stop.${NC}"
echo ""

wait
