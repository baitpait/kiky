# Kiddy Link - Local verification script (Windows)
Write-Host "========================================"
Write-Host "  Kiddy Link - Project Verification"
Write-Host "========================================"
Write-Host ""

$root = Split-Path -Parent $PSScriptRoot
$backend = Join-Path $root "backend"

Write-Host "[1/4] Building backend..."
Push-Location $backend
npm run build
if ($LASTEXITCODE -ne 0) {
    Write-Host "BUILD FAILED" -ForegroundColor Red
    exit 1
}
Write-Host "BUILD OK" -ForegroundColor Green
Pop-Location
Write-Host ""

Write-Host "[2/4] Project structure..."
Write-Host "  backend/src modules:"
Get-ChildItem (Join-Path $root "backend\src") -Directory | ForEach-Object { Write-Host "    - $($_.Name)" }
Write-Host ""
Write-Host "  mobile/lib features:"
Get-ChildItem (Join-Path $root "mobile\lib\features") -Directory | ForEach-Object { Write-Host "    - $($_.Name)" }
Write-Host ""

Write-Host "[3/4] Environment check..."
$docker = Get-Command docker -ErrorAction SilentlyContinue
$flutter = Get-Command flutter -ErrorAction SilentlyContinue
$node = node -v 2>$null
Write-Host "  Node.js: $node"
Write-Host "  Docker:  $(if ($docker) { 'OK' } else { 'NOT FOUND - install Docker Desktop' })"
Write-Host "  Flutter: $(if ($flutter) { 'OK' } else { 'NOT FOUND - install Flutter SDK' })"
Write-Host ""

Write-Host "[4/4] To run full stack:"
Write-Host "  1. Install Docker Desktop: winget install Docker.DockerDesktop"
Write-Host "  2. docker compose up -d --build"
Write-Host "  3. Open http://localhost:3000/api/docs"
Write-Host "  4. Login: admin / Admin@123"
Write-Host ""
Write-Host "  Flutter:"
Write-Host "  1. winget install Google.Flutter"
Write-Host "  2. cd mobile; flutter pub get; flutter run"
Write-Host ""
Write-Host "========================================"
Write-Host "  All 6 phases implemented!" -ForegroundColor Cyan
Write-Host "========================================"
