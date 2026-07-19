#Requires -Version 5.1
<#
.SYNOPSIS
  Phase 6 - pre-launch verification (local XAMPP stack)
#>
$api = "http://localhost:3000/api"
$root = Split-Path -Parent $PSScriptRoot
$results = @()

function Pass($name) {
    $script:results += "[OK] $name"
    Write-Host "[OK] $name" -ForegroundColor Green
}

function Fail($name, $msg) {
    $script:results += "[FAIL] $name - $msg"
    Write-Host "[FAIL] $name - $msg" -ForegroundColor Red
}

function Warn($name, $msg) {
    $script:results += "[WARN] $name - $msg"
    Write-Host "[WARN] $name - $msg" -ForegroundColor Yellow
}

Write-Host "=== Phase 6 Pre-Launch Check ===" -ForegroundColor Cyan

# API reachable
try {
    $health = Invoke-RestMethod -Uri "$api/auth/login" -Method POST `
        -ContentType "application/json" `
        -Body (@{ username = "admin"; password = "Admin@123" } | ConvertTo-Json)
    $ah = @{ Authorization = "Bearer $($health.accessToken)" }
    Pass "API online + admin login"
} catch {
    Fail "API online" $_.Exception.Message
    Write-Host "Start API first: E:\Eman Project\START.bat" -ForegroundColor Red
    exit 1
}

# Swagger (optional - disabled unless SWAGGER_ENABLED=true)
try {
    $sw = Invoke-WebRequest -Uri "http://localhost:3000/api/docs" -UseBasicParsing -TimeoutSec 5
    if ($sw.StatusCode -eq 200) { Pass "Swagger /api/docs" }
    else { Warn "Swagger" "HTTP $($sw.StatusCode)" }
} catch { Warn "Swagger" "disabled - set SWAGGER_ENABLED=true in backend/.env" }

# Web app
try {
    $web = Invoke-WebRequest -Uri "http://localhost:8082/login" -UseBasicParsing -TimeoutSec 5
    if ($web.StatusCode -eq 200) { Pass "Web app http://localhost:8082" }
    else { Warn "Web app" "HTTP $($web.StatusCode) - run start-web-fast.ps1" }
} catch { Warn "Web app" "not running on 8082" }

# .env production readiness (warnings only)
$envFile = Join-Path $root "backend\.env"
if (Test-Path $envFile) {
    $envText = Get-Content $envFile -Raw
    if ($envText -match 'JWT_ACCESS_SECRET=change-me|JWT_REFRESH_SECRET=change-me') {
        Warn "Secrets" "default JWT secrets - change before production"
    } else { Pass "JWT secrets customized" }

    if ($envText -notmatch 'AGORA_APP_ID=\s*\S+') {
        Warn "Agora" "no AGORA_APP_ID - live uses demo mode"
    } else { Pass "Agora configured" }

    if ($envText -notmatch 'OPENAI_API_KEY=\s*\S+') {
        Warn "OpenAI" "no key - AI uses fallback picker"
    } else { Pass "OpenAI configured" }
} else {
    Warn ".env" "backend/.env missing - copy from .env.example"
}

# Phase 6 admin features: notify + content CRUD smoke
try {
    Invoke-RestMethod -Uri "$api/admin/notifications/send" -Method POST -Headers $ah `
        -ContentType "application/json" `
        -Body (@{
            target = "parents"
            title  = "Phase6 launch test"
            body   = "pre-launch check"
        } | ConvertTo-Json) | Out-Null
    Pass "Admin send notification"
} catch { Fail "Admin send notification" $_.Exception.Message }

try {
    $banners = Invoke-RestMethod -Uri "$api/admin/banners" -Headers $ah
    $events = Invoke-RestMethod -Uri "$api/admin/calendar-events" -Headers $ah
    Pass "Admin banners count $($banners.Count)"
    Pass "Admin calendar count $($events.Count)"
} catch { Fail "Admin content" $_.Exception.Message }

# Uploads folder exists (local photos)
$uploads = Join-Path $root "backend\uploads"
if (Test-Path $uploads) {
    $files = @(Get-ChildItem $uploads -Recurse -File -ErrorAction SilentlyContinue)
    Pass "Local uploads folder ($($files.Count) files)"
} else {
    Warn "Uploads" "backend/uploads empty or missing"
}

# Run prior phase tests
$phaseScripts = @(
    "test-phase2.ps1",
    "test-phase3.ps1",
    "test-phase4.ps1",
    "test-phase5.ps1",
    "test-parent-ui.ps1"
)

foreach ($script in $phaseScripts) {
    $path = Join-Path $root "scripts\$script"
    if (-not (Test-Path $path)) {
        Fail $script "missing"
        continue
    }
    Write-Host ""
    Write-Host "--- Running $script ---" -ForegroundColor DarkCyan
    & powershell -ExecutionPolicy Bypass -File $path
    if ($LASTEXITCODE -eq 0) { Pass "$script passed" }
    else { Fail $script "failed" }
}

Write-Host ""
Write-Host "=== Phase 6 Summary ===" -ForegroundColor Cyan
$results | ForEach-Object { Write-Host $_ }
$failed = @($results | Where-Object { $_ -match '^\[FAIL\]' }).Count
$warned = @($results | Where-Object { $_ -match '^\[WARN\]' }).Count

Write-Host ""
if ($failed -eq 0) {
    Write-Host "Phase 6 LOCAL: READY FOR LAUNCH PREP" -ForegroundColor Green
    if ($warned -gt 0) {
        Write-Host "$warned warnings - review before production server deploy" -ForegroundColor Yellow
    }
    Write-Host ""
    Write-Host "Production deploy: see docs/DEPLOYMENT.md" -ForegroundColor Cyan
} else {
    Write-Host "Phase 6: $failed failed - fix before launch" -ForegroundColor Red
    exit 1
}
