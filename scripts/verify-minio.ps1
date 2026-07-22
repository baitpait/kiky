#Requires -Version 5.1
<#
.SYNOPSIS
  Check MinIO / local uploads storage mode
#>
$ErrorActionPreference = "Continue"
$root = Split-Path -Parent $PSScriptRoot
$envFile = Join-Path $root "backend\.env"
$uploadsDir = Join-Path $root "backend\uploads"

Write-Host "=== Storage Status ===" -ForegroundColor Cyan

$minioEnabled = $false
if (Test-Path $envFile) {
    $lines = Get-Content $envFile
    $flag = ($lines | Where-Object { $_ -match '^MINIO_ENABLED=' }) -replace '^MINIO_ENABLED=', ''
    $minioEnabled = ($flag -eq 'true')
}

Write-Host "MINIO_ENABLED: $(if ($minioEnabled) { 'true' } else { 'false (local uploads)' })"

if ($minioEnabled) {
    $port = 9000
    if (Test-Path $envFile) {
        $portLine = (Get-Content $envFile | Where-Object { $_ -match '^MINIO_PORT=' }) -replace '^MINIO_PORT=', ''
        if ($portLine -match '^\d+$') { $port = [int]$portLine }
    }

    try {
        $tcp = New-Object System.Net.Sockets.TcpClient
        $tcp.Connect("localhost", $port)
        $tcp.Close()
        Write-Host "MinIO port $port : [OK] reachable" -ForegroundColor Green
        Write-Host "Mode: MinIO object storage" -ForegroundColor Green
    } catch {
        Write-Host "MinIO port $port : [FAIL] not reachable" -ForegroundColor Red
        Write-Host "Start: docker compose up -d minio" -ForegroundColor Yellow
        Write-Host "Or set MINIO_ENABLED=false for local uploads" -ForegroundColor Yellow
        exit 1
    }
} else {
    if (Test-Path $uploadsDir) {
        $count = @(Get-ChildItem $uploadsDir -Recurse -File -ErrorAction SilentlyContinue).Count
        Write-Host "Local uploads: [OK] backend/uploads ($count files)" -ForegroundColor Green
        Write-Host "Mode: local disk (fine for dev / pre-launch)" -ForegroundColor Green
    } else {
        New-Item -ItemType Directory -Path $uploadsDir -Force | Out-Null
        Write-Host "Local uploads: [OK] created backend/uploads" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host 'Production: enable MinIO - see docs\MINIO_SETUP.md' -ForegroundColor Cyan
