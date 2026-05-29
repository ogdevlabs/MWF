#!/usr/bin/env bash
# test-login.sh — Run the login integration test against the configured Supabase project.
#
# Reads credentials from local-dev/.env (SUPABASE_URL, SUPABASE_PUBLISHABLE_KEY,
# TEST_EMAIL, TEST_PASSWORD).
#
# Usage:
#   ./local-dev/test-login.sh            — run on first available iPhone simulator
#   ./local-dev/test-login.sh android    — run on Android emulator

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Load credentials
[[ -f "$REPO_ROOT/local-dev/.env" ]] && source "$REPO_ROOT/local-dev/.env"

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
die() { echo -e "${RED}✗  $*${NC}"; exit 1; }

SUPABASE_URL="${SUPABASE_URL:-}"
SUPABASE_PUBLISHABLE_KEY="${SUPABASE_PUBLISHABLE_KEY:-}"
TEST_EMAIL="${TEST_EMAIL:-}"
TEST_PASSWORD="${TEST_PASSWORD:-}"

[[ -z "$SUPABASE_URL" ]]               && die "SUPABASE_URL not set in local-dev/.env"
[[ -z "$SUPABASE_PUBLISHABLE_KEY" ]]   && die "SUPABASE_PUBLISHABLE_KEY not set in local-dev/.env"
[[ -z "$TEST_EMAIL" ]]                 && die "TEST_EMAIL not set in local-dev/.env"
[[ -z "$TEST_PASSWORD" ]]              && die "TEST_PASSWORD not set in local-dev/.env"

TARGET="${1:-ios}"

# Find device
DEVICE_FLAG=""
if [[ "$TARGET" == "android" ]]; then
  DEVICE_ID=$(flutter emulators 2>/dev/null \
    | grep -E "android|pixel|nexus|galaxy" -i | awk '{print $1}' | head -1)
  [[ -n "$DEVICE_ID" ]] && DEVICE_FLAG="-d $DEVICE_ID"
else
  DEVICE_ID=$(xcrun simctl list devices available 2>/dev/null \
    | grep -E "iPhone" | grep "Booted" | head -1 | grep -oE '[A-F0-9-]{36}' || \
    xcrun simctl list devices available 2>/dev/null \
    | grep -E "iPhone" | grep -v "unavailable" | head -1 | grep -oE '[A-F0-9-]{36}')
  if [[ -n "$DEVICE_ID" ]]; then
    xcrun simctl boot "$DEVICE_ID" 2>/dev/null || true
    DEVICE_FLAG="-d $DEVICE_ID"
  fi
fi

[[ -z "$DEVICE_FLAG" ]] && die "No device found. Boot a simulator or connect a device."

echo -e "\n${GREEN}▶ Running login integration test${NC}"
echo "  Supabase: $SUPABASE_URL"
echo "  Email:    $TEST_EMAIL"
echo ""

cd "$REPO_ROOT/mobile"

# shellcheck disable=SC2086
flutter test integration_test/auth_login_test.dart \
  $DEVICE_FLAG \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_PUBLISHABLE_KEY="$SUPABASE_PUBLISHABLE_KEY" \
  --dart-define=TEST_EMAIL="$TEST_EMAIL" \
  --dart-define=TEST_PASSWORD="$TEST_PASSWORD"
