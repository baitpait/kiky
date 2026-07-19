#Requires -Version 5.1
<#
.SYNOPSIS
  تشغيل Kiddy Link محلياً — MySQL + NestJS + Flutter (Chrome)
#>
$projectRoot = "E:\Eman Project"
$flutterBin = "C:\src\flutter\bin"
$apiPort = 3000
$webPort = 8082

function Test-ApiHealthy {
    try {
        Invoke-RestMethod -Uri "http://localhost:$apiPort/api/auth/login" `
            -Method POST -ContentType "application/json" `
            -Body '{"username":"admin","password":"Admin@123"}' `
            -TimeoutSec 8 | Out-Null
        return $true
    } catch {
        return $false
    }
}

function Stop-PortListener([int]$Port) {
    $pids = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty OwningProcess -Unique
    foreach ($pid in $pids) {
        Stop-Process -Id $pid -Force -ErrorAction SilentlyContinue
    }
}

Write-Host "=== Kiddy Link - Local Start ===" -ForegroundColor Cyan
Write-Host "Project: $projectRoot"
Write-Host ""

$mysql = Get-NetTCPConnection -LocalPort 3306 -State Listen -ErrorAction SilentlyContinue
if (-not $mysql) {
    Write-Host "[!] MySQL not running on port 3306" -ForegroundColor Red
    Write-Host "    Open XAMPP Control Panel and start MySQL." -ForegroundColor Yellow
    exit 1
}
Write-Host "[OK] MySQL on port 3306" -ForegroundColor Green

if (-not (Test-ApiHealthy)) {
    Write-Host "[*] Restarting API on port $apiPort..."
    Stop-PortListener $apiPort
    Start-Sleep -Seconds 2
    Start-Process powershell -ArgumentList @(
        "-NoExit", "-Command",
        "Set-Location '$projectRoot\backend'; npm run start:dev"
    )
    $ready = $false
    for ($i = 1; $i -le 30; $i++) {
        if (Test-ApiHealthy) { $ready = $true; break }
        Start-Sleep -Seconds 2
    }
    if (-not $ready) {
        Write-Host "[!] API failed to start. Check the API PowerShell window for errors." -ForegroundColor Red
        exit 1
    }
    Write-Host "[OK] API ready on http://localhost:$apiPort/api" -ForegroundColor Green
} else {
    Write-Host "[OK] API already running on port $apiPort" -ForegroundColor Green
}

$env:PATH = "$flutterBin;$env:PATH"
$webHealthy = $false
try {
    $resp = Invoke-WebRequest -Uri "http://localhost:$webPort" -UseBasicParsing -TimeoutSec 8
    $webHealthy = $resp.StatusCode -eq 200
} catch {
    $webHealthy = $false
}

if (-not $webHealthy) {
    Write-Host "[*] Starting Flutter on http://localhost:$webPort ..."
    Stop-PortListener $webPort
    Stop-PortListener 8081
    Start-Sleep -Seconds 1
    Start-Process powershell -ArgumentList @(
        "-NoExit", "-Command",
        "& '$projectRoot\scripts\start-web-fast.ps1'"
    )
    Write-Host "[*] Building/serving fast web (see new window)..." -ForegroundColor Yellow
} else {
    Write-Host "[OK] Flutter already running on port $webPort" -ForegroundColor Green
}

Start-Process "http://localhost:$webPort"

Write-Host ""
Write-Host "=== Ready ===" -ForegroundColor Green
Write-Host "  App:   http://localhost:$webPort"
Write-Host "  API:   http://localhost:$apiPort/api"
Write-Host "  Login: admin / Admin@123"
Write-Host ""
