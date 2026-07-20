#Requires -Version 5.1
<#
.SYNOPSIS
  Clean Flutter + backend build caches and rebuild
#>
$projectRoot = "E:\Eman Project"
$ErrorActionPreference = "Stop"

Write-Host "=== Kiddy Link - Clean Cache ===" -ForegroundColor Cyan

Write-Host "[*] Stopping services..." -ForegroundColor Yellow
& "$projectRoot\scripts\stop-all.ps1" 2>$null
Start-Sleep -Seconds 2

Write-Host "[*] Flutter clean..." -ForegroundColor Yellow
Push-Location "$projectRoot\mobile"
flutter clean 2>&1 | Out-Host
Start-Sleep -Seconds 1
if (Test-Path "build") {
    Remove-Item -Recurse -Force "build" -ErrorAction SilentlyContinue
}
if (Test-Path ".dart_tool") {
    Remove-Item -Recurse -Force ".dart_tool" -ErrorAction SilentlyContinue
}
flutter pub get 2>&1 | Out-Host
Pop-Location

Write-Host "[*] Backend clean..." -ForegroundColor Yellow
Push-Location "$projectRoot\backend"
if (Test-Path "dist") {
    Remove-Item -Recurse -Force "dist"
}
npm run build 2>&1 | Out-Host
Pop-Location

Write-Host "[*] Rebuild web + start stack..." -ForegroundColor Yellow
& "$projectRoot\scripts\go.ps1"

Write-Host ""
Write-Host "=== Cache cleaned and stack restarted ===" -ForegroundColor Green
Write-Host "  http://localhost:8082/login" -ForegroundColor Cyan
