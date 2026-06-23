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

## Commands

Create your local environment file first:

```powershell
Copy-Item .env.example .env
```

```powershell
docker compose up -d
docker compose ps
docker compose logs -f
```

To stop the stack without deleting saved data:

```powershell
docker compose down
```

The `n8n_data`, `redis_data`, and `postgres_data` Docker volumes preserve app data between restarts.

<!-- claude-review oauth check (throwaway) -->
