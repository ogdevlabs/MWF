#!/usr/bin/env bash
# run-mobile.sh — Install Flutter deps (if needed) and run the mobile app
#
# Usage:
#   ./local-dev/run-mobile.sh              — auto-discover best available device
#   ./local-dev/run-mobile.sh ios          — first available iPhone simulator
#   ./local-dev/run-mobile.sh android      — first available Android emulator
#   ./local-dev/run-mobile.sh list         — list all available devices
#   ./local-dev/run-mobile.sh <device-id>  — specific UDID or device ID

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

# Load local credentials (gitignored — never committed)
# shellcheck source=/dev/null
[[ -f "$REPO_ROOT/local-dev/.env" ]] && source "$REPO_ROOT/local-dev/.env"

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; CYAN='\033[0;36m'; NC='\033[0m'
step() { echo -e "\n${GREEN}▶ $*${NC}"; }
warn() { echo -e "${YELLOW}⚠  $*${NC}"; }
die()  { echo -e "${RED}✗  $*${NC}"; exit 1; }
info() { echo -e "${CYAN}   $*${NC}"; }

command -v flutter >/dev/null 2>&1 || die "Flutter not found. Run ./local-dev/install.sh first."

# ── device discovery ──────────────────────────────────────────────────────────

# Find first available iPhone simulator UDID (booted first, then shutdown)
find_ios_device() {
  # Prefer already-booted simulator
  local udid
  udid=$(xcrun simctl list devices available 2>/dev/null \
    | grep -E "iPhone" \
    | grep "Booted" \
    | head -1 \
    | grep -oE '[A-F0-9-]{36}')
  if [[ -n "$udid" ]]; then echo "$udid"; return; fi

  # Fall back to first available (shutdown) iPhone
  udid=$(xcrun simctl list devices available 2>/dev/null \
    | grep -E "iPhone" \
    | grep -v "unavailable" \
    | head -1 \
    | grep -oE '[A-F0-9-]{36}')
  echo "$udid"
}

# Find first available Android emulator ID
find_android_device() {
  flutter emulators 2>/dev/null \
    | grep -E "android|pixel|nexus|galaxy" -i \
    | awk '{print $1}' \
    | head -1
}

# ── resolve Supabase keys from running stack ──────────────────────────────────
SUPABASE_URL="${SUPABASE_URL:-http://localhost:54321}"
SUPABASE_ANON_KEY="${SUPABASE_ANON_KEY:-}"
GOOGLE_WEB_CLIENT_ID="${GOOGLE_WEB_CLIENT_ID:-}"
GOOGLE_IOS_CLIENT_ID="${GOOGLE_IOS_CLIENT_ID:-}"

if [[ -z "$SUPABASE_ANON_KEY" ]]; then
  STATUS_OUTPUT=$(npx supabase status 2>/dev/null || true)
  if [[ -n "$STATUS_OUTPUT" ]]; then
    SUPABASE_ANON_KEY=$(echo "$STATUS_OUTPUT" | grep -E "anon key" | awk '{print $NF}' | tr -d '[:space:]')
  fi
fi

if [[ -z "$SUPABASE_ANON_KEY" ]]; then
  warn "SUPABASE_ANON_KEY not set — Supabase calls will fail until Phase 2."
  warn "Fix: ./local-dev/supabase.sh start, then export SUPABASE_ANON_KEY=<key>"
  SUPABASE_ANON_KEY="placeholder"
fi

# ── ensure deps are installed ─────────────────────────────────────────────────
step "Checking Flutter dependencies"
cd "$REPO_ROOT/mobile"
if [[ ! -f pubspec.lock ]] || [[ pubspec.yaml -nt pubspec.lock ]]; then
  flutter pub get
else
  echo "  pubspec.lock up to date — skipping"
fi

