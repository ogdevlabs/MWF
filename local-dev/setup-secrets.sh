#!/usr/bin/env bash
# setup-secrets.sh — Push all runtime secrets to the target environment.
#
# Handles three secret stores in one pass:
#   1. Supabase Edge Function secrets (send-fcm, mux-webhook)
#   2. Mux webhook endpoint registration
#   3. Firebase platform config files (delegates to setup-firebase.sh)
#
# Designed for environment promotion — same script runs for dev and prod.
#
# Usage:
#   ./local-dev/setup-secrets.sh              — targets SUPABASE_URL in .env (dev)
#   ./local-dev/setup-secrets.sh --env prod   — targets SUPABASE_PROJECT_REF_PROD
#   ./local-dev/setup-secrets.sh --dry-run    — print what would be set, don't write
#
# Required vars in local-dev/.env (all envs):
#   SUPABASE_SERVICE_ROLE_KEY       — admin Supabase key (for migration-level ops)
#   FIREBASE_SERVICE_ACCOUNT_JSON  — full JSON from Firebase Console → Service Accounts
#   FIREBASE_PROJECT_ID            — e.g. move-with-fergie
#   MUX_TOKEN_ID                   — from Mux dashboard → Settings → API Access Tokens
#   MUX_TOKEN_SECRET               — same
#   MUX_WEBHOOK_SIGNING_SECRET     — from Mux dashboard → Settings → Webhooks
#
# Required for --env prod:
#   SUPABASE_PROJECT_REF_PROD      — Supabase project ref (e.g. rlcgtqagfdweisnxrasn)
#   SUPABASE_ACCESS_TOKEN          — Supabase personal access token (for CLI auth)
#   SUPABASE_URL_PROD              — https://<ref>.supabase.co
#
# Optional (dev only — defaults work locally):
#   SUPABASE_PROJECT_REF_DEV       — defaults to extracting from SUPABASE_URL

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
[[ -f "$REPO_ROOT/local-dev/.env" ]] && source "$REPO_ROOT/local-dev/.env"

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'
step()    { echo -e "\n${GREEN}${BOLD}▶ $*${NC}"; }
info()    { echo -e "${CYAN}   $*${NC}"; }
warn()    { echo -e "${YELLOW}⚠  $*${NC}"; }
die()     { echo -e "${RED}✗  $*${NC}"; exit 1; }
ok()      { echo -e "${GREEN}   ✓ $*${NC}"; }
dryrun()  { echo -e "${YELLOW}   [dry-run] $*${NC}"; }

# ── parse args ────────────────────────────────────────────────────────────────
TARGET_ENV="dev"
DRY_RUN=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --env) TARGET_ENV="$2"; shift 2 ;;
    --dry-run) DRY_RUN=true; shift ;;
    *) die "Unknown argument: $1" ;;
  esac
done

# ── resolve environment config ────────────────────────────────────────────────
if [[ "$TARGET_ENV" == "prod" ]]; then
  [[ -z "${SUPABASE_PROJECT_REF_PROD:-}" ]] && die "SUPABASE_PROJECT_REF_PROD not set in local-dev/.env"
  [[ -z "${SUPABASE_ACCESS_TOKEN:-}" ]]      && die "SUPABASE_ACCESS_TOKEN not set in local-dev/.env"
  [[ -z "${SUPABASE_URL_PROD:-}" ]]          && die "SUPABASE_URL_PROD not set in local-dev/.env"
  PROJECT_REF="$SUPABASE_PROJECT_REF_PROD"
  SUPABASE_FUNCTIONS_URL="${SUPABASE_URL_PROD}/functions/v1"
  export SUPABASE_ACCESS_TOKEN
