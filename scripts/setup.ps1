<#
.SYNOPSIS
  One-time per-clone setup for the agent PR workflow: point git at the tracked hooks,
  populate origin/HEAD, normalize hook line endings to LF, and mark hooks executable.
  Run after cloning:  pwsh scripts/setup.ps1
  managed: agent-pr-workflow v1
#>
[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path

git -C $root config core.hooksPath scripts/githooks
Write-Host "core.hooksPath -> scripts/githooks" -ForegroundColor Green

# Populate origin/HEAD so the post-commit hook can resolve the real default branch.
git -C $root remote set-head origin --auto *> $null

# Normalize hook line endings to LF and mark executable in git's index.
$hookDir = Join-Path $root 'scripts/githooks'
Get-ChildItem -Path $hookDir -File | ForEach-Object {
    (Get-Content $_.FullName -Raw).Replace("`r`n", "`n") | Set-Content $_.FullName -NoNewline -Encoding ascii
    git -C $root update-index --add --chmod=+x ("scripts/githooks/" + $_.Name) *> $null
}
Write-Host "hooks normalized (LF) + marked executable" -ForegroundColor Green
Write-Host "Setup complete." -ForegroundColor Green