# ── Patch iOS URL scheme in Info.plist ───────────────────────────────────────
# Info.plist must contain the reversed iOS client ID as a literal string —
# Xcode build setting variables ($(VAR)) are not populated by flutter run.
# We patch the placeholder before every launch so the scheme stays current.
TARGET_PEEK="${1:-ios}"
INFO_PLIST="$REPO_ROOT/mobile/ios/Runner/Info.plist"
if [[ "$TARGET_PEEK" != "android" ]] && [[ -n "$GOOGLE_IOS_CLIENT_ID" ]]; then
  # Reversed client ID: strip .apps.googleusercontent.com suffix
  IOS_URL_SCHEME="com.googleusercontent.apps.${GOOGLE_IOS_CLIENT_ID%.apps.googleusercontent.com}"
  # Replace placeholder OR any previously-set scheme — always idempotent
  sed -i '' "s|GOOGLE_IOS_URL_SCHEME_PLACEHOLDER|$IOS_URL_SCHEME|g" "$INFO_PLIST"
  sed -i '' "s|com\.googleusercontent\.apps\.[^<]*|$IOS_URL_SCHEME|g" "$INFO_PLIST"
  info "Google iOS URL scheme: $IOS_URL_SCHEME"
elif [[ "$TARGET_PEEK" != "android" ]]; then
  warn "GOOGLE_IOS_CLIENT_ID not set — Google Sign-In redirect will fail on iOS."
  warn "Set GOOGLE_IOS_CLIENT_ID in local-dev/.env"
fi

# ── iOS CocoaPods ─────────────────────────────────────────────────────────────
if [[ "$TARGET_PEEK" != "android" ]] && command -v pod >/dev/null 2>&1; then
  step "Running pod install (iOS)"
  cd "$REPO_ROOT/mobile/ios"
  pod install --repo-update 2>&1 | grep -E "Installing|Updating|error:|warning:" || true
  cd "$REPO_ROOT/mobile"
fi

# ── resolve target device ─────────────────────────────────────────────────────
TARGET="${1:-}"

case "$TARGET" in
  ios|"")
    step "Discovering iOS Simulator"
    IOS_UDID=$(find_ios_device)
    [[ -n "$IOS_UDID" ]] || die "No iPhone simulator found. Open Xcode → Simulator to create one."

    DEVICE_NAME=$(xcrun simctl list devices available 2>/dev/null \
      | grep "$IOS_UDID" | sed 's/ (.*//; s/^[[:space:]]*//')
    info "Using: $DEVICE_NAME ($IOS_UDID)"

    xcrun simctl boot "$IOS_UDID" 2>/dev/null || true  # no-op if already booted
    open -a Simulator 2>/dev/null || true
    sleep 2
    DEVICE_FLAG="-d $IOS_UDID"
    ;;

  android)
    step "Discovering Android Emulator"
    ANDROID_ID=$(find_android_device)
    [[ -n "$ANDROID_ID" ]] || die "No Android emulator found. Create one in Android Studio → AVD Manager."

    info "Using: $ANDROID_ID"
    flutter emulators --launch "$ANDROID_ID" 2>/dev/null || true
    sleep 5
    DEVICE_FLAG="-d $ANDROID_ID"
    ;;

  list)
    echo -e "\n${CYAN}Available devices:${NC}"
    flutter devices
    echo -e "\n${CYAN}Available emulators:${NC}"
    flutter emulators
    exit 0
    ;;

  *)
    # Explicit device ID passed
    DEVICE_FLAG="-d $TARGET"
    ;;
esac

# ── run ───────────────────────────────────────────────────────────────────────
[[ -z "$GOOGLE_WEB_CLIENT_ID" ]] && warn "GOOGLE_WEB_CLIENT_ID not set — Google Sign-In will show an error."
[[ -z "$GOOGLE_IOS_CLIENT_ID" ]] && warn "GOOGLE_IOS_CLIENT_ID not set — Google Sign-In will show an error."

echo ""
info "SUPABASE_URL:          $SUPABASE_URL"
info "GOOGLE_WEB_CLIENT_ID:  ${GOOGLE_WEB_CLIENT_ID:-not set}"
info "GOOGLE_IOS_CLIENT_ID:  ${GOOGLE_IOS_CLIENT_ID:-not set}"
echo ""

# shellcheck disable=SC2086
flutter run $DEVICE_FLAG \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY" \
  --dart-define=GOOGLE_WEB_CLIENT_ID="$GOOGLE_WEB_CLIENT_ID" \
  --dart-define=GOOGLE_IOS_CLIENT_ID="$GOOGLE_IOS_CLIENT_ID" \
  --dart-define=GOOGLE_IOS_URL_SCHEME="${GOOGLE_IOS_CLIENT_ID:+com.googleusercontent.apps.${GOOGLE_IOS_CLIENT_ID%.apps.googleusercontent.com}}"
