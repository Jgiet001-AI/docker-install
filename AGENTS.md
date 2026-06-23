# AGENTS.md — docker-install

Agent contract for this repo (read by Claude Code and Codex). Single source of truth for this
directory; there is no `CLAUDE.md` here, so this file stands alone.

## What this is

A local **n8n + Redis + Postgres** stack run with Docker Compose, for local automation/workflow
development. Data persists in named volumes (`n8n_data`, `redis_data`, `postgres_data`) across
restarts. Repo `Jgiet001-AI/docker-install`.

## Run

```powershell
Copy-Item .env.example .env     # then fill in real secrets (see below)
docker compose up -d
docker compose ps
docker compose logs -f
docker compose down             # stop; keeps volumes/data
```

## Services

| Service  | Image (pinned via env)         | Port (host)   | Notes |
| -------- | ------------------------------- | ------------- | ----- |
| n8n      | `n8nio/n8n:${N8N_VERSION}`      | `5678`        | UI at http://localhost:5678 |
| redis    | `redis:${REDIS_VERSION}`        | `6379`        | host `redis` from workflows |
| postgres | `postgres:${POSTGRES_VERSION}`  | `5432`        | db `n8n_local`, user `n8n`; host `postgres` from workflows |

Shared host files for n8n: drop files in `./local-files`, then reference them as `/files` inside n8n.

## Environment (`.env`, from `.env.example`)

- Versions: `N8N_VERSION`, `REDIS_VERSION`, `POSTGRES_VERSION`.
- `N8N_ENCRYPTION_KEY` — stable 32-char key; **back it up**, changing it breaks saved n8n credentials.
- `GENERIC_TIMEZONE`.
- Redis: `REDIS_HOST`, `REDIS_PORT`. Postgres: `POSTGRES_HOST`, `POSTGRES_PORT`, `POSTGRES_DB`,
  `POSTGRES_USER`, `POSTGRES_PASSWORD`.

## Conventions

- **Never commit `.env`** (it holds the encryption key + DB password). Stage files by name; never
  `git add -A`/`.`.
- **Docker engine churn:** prefer `docker compose restart <svc>` for a single misbehaving service.
  Reserve `wsl --shutdown` for a hung engine (`docker ps` hangs / "error during connect"); it bounces
  every distro and every other agent's containers.
- Other AI agents run on this machine concurrently — never kill their processes to free resources.

<!-- agent-pr-workflow -->
## PR workflow

This repo uses the agent PR flow (see the `pr-flow` convention note and the `/ship` command):

- **Never push straight to `main`.** Work on a branch; open a PR. The tracked `scripts/githooks/post-commit`
  hook (wired via `core.hooksPath=scripts/githooks`, set up by `scripts/setup.ps1` on a fresh clone)
  auto-pushes the current feature branch in the background but never the default branch.
- **Review bots:** every PR runs `.github/workflows/claude-code-review.yml` and `codex-review.yml`.
  They are token-gated on repo secrets `CLAUDE_CODE_OAUTH_TOKEN` and `OPENAI_API_KEY` (both set); the
  Codex job posts a `VERDICT: APPROVE|REQUEST_CHANGES` comment.
- **To ship a change:** run `/ship` (Claude) or the `ship` skill (Codex) — branch -> push -> open PR ->
  watch review + CI -> fix actionable findings -> ask before merge -> squash-merge + delete branch.
- These files are auto-provisioned/maintained by `~/.claude/hooks/provision-pr-workflow.ps1`; do not
  rename them. Run `pwsh scripts/setup.ps1` after cloning to activate the hook locally.
