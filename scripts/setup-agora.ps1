#Requires -Version 5.1
<#
.SYNOPSIS
  Configure Agora credentials in backend/.env for real live streaming

.EXAMPLE
  .\setup-agora.ps1
  .\setup-agora.ps1 -AppId "your-app-id" -Certificate "your-cert"
#>
param(
    [string]$AppId,
    [string]$Certificate
)

$root = Split-Path -Parent $PSScriptRoot
$envFile = Join-Path $root "backend\.env"

if (-not (Test-Path $envFile)) {
    Write-Host "[FAIL] backend/.env not found" -ForegroundColor Red
    Write-Host "Copy from .env.example first." -ForegroundColor Yellow
    exit 1
}

Write-Host "=== Agora Setup ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Open: https://console.agora.io"
Write-Host "2. Projects -> Create -> Secure mode: APP ID + Token"
Write-Host "3. Copy App ID + Primary Certificate"
Write-Host ""

if ([string]::IsNullOrWhiteSpace($AppId)) {
    $AppId = Read-Host "AGORA_APP_ID"
}
if ([string]::IsNullOrWhiteSpace($Certificate)) {
    $Certificate = Read-Host "AGORA_APP_CERTIFICATE"
}

$AppId = $AppId.Trim()
$Certificate = $Certificate.Trim()

if ([string]::IsNullOrWhiteSpace($AppId) -or [string]::IsNullOrWhiteSpace($Certificate)) {
    Write-Host "[!] Empty values — cancelled" -ForegroundColor Yellow
    exit 1
}

$content = Get-Content $envFile -Raw
if ($content -match '(?m)^AGORA_APP_ID=') {
    $content = $content -replace '(?m)^AGORA_APP_ID=.*$', "AGORA_APP_ID=$AppId"
} else {
    $content += "`nAGORA_APP_ID=$AppId"
}

if ($content -match '(?m)^AGORA_APP_CERTIFICATE=') {
    $content = $content -replace '(?m)^AGORA_APP_CERTIFICATE=.*$', "AGORA_APP_CERTIFICATE=$Certificate"
} else {
    $content += "`nAGORA_APP_CERTIFICATE=$Certificate"
}

if ($content -notmatch '(?m)^AGORA_TOKEN_EXPIRE=') {
    $content += "`nAGORA_TOKEN_EXPIRE=3600"
}

Set-Content -Path $envFile -Value $content.TrimEnd() + "`n" -NoNewline

Write-Host ""
Write-Host "[OK] Saved to backend/.env" -ForegroundColor Green
Write-Host "[*] Restarting API..."
& (Join-Path $root "scripts\restart-api.ps1")

Start-Sleep -Seconds 3

Write-Host ""
Write-Host "[*] Verifying Agora..."
& (Join-Path $root "scripts\verify-agora.ps1")
$verifyExit = $LASTEXITCODE

Write-Host ""
if ($verifyExit -eq 0) {
    Write-Host "[OK] Agora ready — rebuild Web:" -ForegroundColor Green
    Write-Host "  scripts\start-web-fast.ps1"
    Write-Host ""
    Write-Host "Test accounts: p5teacher / p5parent — Test@123456"
} else {
    Write-Host "[WARN] Keys saved but API still in demo mode — check values and restart API" -ForegroundColor Yellow
}

Write-Host "Docs: docs\AGORA_SETUP.md"
