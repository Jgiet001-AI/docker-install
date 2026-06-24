# Local n8n, Redis, and Postgres

This Docker Compose setup runs n8n, Redis, and Postgres locally with persistent Docker volumes.

## URLs and Connections

- n8n: http://localhost:5678
- Redis from n8n workflows: host `redis`, port `6379`
- Redis from host scripts: host `localhost`, port `6379`
- Postgres from n8n workflows: host `postgres`, port `5432`, database `n8n_local`, user `n8n`
- Postgres from host scripts: host `localhost`, port `5432`, database `n8n_local`, user `n8n`
- Postgres password: stored in `.env` as `POSTGRES_PASSWORD`
- Shared host files for n8n: put files in `./local-files`, then use `/files` inside n8n

## Quick start

Clone the repo and run the bootstrap script. It creates `.env` from
`.env.example` with randomly generated secrets (no editing, no prompts) and
starts the stack:

```bash
# macOS / Linux
./scripts/start.sh
```

```powershell
# Windows
pwsh scripts/start.ps1
```

Re-running is safe — an existing `.env` is never overwritten, so your secrets
and saved n8n credentials are preserved. **Back up `.env`**: changing
`N8N_ENCRYPTION_KEY` later breaks saved n8n credentials.

## Commands

```bash
docker compose ps
docker compose logs -f
```

To stop the stack without deleting saved data:

```bash
docker compose down
```

The `n8n_data`, `redis_data`, and `postgres_data` Docker volumes preserve app data between restarts.
