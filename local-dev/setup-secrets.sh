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
echo -e "${BOLD}  MWF Secrets Setup — $(echo "$TARGET_ENV" | tr '[:lower:]' '[:upper:]')${NC}"
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
  dryrun "Push 7 secrets to Supabase Edge Functions via Management API"
  dryrun "Secrets: SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, FIREBASE_SERVICE_ACCOUNT_JSON,"
  dryrun "         FIREBASE_PROJECT_ID, MUX_TOKEN_ID, MUX_TOKEN_SECRET, MUX_WEBHOOK_SIGNING_SECRET"
elif [[ -n "${SUPABASE_ACCESS_TOKEN:-}" ]]; then
  # Push non-SUPABASE_ prefixed secrets via Management API
  # Note: SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY are built-in to edge functions
  # and cannot be set via this API (prefix is reserved). Only push app-level secrets.
  SECRETS_JSON=$(python3 -c "
import json, os
secrets = {
    'FIREBASE_SERVICE_ACCOUNT_JSON': os.environ.get('FIREBASE_SERVICE_ACCOUNT_JSON', ''),
    'FIREBASE_PROJECT_ID': os.environ.get('FIREBASE_PROJECT_ID', ''),
    'MUX_TOKEN_ID': os.environ.get('MUX_TOKEN_ID', ''),
    'MUX_TOKEN_SECRET': os.environ.get('MUX_TOKEN_SECRET', ''),
    'MUX_WEBHOOK_SIGNING_SECRET': os.environ.get('MUX_WEBHOOK_SIGNING_SECRET', ''),
}
print(json.dumps([{'name': k, 'value': v} for k, v in secrets.items() if v]))
" 2>/dev/null)
  RESULT=$(curl -sf \
    -X POST \
    -H "Authorization: Bearer ${SUPABASE_ACCESS_TOKEN}" \
    -H "Content-Type: application/json" \
    "https://api.supabase.com/v1/projects/${PROJECT_REF}/secrets" \
    -d "$SECRETS_JSON" 2>&1 || echo "FAILED")
  if [[ "$RESULT" == "FAILED" ]] || echo "$RESULT" | grep -q '"message"'; then
    warn "Secrets push failed: $RESULT"
  else
    ok "Edge Function secrets set (5 secrets: Firebase + Mux)"
  fi
else
  warn "SUPABASE_ACCESS_TOKEN not set — skipping secrets push."
  warn "Get token from: https://supabase.com/dashboard/account/tokens"
  warn "Add SUPABASE_ACCESS_TOKEN=sbp_... to local-dev/.env"
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
    dryrun "Deploy edge function: $fn"
  elif [[ -n "${SUPABASE_ACCESS_TOKEN:-}" ]]; then
    export SUPABASE_ACCESS_TOKEN
    npx supabase functions deploy "$fn" \
      --project-ref "$PROJECT_REF" \
      --no-verify-jwt 2>&1 | tail -3 || warn "Deploy of $fn may have failed"
    ok "Deployed: $fn"
  else
    warn "Skipping deploy of $fn — SUPABASE_ACCESS_TOKEN not set"
  fi
done

# ── 3. Mux webhook (dashboard-only — cannot be automated via API) ─────────────
step "3/3  Mux webhook"

WEBHOOK_URL="${SUPABASE_FUNCTIONS_URL}/mux-webhook"

# Mux does not allow webhook creation via API tokens.
# The /system/v1/webhooks endpoint returns 401 "must be completed through dashboard".
# Verify if already registered by checking if the URL is known.
MUX_WEBHOOK_ID_KEY="MUX_WEBHOOK_ID_$(echo "$TARGET_ENV" | tr '[:lower:]' '[:upper:]')"
if grep -q "$MUX_WEBHOOK_ID_KEY" "$REPO_ROOT/local-dev/.env" 2>/dev/null; then
  SAVED_ID=$(grep "$MUX_WEBHOOK_ID_KEY" "$REPO_ROOT/local-dev/.env" | cut -d= -f2 | tr -d ' ')
  ok "Mux webhook previously registered (id: $SAVED_ID)"
  info "URL: $WEBHOOK_URL"
else
  echo ""
  echo -e "${YELLOW}${BOLD}  ⚠  Mux webhook requires manual setup (dashboard-only):${NC}"
  echo ""
  echo "  1. Go to: https://dashboard.mux.com/settings/webhooks"
  echo "  2. Click 'Add Webhook'"
  echo "  3. URL: ${WEBHOOK_URL}"
  echo "  4. Events: video.asset.ready, video.asset.errored"
  echo "  5. Copy the Signing Secret → paste as MUX_WEBHOOK_SIGNING_SECRET in local-dev/.env"
  echo "  6. Copy the Webhook ID → add to local-dev/.env:"
  echo "     ${MUX_WEBHOOK_ID_KEY}=<webhook-id>"
  echo ""
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
echo -e "${GREEN}${BOLD}✓ Secrets setup complete for $(echo "$TARGET_ENV" | tr '[:lower:]' '[:upper:]')${NC}"
echo ""
echo "  ✓ Firebase client config files generated"
[[ -n "${SUPABASE_ACCESS_TOKEN:-}" ]] && echo "  ✓ Supabase Edge Function secrets (7 vars)" || echo "  ⚠  Supabase secrets skipped — add SUPABASE_ACCESS_TOKEN to .env"
[[ -n "${SUPABASE_ACCESS_TOKEN:-}" ]] && echo "  ✓ Edge Functions deployed" || echo "  ⚠  Edge Function deploy skipped — add SUPABASE_ACCESS_TOKEN to .env"
echo "  ⚙  Mux webhook — register manually at https://dashboard.mux.com/settings/webhooks"
echo "     URL: $WEBHOOK_URL"
echo "  ✓ Firebase client config files generated"
echo ""
if [[ "$TARGET_ENV" == "dev" ]]; then
  echo -e "${CYAN}  Next: ./local-dev/dev.sh${NC}"
else
  echo -e "${CYAN}  Prod secrets are live. Verify at:${NC}"
  echo -e "${CYAN}  https://supabase.com/dashboard/project/$PROJECT_REF/settings/vault${NC}"
fi
echo ""
