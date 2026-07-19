#Requires -RunAsAdministrator
<#
.SYNOPSIS
  تثبيت WSL2 + تشغيل Docker + Kiddy Link
  شغّل هذا الملف: Right-click -> Run with PowerShell (as Administrator)
#>
$ErrorActionPreference = 'Stop'

Write-Host "=== Kiddy Link - Full Setup (Admin) ===" -ForegroundColor Cyan

# 1. WSL2
Write-Host "`n[1/4] Installing WSL2..."
wsl --install --no-distribution
if ($LASTEXITCODE -ne 0) {
    Write-Host "WSL may already be installed or needs reboot." -ForegroundColor Yellow
}

# 2. Docker Desktop
Write-Host "`n[2/4] Installing Docker Desktop..."
winget install Docker.DockerDesktop --accept-package-agreements --accept-source-agreements

# 3. Start Docker Desktop
Write-Host "`n[3/4] Starting Docker Desktop..."
$dockerExe = "C:\Program Files\Docker\Docker\Docker Desktop.exe"
if (Test-Path $dockerExe) {
    Start-Process $dockerExe
    Write-Host "Waiting for Docker daemon (up to 3 min)..."
    $docker = "C:\Program Files\Docker\Docker\resources\bin\docker.exe"
    $ready = $false
    for ($i = 1; $i -le 36; $i++) {
        & $docker info *> $null
        if ($LASTEXITCODE -eq 0) { $ready = $true; break }
        Start-Sleep -Seconds 5
    }
    if (-not $ready) {
        Write-Host "Docker not ready yet. Complete Docker Desktop setup UI, then re-run step 4." -ForegroundColor Yellow
    }
}

# 4. Start Kiddy Link stack
Write-Host "`n[4/4] Starting Kiddy Link..."
Set-Location "e:\Eman Project"
docker compose up -d --build

Write-Host "`n=== Done ===" -ForegroundColor Green
Write-Host "Swagger: http://localhost:3000/api/docs"
Write-Host "Login: admin / Admin@123"
Write-Host ""
Write-Host "If WSL was just installed, REBOOT Windows first, then run:"
Write-Host "  cd 'e:\Eman Project'; docker compose up -d --build"
