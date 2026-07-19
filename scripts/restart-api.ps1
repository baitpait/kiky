#Requires -Version 5.1
<#
.SYNOPSIS
  Restart Kiddy Link API - fast mode (no watch, starts in seconds)
#>
$projectRoot = "E:\Eman Project"
$backend = Join-Path $projectRoot "backend"

function Test-ApiReady {
    try {
        Invoke-RestMethod -Uri "http://localhost:3000/api/auth/login" `
            -Method POST -ContentType "application/json" `
            -Body '{"username":"admin","password":"Admin@123"}' `
            -TimeoutSec 8 | Out-Null
        return $true
    } catch { return $false }
}

Write-Host "=== Restart Kiddy Link API ===" -ForegroundColor Cyan

Get-NetTCPConnection -LocalPort 3000 -State Listen -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty OwningProcess -Unique |
    ForEach-Object {
        Write-Host "[*] Stopping old API (PID $_)..." -ForegroundColor Yellow
        Stop-Process -Id $_ -Force -ErrorAction SilentlyContinue
    }

Start-Sleep -Seconds 2

Write-Host "[*] Building API (once)..." -ForegroundColor Yellow
Push-Location $backend
npm run build --silent 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "[!] Build failed" -ForegroundColor Red
    Pop-Location
    exit 1
}
Pop-Location

Write-Host "[*] Starting API (fast mode)..." -ForegroundColor Yellow
$bat = Join-Path $projectRoot "scripts\start-api.bat"
Start-Process cmd -ArgumentList @("/c", "`"$bat`"") -WindowStyle Minimized

$ready = $false
for ($i = 1; $i -le 25; $i++) {
    if (Test-ApiReady) { $ready = $true; break }
    Start-Sleep -Seconds 2
}

if ($ready) {
    Write-Host "[OK] API http://localhost:3000/api" -ForegroundColor Green
} else {
    Write-Host "[!] API not ready - check MySQL is running in XAMPP" -ForegroundColor Red
    exit 1
}
