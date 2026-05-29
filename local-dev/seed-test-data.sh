#!/usr/bin/env bash
# seed-test-data.sh — Seed Phase 7 test data against the hosted Supabase project.
#
# Creates two test users (premium + basic), a program with 3 sessions, enrolls
# the premium user, and pre-seeds coach replies so all PR #12 test plan steps
# can be exercised without any manual SQL.
#
# Usage:
#   ./local-dev/seed-test-data.sh
#   ./local-dev/seed-test-data.sh --reset    # drop and re-seed
#
# Required vars in local-dev/.env:
#   SUPABASE_URL                 e.g. https://rlcgtqagfdweisnxrasn.supabase.co
#   SUPABASE_SERVICE_ROLE_KEY    from Supabase dashboard → Settings → API
#
# Optional vars:
#   SEED_PREMIUM_EMAIL           default: premium@test.mwf
#   SEED_PREMIUM_PASSWORD        default: Test1234!
#   SEED_BASIC_EMAIL             default: basic@test.mwf
#   SEED_BASIC_PASSWORD          default: Test1234!

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
[[ -f "$REPO_ROOT/local-dev/.env" ]] && source "$REPO_ROOT/local-dev/.env"

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'
step() { echo -e "\n${GREEN}${BOLD}▶ $*${NC}"; }
info() { echo -e "${CYAN}   $*${NC}"; }
warn() { echo -e "${YELLOW}⚠  $*${NC}"; }
die()  { echo -e "${RED}✗  $*${NC}"; exit 1; }
ok()   { echo -e "${GREEN}   ✓ $*${NC}"; }

RESET="${1:-}"

# ── validate ──────────────────────────────────────────────────────────────────
[[ -z "${SUPABASE_URL:-}" ]]              && die "SUPABASE_URL not set in local-dev/.env"
[[ -z "${SUPABASE_SERVICE_ROLE_KEY:-}" ]] && die "SUPABASE_SERVICE_ROLE_KEY not set in local-dev/.env"
command -v curl >/dev/null 2>&1           || die "curl not found"

SUPABASE_URL="${SUPABASE_URL%/}"   # strip trailing slash
SERVICE_KEY="$SUPABASE_SERVICE_ROLE_KEY"
REST="$SUPABASE_URL/rest/v1"
AUTH="$SUPABASE_URL/auth/v1"

PREMIUM_EMAIL="${SEED_PREMIUM_EMAIL:-premium@test.mwf}"
PREMIUM_PASS="${SEED_PREMIUM_PASSWORD:-Test1234!}"
BASIC_EMAIL="${SEED_BASIC_EMAIL:-basic@test.mwf}"
BASIC_PASS="${SEED_BASIC_PASSWORD:-Test1234!}"

# Fixed UUIDs so seeding is idempotent
PROGRAM_ID="aaaaaaaa-0000-0000-0000-000000000001"
SESSION_1="bbbbbbbb-0000-0000-0000-000000000001"
SESSION_2="bbbbbbbb-0000-0000-0000-000000000002"
SESSION_3="bbbbbbbb-0000-0000-0000-000000000003"
SENTINEL_SESSION="00000000-0000-0000-0000-000000000000"

# ── helpers ───────────────────────────────────────────────────────────────────

# POST to Supabase REST API (service role — bypasses RLS)
sb_post() {
  local path="$1"; shift
  local body="$1"; shift
  local prefer="${1:-resolution=merge-duplicates}"
  curl -sf \
    -X POST \
    -H "apikey: $SERVICE_KEY" \
    -H "Authorization: Bearer $SERVICE_KEY" \
    -H "Content-Type: application/json" \
    -H "Prefer: $prefer" \
    "$REST/$path" \
    -d "$body" 2>&1 || true
}

# GET from Supabase REST API
sb_get() {
  local path="$1"
  curl -sf \
    -H "apikey: $SERVICE_KEY" \
    -H "Authorization: Bearer $SERVICE_KEY" \
    "$REST/$path" 2>&1
}

# Create auth user via Admin API, returns user id
create_auth_user() {
  local email="$1" password="$2"
  local response
  response=$(curl -sf \
    -X POST \
    -H "apikey: $SERVICE_KEY" \
    -H "Authorization: Bearer $SERVICE_KEY" \
    -H "Content-Type: application/json" \
    "$AUTH/admin/users" \
    -d "{\"email\": \"$email\", \"password\": \"$password\", \"email_confirm\": true}" 2>&1 || true)
  echo "$response" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4
}

# Get existing auth user id by email
get_auth_user_id() {
  local email="$1"
  local response
  response=$(curl -sf \
    -H "apikey: $SERVICE_KEY" \
    -H "Authorization: Bearer $SERVICE_KEY" \
    "$AUTH/admin/users?email=$email" 2>&1 || true)
  echo "$response" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4
}

