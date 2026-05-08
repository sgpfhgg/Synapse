# scripts/install.ps1 — deploy Collab Mesh into the OpenClaw workspace.
# Run from anywhere: pwsh ./scripts/install.ps1
# Idempotent: safe to re-run after every edit.

$ErrorActionPreference = 'Stop'

# Repo root = parent of scripts/
$repo = Split-Path -Parent $PSScriptRoot
$workspace = Join-Path $HOME '.openclaw\workspace'

if (-not (Test-Path $workspace)) {
  Write-Error "OpenClaw workspace not found at $workspace. Run 'openclaw onboard' first."
}

Write-Host "Deploying Collab Mesh -> $workspace" -ForegroundColor Cyan

# SOUL.md at workspace root
if (Test-Path "$repo\SOUL.md") {
  Copy-Item -Force "$repo\SOUL.md" "$workspace\SOUL.md"
  Write-Host "  + SOUL.md"
}

# members.json at workspace root (optional — exists once skill #2 lands)
if (Test-Path "$repo\members.json") {
  Copy-Item -Force "$repo\members.json" "$workspace\members.json"
  Write-Host "  + members.json"
}

# Skills directory: copy each <name>/ into workspace/skills/<name>/
$skillsTarget = Join-Path $workspace 'skills'
if (-not (Test-Path $skillsTarget)) {
  New-Item -ItemType Directory -Path $skillsTarget | Out-Null
}

if (Test-Path "$repo\skills") {
  Get-ChildItem "$repo\skills" -Directory | ForEach-Object {
    $dest = Join-Path $skillsTarget $_.Name
    if (Test-Path $dest) { Remove-Item -Recurse -Force $dest }
    Copy-Item -Recurse -Force $_.FullName $dest
    Write-Host "  + skills/$($_.Name)"
  }
}

Write-Host ""
Write-Host "Done. Reload the gateway so skills register:" -ForegroundColor Green
Write-Host "  openclaw gateway restart"
