<#
.SYNOPSIS
  One-command bootstrap for the n8n + Redis + Postgres stack (Windows).

    pwsh scripts/start.ps1

  Creates .env from .env.example on first run, filling in randomly generated
  secrets (N8N_ENCRYPTION_KEY, POSTGRES_PASSWORD) so there is nothing to edit
  by hand, then runs `docker compose up -d`. Safe to re-run: an existing .env
  is never overwritten, so secrets and saved n8n credentials are preserved.
#>
[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'

$root        = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$envFile     = Join-Path $root '.env'
$exampleFile = Join-Path $root '.env.example'

# --- preflight ---------------------------------------------------------------
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    throw "docker is not installed or not on PATH. Install Docker Desktop first."
}
docker compose version *> $null
if ($LASTEXITCODE -ne 0) { throw "'docker compose' (v2) is unavailable. Update Docker Desktop." }
docker info *> $null
if ($LASTEXITCODE -ne 0) { throw "the Docker engine is not running. Start Docker Desktop and retry." }

# --- generate .env on first run ---------------------------------------------
function New-Secret([int]$bytes) {
    # hex string => no shell/.env-unsafe characters
    -join ([System.Security.Cryptography.RandomNumberGenerator]::GetBytes($bytes) |
        ForEach-Object { $_.ToString('x2') })
}

if (Test-Path $envFile) {
    Write-Host ".env already exists - leaving it untouched." -ForegroundColor Yellow
}
else {
    if (-not (Test-Path $exampleFile)) { throw ".env.example not found; cannot bootstrap .env." }

    $encKey = New-Secret 16   # 32 hex chars for N8N_ENCRYPTION_KEY
    $pgPass = New-Secret 24   # 48 hex chars for POSTGRES_PASSWORD

    $lines = Get-Content $exampleFile | ForEach-Object {
        switch -Regex ($_) {
            '^N8N_ENCRYPTION_KEY=' { "N8N_ENCRYPTION_KEY=$encKey"; break }
            '^POSTGRES_PASSWORD='  { "POSTGRES_PASSWORD=$pgPass"; break }
            default                { $_ }
        }
    }
    # Write LF-only to match .gitattributes / container expectations.
    [System.IO.File]::WriteAllText($envFile, ($lines -join "`n") + "`n")

    Write-Host "Created .env with generated secrets (N8N_ENCRYPTION_KEY, POSTGRES_PASSWORD)." -ForegroundColor Green
    Write-Host "Back up .env - changing N8N_ENCRYPTION_KEY later breaks saved n8n credentials." -ForegroundColor Green
}

# --- bring the stack up ------------------------------------------------------
Write-Host "Starting stack..." -ForegroundColor Cyan
docker compose up -d
docker compose ps

Write-Host ""
Write-Host "n8n is starting at http://localhost:5678"
Write-Host "Follow logs with: docker compose logs -f"