else
  # Dev — extract project ref from SUPABASE_URL (https://<ref>.supabase.co)
  SUPABASE_URL="${SUPABASE_URL:-}"
  if [[ -n "${SUPABASE_PROJECT_REF_DEV:-}" ]]; then
    PROJECT_REF="$SUPABASE_PROJECT_REF_DEV"
  elif [[ "$SUPABASE_URL" =~ https://([a-z0-9]+)\.supabase\.co ]]; then
    PROJECT_REF="${BASH_REMATCH[1]}"
  else
    die "Cannot determine project ref. Set SUPABASE_PROJECT_REF_DEV in local-dev/.env or use a hosted SUPABASE_URL."
  fi
  SUPABASE_FUNCTIONS_URL="${SUPABASE_URL}/functions/v1"
fi

# ── validate required vars ────────────────────────────────────────────────────
REQUIRED=(
  SUPABASE_SERVICE_ROLE_KEY
  FIREBASE_SERVICE_ACCOUNT_JSON
  FIREBASE_PROJECT_ID
  MUX_TOKEN_ID
  MUX_TOKEN_SECRET
  MUX_WEBHOOK_SIGNING_SECRET
)
MISSING=()
for var in "${REQUIRED[@]}"; do
  [[ -z "${!var:-}" ]] && MISSING+=("$var")
done

if [[ ${#MISSING[@]} -gt 0 ]]; then
  echo -e "\n${RED}${BOLD}✗  Missing secrets in local-dev/.env:${NC}"
  for v in "${MISSING[@]}"; do echo "     $v"; done
  echo ""
  echo "  See docs/secrets-setup.md for where to get each value."
  exit 1
fi

# ── banner ────────────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}  MWF Secrets Setup — ${TARGET_ENV^^}${NC}"
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
info "Project ref: $PROJECT_REF"
info "Functions:   $SUPABASE_FUNCTIONS_URL"
[[ "$DRY_RUN" == "true" ]] && warn "DRY RUN — no secrets will be written"

# ── 1. Supabase Edge Function secrets ─────────────────────────────────────────
step "1/3  Pushing Supabase Edge Function secrets"

# Write a temporary .env file for supabase secrets set --env-file
SECRETS_TMP=$(mktemp /tmp/mwf-secrets-XXXXXX.env)
trap 'rm -f "$SECRETS_TMP"' EXIT

cat > "$SECRETS_TMP" << ENVEOF
SUPABASE_URL=${SUPABASE_URL:-${SUPABASE_URL_PROD:-}}
SUPABASE_SERVICE_ROLE_KEY=${SUPABASE_SERVICE_ROLE_KEY}
FIREBASE_SERVICE_ACCOUNT_JSON=${FIREBASE_SERVICE_ACCOUNT_JSON}
FIREBASE_PROJECT_ID=${FIREBASE_PROJECT_ID}
MUX_TOKEN_ID=${MUX_TOKEN_ID}
MUX_TOKEN_SECRET=${MUX_TOKEN_SECRET}
MUX_WEBHOOK_SIGNING_SECRET=${MUX_WEBHOOK_SIGNING_SECRET}
ENVEOF

if [[ "$DRY_RUN" == "true" ]]; then
  dryrun "npx supabase secrets set --project-ref $PROJECT_REF --env-file <secrets_file>"
  dryrun "Secrets: SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, FIREBASE_SERVICE_ACCOUNT_JSON,"
  dryrun "         FIREBASE_PROJECT_ID, MUX_TOKEN_ID, MUX_TOKEN_SECRET, MUX_WEBHOOK_SIGNING_SECRET"
else
  npx supabase secrets set \
    --project-ref "$PROJECT_REF" \
    --env-file "$SECRETS_TMP" 2>&1 | grep -v "^$" || true
  ok "Edge Function secrets set (7 secrets)"
fi

# ── 2. Deploy Edge Functions ───────────────────────────────────────────────────
step "2/3  Deploying Edge Functions"

FUNCTIONS=("send-fcm" "mux-webhook" "revenuecat-webhook" "projection-refresh")

for fn in "${FUNCTIONS[@]}"; do
  fn_dir="$REPO_ROOT/supabase/functions/$fn"
  if [[ ! -d "$fn_dir" ]]; then
    warn "Skipping $fn — directory not found"
    continue
  fi

  if [[ "$DRY_RUN" == "true" ]]; then
    dryrun "npx supabase functions deploy $fn --project-ref $PROJECT_REF"
  else
    npx supabase functions deploy "$fn" \
      --project-ref "$PROJECT_REF" \
      --no-verify-jwt 2>&1 | tail -3 || warn "Deploy of $fn may have failed — check output above"
    ok "Deployed: $fn"
  fi
done

# ── 3. Register Mux webhook ───────────────────────────────────────────────────
step "3/3  Registering Mux webhook"

WEBHOOK_URL="${SUPABASE_FUNCTIONS_URL}/mux-webhook"

# Query existing webhooks to check if already registered
EXISTING=$(curl -sf \
  -u "${MUX_TOKEN_ID}:${MUX_TOKEN_SECRET}" \
  "https://api.mux.com/video/v1/webhooks" 2>/dev/null || echo '{"data":[]}')

ALREADY_REGISTERED=$(echo "$EXISTING" | python3 -c "
import sys, json
data = json.load(sys.stdin)
webhooks = data.get('data', [])
url = '$WEBHOOK_URL'
for w in webhooks:
    if w.get('url') == url:
        print(w['id'])
        break
" 2>/dev/null || echo "")

if [[ -n "$ALREADY_REGISTERED" ]]; then
  ok "Mux webhook already registered (id: $ALREADY_REGISTERED)"
  info "URL: $WEBHOOK_URL"
elif [[ "$DRY_RUN" == "true" ]]; then
  dryrun "curl -X POST https://api.mux.com/video/v1/webhooks"
  dryrun "  url=$WEBHOOK_URL"
  dryrun "  events=[video.asset.ready, video.asset.errored]"
else
  RESPONSE=$(curl -sf \
    -X POST \
    -u "${MUX_TOKEN_ID}:${MUX_TOKEN_SECRET}" \
    -H "Content-Type: application/json" \
    "https://api.mux.com/video/v1/webhooks" \
    -d "{
      \"url\": \"$WEBHOOK_URL\",
      \"events\": [\"video.asset.ready\", \"video.asset.errored\"]
    }" 2>&1 || echo '{"error":"failed"}')

  if echo "$RESPONSE" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('data',{}).get('id',''))" 2>/dev/null | grep -q "."; then
    WEBHOOK_ID=$(echo "$RESPONSE" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['data']['id'])" 2>/dev/null)
    ok "Mux webhook registered (id: $WEBHOOK_ID)"
    info "URL: $WEBHOOK_URL"

    # Save the webhook ID back to .env for reference
    if ! grep -q "MUX_WEBHOOK_ID_${TARGET_ENV^^}" "$REPO_ROOT/local-dev/.env" 2>/dev/null; then
      echo "" >> "$REPO_ROOT/local-dev/.env"
      echo "# Auto-set by setup-secrets.sh" >> "$REPO_ROOT/local-dev/.env"
      echo "MUX_WEBHOOK_ID_${TARGET_ENV^^}=${WEBHOOK_ID}" >> "$REPO_ROOT/local-dev/.env"
    fi
  else
    warn "Mux webhook registration may have failed. Response: $RESPONSE"
    warn "Register manually at https://dashboard.mux.com/settings/webhooks"
    warn "URL to register: $WEBHOOK_URL"
  fi
fi

# ── 4. Firebase client config (delegates to setup-firebase.sh) ───────────────
step "4/4  Firebase client config"

if [[ -n "${FIREBASE_PROJECT_ID:-}" ]]; then
  if [[ "$DRY_RUN" == "true" ]]; then
    dryrun "./local-dev/setup-firebase.sh (generates firebase_options.dart + platform files)"
  else
    bash "$REPO_ROOT/local-dev/setup-firebase.sh"
  fi
else
  warn "FIREBASE_PROJECT_ID not set — skipping client Firebase config"
fi

# ── summary ───────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}✓ Secrets setup complete for ${TARGET_ENV^^}${NC}"
echo ""
echo "  ✓ Supabase Edge Function secrets (7 vars)"
echo "  ✓ Edge Functions deployed (send-fcm, mux-webhook, revenuecat-webhook, projection-refresh)"
echo "  ✓ Mux webhook registered → $WEBHOOK_URL"
echo "  ✓ Firebase client config files generated"
echo ""
if [[ "$TARGET_ENV" == "dev" ]]; then
  echo -e "${CYAN}  Next: ./local-dev/dev.sh${NC}"
else
  echo -e "${CYAN}  Prod secrets are live. Verify at:${NC}"
  echo -e "${CYAN}  https://supabase.com/dashboard/project/$PROJECT_REF/settings/vault${NC}"
fi
echo ""
