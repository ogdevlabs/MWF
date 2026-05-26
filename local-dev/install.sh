#!/usr/bin/env bash
# install.sh — Install all project dependencies
# Run once after cloning, or whenever pubspec.yaml / package.json changes.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

# Load local credentials if already set up (silent — install may run before .env exists)
# shellcheck source=/dev/null
[[ -f "$REPO_ROOT/local-dev/.env" ]] && source "$REPO_ROOT/local-dev/.env"

# ── colours ──────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
step()  { echo -e "\n${GREEN}▶ $*${NC}"; }
warn()  { echo -e "${YELLOW}⚠  $*${NC}"; }
die()   { echo -e "${RED}✗  $*${NC}"; exit 1; }

# ── prerequisite checks ───────────────────────────────────────────────────────
step "Checking prerequisites"

command -v flutter >/dev/null 2>&1 || die "Flutter not found. Install: https://docs.flutter.dev/get-started/install"
command -v node    >/dev/null 2>&1 || die "Node.js not found. Install: https://nodejs.org"
command -v npx     >/dev/null 2>&1 || die "npx not found (should come with Node.js)"

FLUTTER_VERSION=$(flutter --version 2>/dev/null | awk 'NR==1{print $2}')
echo "  Flutter $FLUTTER_VERSION"
echo "  Node $(node --version)"

# ── Flutter dependencies ──────────────────────────────────────────────────────
step "Installing Flutter dependencies (mobile/)"
cd "$REPO_ROOT/mobile"
flutter pub get

# ── Android licenses (one-time, non-fatal if already accepted) ───────────────
step "Accepting Android SDK licenses (non-interactive)"
yes | flutter doctor --android-licenses 2>/dev/null || true

# ── Next.js dependencies ──────────────────────────────────────────────────────
step "Installing npm dependencies (admin/)"
cd "$REPO_ROOT/admin"
npm install

# ── env files ────────────────────────────────────────────────────────────────
step "Checking environment files"
cd "$REPO_ROOT"

if [[ ! -f admin/.env.local ]]; then
  cp admin/.env.local.example admin/.env.local
  warn "Created admin/.env.local — fill in Supabase keys before running the admin panel."
else
  echo "  admin/.env.local already exists — skipping."
fi

if [[ ! -f local-dev/.env ]]; then
  cp local-dev/.env.example local-dev/.env
  warn "Created local-dev/.env — fill in your Google Sign-In client IDs and other credentials."
  warn "Edit: local-dev/.env"
else
  echo "  local-dev/.env already exists — skipping."
fi

# ── done ─────────────────────────────────────────────────────────────────────
echo -e "\n${GREEN}✓ Dependencies installed.${NC}"
echo ""
echo "  Next steps:"
echo "    ./local-dev/supabase.sh start   — start local Supabase (requires Docker)"
echo "    ./local-dev/run-mobile.sh       — run Flutter app on simulator"
echo "    ./local-dev/run-admin.sh        — run Next.js admin panel"
echo "    ./local-dev/dev.sh              — start everything at once"
