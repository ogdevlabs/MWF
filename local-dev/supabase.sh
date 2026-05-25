#!/usr/bin/env bash
# supabase.sh — Manage local Supabase stack
#
# Usage:
#   ./local-dev/supabase.sh start    — start stack + apply migrations
#   ./local-dev/supabase.sh stop     — stop stack
#   ./local-dev/supabase.sh reset    — wipe DB and re-apply all migrations
#   ./local-dev/supabase.sh status   — show running services and local API keys
#   ./local-dev/supabase.sh logs     — tail edge function logs

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; CYAN='\033[0;36m'; NC='\033[0m'
step() { echo -e "\n${GREEN}▶ $*${NC}"; }
warn() { echo -e "${YELLOW}⚠  $*${NC}"; }
die()  { echo -e "${RED}✗  $*${NC}"; exit 1; }
info() { echo -e "${CYAN}   $*${NC}"; }

SB="npx supabase"

# ── docker check ─────────────────────────────────────────────────────────────
check_docker() {
  if ! docker info >/dev/null 2>&1; then
    die "Docker is not running. Start Docker Desktop and retry."
  fi
}

# ── commands ──────────────────────────────────────────────────────────────────
cmd="${1:-start}"

case "$cmd" in
  start)
    check_docker
    step "Starting local Supabase"
    $SB start

    step "Applying migrations"
    $SB db push

    echo -e "\n${GREEN}✓ Supabase is running.${NC}"
    echo ""
    info "Studio:            http://localhost:54323"
    info "API:               http://localhost:54321"
    info "Inbucket (email):  http://localhost:54324"
    echo ""
    warn "Copy the anon key and service_role key printed above into admin/.env.local"
    ;;

  stop)
    step "Stopping local Supabase"
    $SB stop
    echo -e "\n${GREEN}✓ Supabase stopped.${NC}"
    ;;

  reset)
    check_docker
    step "Resetting database (all data will be lost)"
    read -rp "  Are you sure? [y/N] " confirm
    [[ "$confirm" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 0; }
    $SB db reset
    echo -e "\n${GREEN}✓ Database reset and migrations re-applied.${NC}"
    ;;

  status)
    step "Supabase status"
    $SB status 2>/dev/null || warn "Supabase does not appear to be running. Run: ./local-dev/supabase.sh start"
    ;;

  logs)
    step "Tailing edge function logs (Ctrl+C to stop)"
    $SB functions serve 2>&1 | grep --line-buffered -v "^$"
    ;;

  *)
    echo "Usage: $0 {start|stop|reset|status|logs}"
    exit 1
    ;;
esac