# ── reset ─────────────────────────────────────────────────────────────────────
if [[ "$RESET" == "--reset" ]]; then
  step "Resetting seed data"
  warn "Deleting test users, program, and feedback from Supabase..."

  # Delete feedback threads for test users
  for email in "$PREMIUM_EMAIL" "$BASIC_EMAIL"; do
    uid=$(get_auth_user_id "$email")
    if [[ -n "$uid" ]]; then
      curl -sf -X DELETE \
        -H "apikey: $SERVICE_KEY" \
        -H "Authorization: Bearer $SERVICE_KEY" \
        "$REST/feedback_threads?student_id=eq.$uid" >/dev/null 2>&1 || true
      curl -sf -X DELETE \
        -H "apikey: $SERVICE_KEY" \
        -H "Authorization: Bearer $SERVICE_KEY" \
        "$REST/enrollments?student_id=eq.$uid" >/dev/null 2>&1 || true
      curl -sf -X DELETE \
        -H "apikey: $SERVICE_KEY" \
        -H "Authorization: Bearer $SERVICE_KEY" \
        "$REST/subscriptions?student_id=eq.$uid" >/dev/null 2>&1 || true
      curl -sf -X DELETE \
        -H "apikey: $SERVICE_KEY" \
        -H "Authorization: Bearer $SERVICE_KEY" \
        "$REST/students?id=eq.$uid" >/dev/null 2>&1 || true
      curl -sf -X DELETE \
        -H "apikey: $SERVICE_KEY" \
        -H "Authorization: Bearer $SERVICE_KEY" \
        "$AUTH/admin/users/$uid" >/dev/null 2>&1 || true
      ok "Deleted $email"
    fi
  done

  # Delete program (cascades to sessions, exercises, enrollments)
  curl -sf -X DELETE \
    -H "apikey: $SERVICE_KEY" \
    -H "Authorization: Bearer $SERVICE_KEY" \
    "$REST/programs?id=eq.$PROGRAM_ID" >/dev/null 2>&1 || true
  ok "Deleted test program"

  info "Reset complete. Re-run without --reset to seed fresh data."
  exit 0
fi

echo ""
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}  MWF Phase 7 Test Data Seed${NC}"
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
info "Target: $SUPABASE_URL"

# ── 1. create auth users ──────────────────────────────────────────────────────
step "1/6  Creating auth users"

PREMIUM_UID=$(get_auth_user_id "$PREMIUM_EMAIL")
if [[ -z "$PREMIUM_UID" ]]; then
  PREMIUM_UID=$(create_auth_user "$PREMIUM_EMAIL" "$PREMIUM_PASS")
  ok "Created premium user ($PREMIUM_EMAIL)"
else
  ok "Premium user already exists ($PREMIUM_EMAIL)"
fi
[[ -z "$PREMIUM_UID" ]] && die "Failed to create/find premium user"

BASIC_UID=$(get_auth_user_id "$BASIC_EMAIL")
if [[ -z "$BASIC_UID" ]]; then
  BASIC_UID=$(create_auth_user "$BASIC_EMAIL" "$BASIC_PASS")
  ok "Created basic user ($BASIC_EMAIL)"
else
  ok "Basic user already exists ($BASIC_EMAIL)"
fi
[[ -z "$BASIC_UID" ]] && die "Failed to create/find basic user"

info "Premium UID: $PREMIUM_UID"
info "Basic UID:   $BASIC_UID"

# ── 2. insert students rows ───────────────────────────────────────────────────
step "2/6  Inserting students rows"

sb_post "students" "[
  {\"id\": \"$PREMIUM_UID\", \"email\": \"$PREMIUM_EMAIL\", \"display_name\": \"Premium Tester\", \"timezone\": \"America/Los_Angeles\"},
  {\"id\": \"$BASIC_UID\",   \"email\": \"$BASIC_EMAIL\",   \"display_name\": \"Basic Tester\",   \"timezone\": \"America/Los_Angeles\"}
]" > /dev/null
ok "Students rows upserted"

# ── 3. grant premium subscription ────────────────────────────────────────────
step "3/6  Granting premium subscription"

sb_post "subscriptions" "[{
  \"student_id\": \"$PREMIUM_UID\",
  \"revenuecat_customer_id\": \"rc_seed_premium_001\",
  \"plan_id\": \"premium_monthly\",
  \"status\": \"active\",
  \"store\": \"app_store\"
}]" > /dev/null
ok "Subscription granted to $PREMIUM_EMAIL"

# ── 4. program + sessions + exercises ────────────────────────────────────────
step "4/6  Seeding program, sessions, exercises"

