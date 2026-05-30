#!/usr/bin/env bash
# setup-supabase.sh — Link project, push all migrations, verify storage buckets.
#
# Run this once on a fresh checkout or when the database needs re-initialising.
# Idempotent — safe to run multiple times.
#
# Usage:
#   ./local-dev/setup-supabase.sh
#
# Required vars in local-dev/.env:
#   SUPABASE_URL              — https://<ref>.supabase.co
#   SUPABASE_SERVICE_ROLE_KEY — service_role key
#   SUPABASE_ACCESS_TOKEN     — personal access token (supabase.com → Account → Tokens)
#   SUPABASE_DB_PASSWORD      — database password (Supabase dashboard → Settings → Database)

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
[[ -f "$REPO_ROOT/local-dev/.env" ]] && source "$REPO_ROOT/local-dev/.env"

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'
step() { echo -e "\n${GREEN}${BOLD}▶ $*${NC}"; }
info() { echo -e "${CYAN}   $*${NC}"; }
warn() { echo -e "${YELLOW}⚠  $*${NC}"; }
die()  { echo -e "${RED}✗  $*${NC}"; exit 1; }
ok()   { echo -e "${GREEN}   ✓ $*${NC}"; }

[[ -z "${SUPABASE_URL:-}"              ]] && die "SUPABASE_URL not set in local-dev/.env"
[[ -z "${SUPABASE_SERVICE_ROLE_KEY:-}" ]] && die "SUPABASE_SERVICE_ROLE_KEY not set in local-dev/.env"
[[ -z "${SUPABASE_ACCESS_TOKEN:-}"     ]] && die "SUPABASE_ACCESS_TOKEN not set in local-dev/.env"

# Extract project ref from URL
if [[ "$SUPABASE_URL" =~ https://([a-z0-9]+)\.supabase\.co ]]; then
  PROJECT_REF="${BASH_REMATCH[1]}"
else
  die "Cannot extract project ref from SUPABASE_URL: $SUPABASE_URL"
fi

export SUPABASE_ACCESS_TOKEN

echo ""
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}  MWF Supabase Setup${NC}"
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
info "Project: $PROJECT_REF"
info "URL:     $SUPABASE_URL"
cd "$REPO_ROOT"

# ── 1. Link project ───────────────────────────────────────────────────────────
step "1/4  Linking Supabase project"
npx supabase link --project-ref "$PROJECT_REF" 2>&1 | tail -2
ok "Linked to $PROJECT_REF"

# ── 2. Push migrations ────────────────────────────────────────────────────────
step "2/4  Pushing database migrations"

if [[ -z "${SUPABASE_DB_PASSWORD:-}" ]]; then
  warn "SUPABASE_DB_PASSWORD not set — migrations may require it."
  warn "Find it at: Supabase dashboard → Settings → Database → Database password"
  warn "Add SUPABASE_DB_PASSWORD=... to local-dev/.env"
  warn "Skipping migration push."
else
  npx supabase db push --password "$SUPABASE_DB_PASSWORD" 2>&1 | tail -5
  ok "Migrations applied"
fi

# ── 3. Verify / create storage buckets ───────────────────────────────────────
step "3/4  Verifying storage buckets"

EXISTING_BUCKETS=$(curl -sf \
  -H "apikey: $SUPABASE_SERVICE_ROLE_KEY" \
  -H "Authorization: Bearer $SUPABASE_SERVICE_ROLE_KEY" \
  "$SUPABASE_URL/storage/v1/bucket" 2>/dev/null | python3 -c "
import sys, json
print(' '.join(b['id'] for b in json.load(sys.stdin)))
" 2>/dev/null || echo "")

ensure_bucket() {
  local bucket="$1" is_public="$2"
  if echo "$EXISTING_BUCKETS" | tr ' ' '\n' | grep -qx "$bucket"; then
    ok "Bucket exists: $bucket (public: $is_public)"
  else
    RESULT=$(curl -sf \
      -X POST \
      -H "apikey: $SUPABASE_SERVICE_ROLE_KEY" \
      -H "Authorization: Bearer $SUPABASE_SERVICE_ROLE_KEY" \
      -H "Content-Type: application/json" \
      "$SUPABASE_URL/storage/v1/bucket" \
      -d "{\"id\": \"$bucket\", \"name\": \"$bucket\", \"public\": $is_public}" 2>&1 || echo "FAILED")
    if echo "$RESULT" | grep -q '"name"'; then
      ok "Created bucket: $bucket (public: $is_public)"
    else
      warn "Failed to create $bucket: $RESULT"
    fi
  fi
}

ensure_bucket "feedback-photos"    "false"
ensure_bucket "program-assets"     "false"
ensure_bucket "exercise-models"    "true"
ensure_bucket "program-thumbnails" "true"

# ── 4. Write admin/.env.local ─────────────────────────────────────────────────
step "4/4  Writing admin/.env.local"

cat > "$REPO_ROOT/admin/.env.local" << ENVEOF
NEXT_PUBLIC_SUPABASE_URL=${SUPABASE_URL}
NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY=${SUPABASE_PUBLISHABLE_KEY:-}
SUPABASE_SERVICE_ROLE_KEY=${SUPABASE_SERVICE_ROLE_KEY}
MUX_TOKEN_ID=${MUX_TOKEN_ID:-placeholder}
MUX_TOKEN_SECRET=${MUX_TOKEN_SECRET:-placeholder}
ENVEOF

ok "admin/.env.local written"

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}✓ Supabase setup complete${NC}"
echo ""
echo "  ✓ Project linked: $PROJECT_REF"
[[ -n "${SUPABASE_DB_PASSWORD:-}" ]] && echo "  ✓ Migrations pushed" || echo "  ⚠  Migrations skipped (add SUPABASE_DB_PASSWORD to .env)"
echo "  ✓ Storage buckets: feedback-photos, program-assets, exercise-models, program-thumbnails"
echo "  ✓ admin/.env.local written"
echo ""
info "Next: ./local-dev/setup-secrets.sh  (push FCM/Mux secrets + deploy edge functions)"
info "Then: ./local-dev/seed-test-data.sh  (create test users + sample data)"
info "Then: ./local-dev/dev.sh             (start the app)"
echo ""
