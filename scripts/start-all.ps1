#Requires -Version 5.1
<#
.SYNOPSIS
  Start Kiddy Link: MySQL + API + Web
#>
$projectRoot = "E:\Eman Project"
$backendPath = Join-Path $projectRoot "backend"

function Test-Api {
    try {
        Invoke-RestMethod -Uri "http://localhost:3000/api/auth/login" `
            -Method POST -ContentType "application/json" `
            -Body '{"username":"admin","password":"Admin@123"}' `
            -TimeoutSec 6 | Out-Null
        return $true
    } catch { return $false }
}

function Stop-ApiPort {
    Get-NetTCPConnection -LocalPort 3000 -State Listen -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty OwningProcess -Unique |
        ForEach-Object { Stop-Process -Id $_ -Force -ErrorAction SilentlyContinue }
}

Write-Host "=== Kiddy Link - Full Stack ===" -ForegroundColor Cyan

$mysql = Get-NetTCPConnection -LocalPort 3306 -State Listen -ErrorAction SilentlyContinue
if (-not $mysql) {
    Write-Host "[!] MySQL not running - start XAMPP first" -ForegroundColor Red
    exit 1
}
Write-Host "[OK] MySQL" -ForegroundColor Green

if (Test-Api) {
    Write-Host "[OK] API already running http://localhost:3000/api" -ForegroundColor Green
} else {
    $portBusy = Get-NetTCPConnection -LocalPort 3000 -State Listen -ErrorAction SilentlyContinue
    if ($portBusy) {
        Write-Host "[!] Port 3000 busy but API not responding - restarting..." -ForegroundColor Yellow
        Stop-ApiPort
        Start-Sleep -Seconds 2
    }
    Write-Host "[*] Starting API (fast mode)..."
    Push-Location $backendPath
    npm run build --silent 2>$null
    Pop-Location
    $apiBat = Join-Path $projectRoot "scripts\start-api.bat"
    Start-Process cmd -ArgumentList @("/c", "`"$apiBat`"") -WindowStyle Minimized
    $ready = $false
    for ($i = 1; $i -le 25; $i++) {
        if (Test-Api) { $ready = $true; break }
        Start-Sleep -Seconds 2
    }
    if (-not $ready) {
        Write-Host "[!] API failed to start - run: scripts\restart-api.ps1" -ForegroundColor Red
        exit 1
    }
    Write-Host "[OK] API http://localhost:3000/api" -ForegroundColor Green
}

$web = Get-NetTCPConnection -LocalPort 8082 -State Listen -ErrorAction SilentlyContinue
if (-not $web) {
    Write-Host "[*] Starting Web..."
    if (-not (Test-Path (Join-Path $projectRoot "mobile\build\web\index.html"))) {
        Write-Host "[!] Web not built - run start-web-fast.ps1 first" -ForegroundColor Yellow
    } else {
        $bat = Join-Path $projectRoot "scripts\start-web.bat"
        Start-Process cmd -ArgumentList @("/c", "`"$bat`"") -WindowStyle Minimized
        Start-Sleep -Seconds 4
        Write-Host "[OK] Web http://localhost:8082" -ForegroundColor Green
    }
} else {
    Write-Host "[OK] Web http://localhost:8082" -ForegroundColor Green
}

Start-Process "http://localhost:8082/login"
Write-Host ""
Write-Host "Login: admin / Admin@123" -ForegroundColor Green
Write-Host "IMPORTANT: Keep the API PowerShell window open!" -ForegroundColor Yellow
