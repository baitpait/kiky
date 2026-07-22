#Requires -Version 5.1
<#
.SYNOPSIS
  Import Firebase service account JSON into backend/.env

.EXAMPLE
  .\setup-fcm-from-json.ps1 -JsonPath "C:\Users\HP\Downloads\kiddy-link-xxxxx.json"
#>
param(
    [Parameter(Mandatory = $false)]
    [string]$JsonPath
)

$root = Split-Path -Parent $PSScriptRoot
$envFile = Join-Path $root "backend\.env"

if (-not $JsonPath) {
    Write-Host "=== FCM from JSON ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Firebase Console -> Project Settings -> Service accounts"
    Write-Host "-> Generate new private key -> save JSON file"
    Write-Host ""
    $JsonPath = Read-Host "Full path to JSON file"
}

if (-not (Test-Path $JsonPath)) {
    Write-Host "[FAIL] File not found: $JsonPath" -ForegroundColor Red
    exit 1
}

try {
    $json = Get-Content $JsonPath -Raw | ConvertFrom-Json
} catch {
    Write-Host "[FAIL] Invalid JSON: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

$projectId = [string]$json.project_id
$clientEmail = [string]$json.client_email
$privateKey = [string]$json.private_key

if ([string]::IsNullOrWhiteSpace($projectId) -or
    [string]::IsNullOrWhiteSpace($clientEmail) -or
    [string]::IsNullOrWhiteSpace($privateKey)) {
    Write-Host "[FAIL] JSON missing project_id, client_email, or private_key" -ForegroundColor Red
    exit 1
}

Write-Host "[OK] Project: $projectId" -ForegroundColor Green
Write-Host "[OK] Email:   $clientEmail" -ForegroundColor Green

if (-not (Test-Path $envFile)) {
    Write-Host "[FAIL] backend/.env not found" -ForegroundColor Red
    exit 1
}

$privateKeyEnv = $privateKey -replace "`r?`n", '\n'
$content = Get-Content $envFile -Raw

function Set-EnvLine([string]$text, [string]$key, [string]$value) {
    if ($text -match "(?m)^$key=") {
        return ($text -replace "(?m)^$key=.*$", "$key=$value")
    }
    return $text + "`n$key=$value"
}

$content = Set-EnvLine $content "FCM_PROJECT_ID" $projectId
$content = Set-EnvLine $content "FCM_CLIENT_EMAIL" $clientEmail
$content = Set-EnvLine $content "FCM_PRIVATE_KEY" "`"$privateKeyEnv`""

Set-Content -Path $envFile -Value $content.TrimEnd() + "`n" -NoNewline

Write-Host ""
Write-Host "[OK] Saved to backend/.env" -ForegroundColor Green
Write-Host "[*] Restarting API..."
& (Join-Path $root "scripts\restart-api.ps1")

Start-Sleep -Seconds 3
Write-Host ""
& (Join-Path $root "scripts\verify-fcm.ps1")

Write-Host ""
Write-Host "Next (mobile push): add Android app in Firebase -> google-services.json" -ForegroundColor Cyan
Write-Host "Docs: docs\FCM_SETUP.md"
