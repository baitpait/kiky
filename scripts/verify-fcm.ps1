#Requires -Version 5.1
<#
.SYNOPSIS
  Check FCM configuration in backend/.env
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
    $projectId = ($lines | Where-Object { $_ -match '^FCM_PROJECT_ID=' }) -replace '^FCM_PROJECT_ID=', ''
    $email = ($lines | Where-Object { $_ -match '^FCM_CLIENT_EMAIL=' }) -replace '^FCM_CLIENT_EMAIL=', ''
    $key = ($lines | Where-Object { $_ -match '^FCM_PRIVATE_KEY=' }) -replace '^FCM_PRIVATE_KEY=', ''

    $hasProject = -not [string]::IsNullOrWhiteSpace($projectId)
    $hasEmail = -not [string]::IsNullOrWhiteSpace($email)
    $hasKey = -not [string]::IsNullOrWhiteSpace($key) -and $key -ne '""' -and $key -ne "''"

    Write-Host "=== FCM Status ===" -ForegroundColor Cyan
    Write-Host "FCM_PROJECT_ID:   $(if ($hasProject) { '[SET]' } else { '[EMPTY]' })"
    Write-Host "FCM_CLIENT_EMAIL: $(if ($hasEmail) { '[SET]' } else { '[EMPTY]' })"
    Write-Host "FCM_PRIVATE_KEY:  $(if ($hasKey) { '[SET] ****' } else { '[EMPTY]' })"

    if ($hasProject -and $hasEmail -and $hasKey) {
        Write-Host "Config: REAL push (FCM enabled after API restart)" -ForegroundColor Green
        return $true
    }

    Write-Host "Config: STUB mode (DB notifications only)" -ForegroundColor Yellow
    Write-Host "Run: scripts\setup-fcm.ps1" -ForegroundColor Yellow
    return $false
}

function Test-DeviceRegisterApi {
    $loginBody = @{ username = "p2parent"; password = "Test@123456" } | ConvertTo-Json
    try {
        $login = Invoke-RestMethod -Uri "$api/auth/login" -Method POST -ContentType "application/json" -Body $loginBody -TimeoutSec 8
    } catch {
        Write-Host "[WARN] API not reachable - start with scripts\go.ps1" -ForegroundColor Yellow
        return
    }

    $ph = @{ Authorization = "Bearer $($login.accessToken)" }
    $regBody = @{
        token = "verify-fcm-test-token-$(Get-Date -Format 'yyyyMMddHHmmss')"
        platform = "android"
    } | ConvertTo-Json

    try {
        Invoke-RestMethod -Uri "$api/devices/register" -Method POST -Headers $ph -ContentType "application/json" -Body $regBody -TimeoutSec 8 | Out-Null
        Write-Host "Device register API: OK" -ForegroundColor Green
    } catch {
        Write-Host "Device register API: FAIL - $($_.Exception.Message)" -ForegroundColor Red
    }
}

$configOk = Show-EnvStatus
Write-Host ""
Test-DeviceRegisterApi

if (-not $configOk) { exit 1 }
