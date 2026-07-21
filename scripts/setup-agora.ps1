#Requires -Version 5.1
<#
.SYNOPSIS
  Configure Agora credentials in backend/.env for real live streaming
#>
$envFile = "E:\Eman Project\backend\.env"

if (-not (Test-Path $envFile)) {
    Write-Host "[FAIL] backend/.env not found" -ForegroundColor Red
    exit 1
}

Write-Host "=== Agora Setup ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Get credentials from: https://console.agora.io"
Write-Host "Project type: Secure mode (APP ID + Token)"
Write-Host ""

$appId = Read-Host "AGORA_APP_ID"
$cert = Read-Host "AGORA_APP_CERTIFICATE"

if ([string]::IsNullOrWhiteSpace($appId) -or [string]::IsNullOrWhiteSpace($cert)) {
    Write-Host "[!] Empty values — cancelled" -ForegroundColor Yellow
    exit 1
}

$content = Get-Content $envFile -Raw
$content = $content -replace '(?m)^AGORA_APP_ID=.*$', "AGORA_APP_ID=$appId"
$content = $content -replace '(?m)^AGORA_APP_CERTIFICATE=.*$', "AGORA_APP_CERTIFICATE=$cert"
if ($content -notmatch 'AGORA_TOKEN_EXPIRE=') {
    $content += "`nAGORA_TOKEN_EXPIRE=3600"
}
Set-Content -Path $envFile -Value $content -NoNewline

Write-Host ""
Write-Host "[OK] Saved to backend/.env" -ForegroundColor Green
Write-Host "[*] Restarting API..."
& "E:\Eman Project\scripts\restart-api.ps1"
Write-Host ""
Write-Host "Next: rebuild Web and test with p5teacher / p5parent" -ForegroundColor Cyan
Write-Host "Docs: docs/AGORA_SETUP.md"
