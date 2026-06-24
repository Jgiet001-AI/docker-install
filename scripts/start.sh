#!/usr/bin/env bash
#
# One-command bootstrap for the n8n + Redis + Postgres stack (macOS/Linux).
#
#   ./scripts/start.sh
#
# Creates .env from .env.example on first run, filling in randomly generated
# secrets (N8N_ENCRYPTION_KEY, POSTGRES_PASSWORD) so there is nothing to edit
# by hand, then runs `docker compose up -d`. Safe to re-run: an existing .env
# is never overwritten, so secrets and saved n8n credentials are preserved.
set -euo pipefail

# Resolve repo root from this script's location so it works from any cwd.
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

env_file="$root/.env"
example_file="$root/.env.example"

# --- preflight ---------------------------------------------------------------
if ! command -v docker >/dev/null 2>&1; then
  echo "error: docker is not installed or not on PATH. Install Docker Desktop first." >&2
  exit 1
fi
if ! docker compose version >/dev/null 2>&1; then
  echo "error: 'docker compose' (v2) is unavailable. Update Docker Desktop." >&2
  exit 1
fi
if ! docker info >/dev/null 2>&1; then
  echo "error: the Docker engine is not running. Start Docker Desktop and retry." >&2
  exit 1
fi

# --- generate .env on first run ---------------------------------------------
gen_secret() { openssl rand -hex "$1"; }  # hex => no shell/.env-unsafe chars

if [[ -f "$env_file" ]]; then
  echo ".env already exists — leaving it untouched."
else
  if [[ ! -f "$example_file" ]]; then
    echo "error: .env.example not found; cannot bootstrap .env." >&2
    exit 1
  fi

  enc_key="$(gen_secret 16)"   # 32 hex chars for N8N_ENCRYPTION_KEY
  pg_pass="$(gen_secret 24)"   # 48 hex chars for POSTGRES_PASSWORD

  # Copy the example, substituting only the two placeholder secret lines.
  # Done line-by-line so it is portable across BSD (macOS) and GNU sed.
  while IFS= read -r line || [[ -n "$line" ]]; do
    case "$line" in
      N8N_ENCRYPTION_KEY=*) echo "N8N_ENCRYPTION_KEY=$enc_key" ;;
      POSTGRES_PASSWORD=*)  echo "POSTGRES_PASSWORD=$pg_pass" ;;
      *)                    echo "$line" ;;
    esac
  done < "$example_file" > "$env_file"

  chmod 600 "$env_file"
  echo "Created .env with generated secrets (N8N_ENCRYPTION_KEY, POSTGRES_PASSWORD)."
  echo "Back up .env — changing N8N_ENCRYPTION_KEY later breaks saved n8n credentials."
fi

# --- bring the stack up ------------------------------------------------------
echo "Starting stack..."
docker compose up -d
docker compose ps

echo
echo "n8n is starting at http://localhost:5678"
echo "Follow logs with: docker compose logs -f"
