#!/usr/bin/env bash
# run-admin.sh — Install npm deps (if needed) and run the Next.js admin panel

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

# Load local credentials (gitignored — never committed)
# shellcheck source=/dev/null
[[ -f "$REPO_ROOT/local-dev/.env" ]] && source "$REPO_ROOT/local-dev/.env"

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
step() { echo -e "\n${GREEN}▶ $*${NC}"; }
warn() { echo -e "${YELLOW}⚠  $*${NC}"; }
die()  { echo -e "${RED}✗  $*${NC}"; exit 1; }

command -v node >/dev/null 2>&1 || die "Node.js not found. Run ./local-dev/install.sh first."

# ── check .env.local ──────────────────────────────────────────────────────────
step "Checking environment"
cd "$REPO_ROOT/admin"

if [[ ! -f .env.local ]]; then
  if [[ -f .env.local.example ]]; then
    cp .env.local.example .env.local
  else
    cat > .env.local << EOF
NEXT_PUBLIC_SUPABASE_URL=http://localhost:54321
NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY=placeholder
SUPABASE_SERVICE_ROLE_KEY=placeholder
MUX_TOKEN_ID=placeholder
MUX_TOKEN_SECRET=placeholder
EOF
  fi
  warn ".env.local created — fill in Supabase keys before using the admin panel."
fi

# ── ensure deps ───────────────────────────────────────────────────────────────
step "Checking npm dependencies"
if [[ ! -d node_modules ]] || [[ package.json -nt node_modules/.package-lock.json ]]; then
  echo "  package.json changed — running npm install"
  npm install
else
  echo "  node_modules up to date — skipping install"
fi

# ── run ───────────────────────────────────────────────────────────────────────
step "Starting Next.js dev server"
echo ""
echo "  Admin panel: http://localhost:3555"
echo "  Press Ctrl+C to stop"
echo ""

npm run dev -- --port 3555