sb_post "programs" "[{
  \"id\": \"$PROGRAM_ID\",
  \"title\": \"Core Foundations\",
  \"description\": \"A beginner 4-week mat Pilates program.\",
  \"difficulty\": \"beginner\",
  \"duration_weeks\": 4,
  \"published\": true,
  \"published_at\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"
}]" > /dev/null
ok "Program: Core Foundations"

sb_post "sessions" "[
  {\"id\": \"$SESSION_1\", \"program_id\": \"$PROGRAM_ID\", \"day_number\": 1, \"title\": \"Foundation Flow\"},
  {\"id\": \"$SESSION_2\", \"program_id\": \"$PROGRAM_ID\", \"day_number\": 2, \"title\": \"Breath and Core\"},
  {\"id\": \"$SESSION_3\", \"program_id\": \"$PROGRAM_ID\", \"day_number\": 3, \"title\": \"Spinal Mobility\"}
]" > /dev/null
ok "Sessions: Day 1, 2, 3"

sb_post "exercises" "[
  {\"session_id\": \"$SESSION_1\", \"display_order\": 1, \"title\": \"Hundred Prep\",        \"rep_count\": 10},
  {\"session_id\": \"$SESSION_1\", \"display_order\": 2, \"title\": \"Roll Up\",              \"rep_count\": 8},
  {\"session_id\": \"$SESSION_2\", \"display_order\": 1, \"title\": \"Single Leg Stretch\",   \"rep_count\": 10},
  {\"session_id\": \"$SESSION_2\", \"display_order\": 2, \"title\": \"Double Leg Stretch\",   \"rep_count\": 8},
  {\"session_id\": \"$SESSION_3\", \"display_order\": 1, \"title\": \"Spine Stretch Forward\",\"rep_count\": 8},
  {\"session_id\": \"$SESSION_3\", \"display_order\": 2, \"title\": \"Swan Prep\",            \"rep_count\": 6}
]" > /dev/null
ok "Exercises seeded (2 per session)"

# ── 5. enroll premium user ────────────────────────────────────────────────────
step "5/6  Enrolling premium user"

sb_post "enrollments" "[{
  \"student_id\": \"$PREMIUM_UID\",
  \"program_id\": \"$PROGRAM_ID\",
  \"current_day\": 1
}]" > /dev/null
ok "$PREMIUM_EMAIL enrolled in Core Foundations"

# ── 6. pre-seed feedback threads with coach replies ───────────────────────────
step "6/6  Seeding feedback threads with coach replies"

NOW="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

# Free-form DM (from compose bar) — uses sentinel session_id
sb_post "feedback_threads" "[{
  \"student_id\": \"$PREMIUM_UID\",
  \"session_id\": \"$SENTINEL_SESSION\",
  \"student_message\": \"Felt strong today but my left hip is still tight.\",
  \"coach_reply\": \"Great work! Try adding the hip flexor stretch after your next session — hold for 30 seconds each side.\",
  \"replied_at\": \"$NOW\",
  \"notification_sent\": true
}]" > /dev/null
ok "Free-form DM thread (sentinel session)"

# Session-linked feedback from Day 1
sb_post "feedback_threads" "[{
  \"student_id\": \"$PREMIUM_UID\",
  \"session_id\": \"$SESSION_1\",
  \"student_message\": \"Completed Day 1! The Hundred Prep was harder than I expected.\",
  \"coach_reply\": \"Well done on Day 1! Keep your chin slightly tucked and breathe into the sides of your ribcage.\",
  \"replied_at\": \"$NOW\",
  \"notification_sent\": true
}]" > /dev/null
ok "Session-linked thread (Day 1 — Foundation Flow)"

# ── summary ───────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}✓ Test data seeded successfully.${NC}"
echo ""
echo -e "${BOLD}Test credentials:${NC}"
echo ""
echo "  Premium student (Coach tab + chat):"
echo "    Email:    $PREMIUM_EMAIL"
echo "    Password: $PREMIUM_PASS"
echo ""
echo "  Basic student (paywall):"
echo "    Email:    $BASIC_EMAIL"
echo "    Password: $BASIC_PASS"
echo ""
echo -e "${BOLD}Seeded:${NC}"
echo "  ✓ Program: Core Foundations (3 sessions, 6 exercises)"
echo "  ✓ Enrollment: premium user in Core Foundations"
echo "  ✓ Subscription: premium_monthly active"
echo "  ✓ Feedback thread: free-form DM with coach reply"
echo "  ✓ Feedback thread: Day 1 session-linked with coach reply"
echo ""
echo -e "${CYAN}  Notifications tab will show 2 coach replies.${NC}"
echo -e "${CYAN}  To reset and re-seed: ./local-dev/seed-test-data.sh --reset${NC}"
echo ""
