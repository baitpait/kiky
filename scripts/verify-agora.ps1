#Requires -Version 5.1
<#
.SYNOPSIS
  Check Agora configuration in backend/.env and live API token mode
#>
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$envFile = Join-Path $root "backend\.env"
$api = "http://localhost:3000/api"

function Show-EnvStatus {
    if (-not (Test-Path $envFile)) {
        Write-Host "[FAIL] backend/.env not found" -ForegroundColor Red
        return $false
    }

    $lines = Get-Content $envFile
    $appId = ($lines | Where-Object { $_ -match '^AGORA_APP_ID=' }) -replace '^AGORA_APP_ID=', ''
    $cert = ($lines | Where-Object { $_ -match '^AGORA_APP_CERTIFICATE=' }) -replace '^AGORA_APP_CERTIFICATE=', ''

    $hasId = -not [string]::IsNullOrWhiteSpace($appId)
    $hasCert = -not [string]::IsNullOrWhiteSpace($cert)

    Write-Host "=== Agora Status ===" -ForegroundColor Cyan
    if ($hasId) {
        $preview = $appId.Substring(0, [Math]::Min(8, $appId.Length))
        Write-Host "AGORA_APP_ID:          [SET] ${preview}..."
    } else {
        Write-Host "AGORA_APP_ID:          [EMPTY]"
    }
    if ($hasCert) {
        Write-Host "AGORA_APP_CERTIFICATE: [SET] ****"
    } else {
        Write-Host "AGORA_APP_CERTIFICATE: [EMPTY]"
    }

    if ($hasId -and $hasCert) {
        Write-Host "Config: REAL mode (tokens from Agora)" -ForegroundColor Green
        return $true
    }

    Write-Host "Config: DEMO mode (no real video)" -ForegroundColor Yellow
    Write-Host "Run: scripts\setup-agora.ps1" -ForegroundColor Yellow
    return $false
}

function Test-LiveApi {
    $loginBody = @{ username = "p5teacher"; password = "Test@123456" } | ConvertTo-Json
    try {
        $login = Invoke-RestMethod -Uri "$api/auth/login" -Method POST -ContentType "application/json" -Body $loginBody -TimeoutSec 8
    } catch {
        Write-Host "[WARN] API not reachable - start with scripts\go.ps1" -ForegroundColor Yellow
        return
    }

    $th = @{ Authorization = "Bearer $($login.accessToken)" }

    try {
        $active = Invoke-RestMethod -Uri "$api/live/my-active" -Headers $th -TimeoutSec 8
        if ($active -and $active.id) {
            $endBody = @{ streamId = [int]$active.id } | ConvertTo-Json
            Invoke-RestMethod -Uri "$api/live/end" -Method POST -Headers $th -ContentType "application/json" -Body $endBody | Out-Null
        }
    } catch { }

    $startBody = @{ title = "Agora verify" } | ConvertTo-Json
    $start = Invoke-RestMethod -Uri "$api/live/start" -Method POST -Headers $th -ContentType "application/json" -Body $startBody -TimeoutSec 10

    $demo = [bool]$start.agora.demo
    $token = [string]$start.agora.token
    $streamId = [int]$start.stream.id

    if ($demo -or $token -eq "demo-token") {
        Write-Host "API live token: DEMO ($token)" -ForegroundColor Yellow
    } else {
        Write-Host "API live token: REAL (len=$($token.Length))" -ForegroundColor Green
    }

    $endBody2 = @{ streamId = $streamId } | ConvertTo-Json
    Invoke-RestMethod -Uri "$api/live/end" -Method POST -Headers $th -ContentType "application/json" -Body $endBody2 | Out-Null
}

$configOk = Show-EnvStatus
Write-Host ""
Test-LiveApi

if (-not $configOk) { exit 1 }
