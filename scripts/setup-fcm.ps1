#Requires -Version 5.1
<#
.SYNOPSIS
  Configure Firebase Cloud Messaging credentials in backend/.env

.EXAMPLE
  .\setup-fcm.ps1
  .\setup-fcm.ps1 -ProjectId "my-project" -ClientEmail "firebase-adminsdk@..." -PrivateKey "-----BEGIN..."
#>
param(
    [string]$ProjectId,
    [string]$ClientEmail,
    [string]$PrivateKey
)

$root = Split-Path -Parent $PSScriptRoot
$envFile = Join-Path $root "backend\.env"

if (-not (Test-Path $envFile)) {
    Write-Host "[FAIL] backend/.env not found" -ForegroundColor Red
    exit 1
}

Write-Host "=== FCM Setup ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Firebase Console: https://console.firebase.google.com"
Write-Host "2. Project Settings -> Service accounts -> Generate new private key"
Write-Host "3. From the JSON file copy: project_id, client_email, private_key"
Write-Host ""

if ([string]::IsNullOrWhiteSpace($ProjectId)) {
    $ProjectId = Read-Host "FCM_PROJECT_ID"
}
if ([string]::IsNullOrWhiteSpace($ClientEmail)) {
    $ClientEmail = Read-Host "FCM_CLIENT_EMAIL"
}
if ([string]::IsNullOrWhiteSpace($PrivateKey)) {
    Write-Host "Paste FCM_PRIVATE_KEY (full PEM, one line with \n is OK):"
    $PrivateKey = Read-Host "FCM_PRIVATE_KEY"
}

$ProjectId = $ProjectId.Trim()
$ClientEmail = $ClientEmail.Trim()
$PrivateKey = $PrivateKey.Trim()

if ([string]::IsNullOrWhiteSpace($ProjectId) -or [string]::IsNullOrWhiteSpace($ClientEmail) -or [string]::IsNullOrWhiteSpace($PrivateKey)) {
    Write-Host "[!] Empty values — cancelled" -ForegroundColor Yellow
    exit 1
}

# Store PEM as single line with \n escapes for .env
$PrivateKeyEnv = $PrivateKey -replace "`r?`n", '\n'

$content = Get-Content $envFile -Raw

function Set-EnvLine([string]$text, [string]$key, [string]$value) {
    if ($text -match "(?m)^$key=") {
        return ($text -replace "(?m)^$key=.*$", "$key=$value")
    }
    return $text + "`n$key=$value"
}

$content = Set-EnvLine $content "FCM_PROJECT_ID" $ProjectId
$content = Set-EnvLine $content "FCM_CLIENT_EMAIL" $ClientEmail
$content = Set-EnvLine $content "FCM_PRIVATE_KEY" "`"$PrivateKeyEnv`""

Set-Content -Path $envFile -Value $content.TrimEnd() + "`n" -NoNewline

Write-Host ""
Write-Host "[OK] Saved to backend/.env" -ForegroundColor Green
Write-Host "[*] Restarting API..."
& (Join-Path $root "scripts\restart-api.ps1")

Start-Sleep -Seconds 3
Write-Host ""
& (Join-Path $root "scripts\verify-fcm.ps1")

Write-Host ""
Write-Host "Mobile FCM: see docs\FCM_SETUP.md (flutterfire configure)" -ForegroundColor Cyan
