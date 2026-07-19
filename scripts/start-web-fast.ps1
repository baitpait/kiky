#Requires -Version 5.1
<#
.SYNOPSIS
  تشغيل Kiddy Link Web بسرعة — Release + بدون CDN (لا ينتظر الإنترنت)
#>
$projectRoot = "E:\Eman Project"
$mobile = Join-Path $projectRoot "mobile"
$flutterBin = "C:\src\flutter\bin"
$webPort = 8082
$buildDir = Join-Path $mobile "build\web"
$stampFile = Join-Path $buildDir ".build-stamp"

function Stop-Port([int]$Port) {
    Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty OwningProcess -Unique |
        ForEach-Object { Stop-Process -Id $_ -Force -ErrorAction SilentlyContinue }
}

$env:PATH = "$flutterBin;$env:PATH"

Write-Host "=== Kiddy Link - Fast Web ===" -ForegroundColor Cyan

$needsBuild = -not (Test-Path (Join-Path $buildDir "index.html"))
if (-not $needsBuild -and (Test-Path $stampFile)) {
    $srcNewer = Get-ChildItem (Join-Path $mobile "lib") -Recurse -File -ErrorAction SilentlyContinue |
        Where-Object { $_.LastWriteTime -gt (Get-Item $stampFile).LastWriteTime } |
        Select-Object -First 1
    if ($srcNewer) { $needsBuild = $true }
}

if ($needsBuild) {
    Write-Host "[*] Building web release (once, 3-8 min)..." -ForegroundColor Yellow
    Push-Location $mobile
    flutter build web --release --no-web-resources-cdn
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[!] Build failed" -ForegroundColor Red
        exit 1
    }
    New-Item -ItemType File -Path $stampFile -Force | Out-Null
    Pop-Location
    Write-Host "[OK] Build complete" -ForegroundColor Green
} else {
    Write-Host "[OK] Using cached web build" -ForegroundColor Green
}

Stop-Port $webPort
Start-Sleep -Seconds 1

Write-Host "[*] Serving on http://localhost:$webPort ..."
Push-Location $buildDir

# Prefer SPA-aware Python server; fallback to Flutter web-server
$spaServer = Join-Path $projectRoot "scripts\spa_server.py"
$python = Get-Command python -ErrorAction SilentlyContinue
if ($python -and (Test-Path $spaServer)) {
    Start-Process powershell -ArgumentList @(
        "-NoExit", "-Command",
        "python '$spaServer' $webPort '$buildDir'"
    )
} elseif ($python) {
    Start-Process powershell -ArgumentList @(
        "-NoExit", "-Command",
        "Set-Location '$buildDir'; python -m http.server $webPort"
    )
} else {
    Start-Process powershell -ArgumentList @(
        "-NoExit", "-Command",
        "`$env:PATH = '$flutterBin;' + `$env:PATH; Set-Location '$mobile'; flutter run -d web-server --release --web-port=$webPort --web-hostname=localhost --no-web-resources-cdn"
    )
}
Pop-Location

Start-Sleep -Seconds 2
Start-Process "http://localhost:$webPort/login"

Write-Host ""
Write-Host "=== Ready ===" -ForegroundColor Green
Write-Host "  Login: http://localhost:$webPort/login"
Write-Host "  API:   http://localhost:3000/api (must be running)"
Write-Host "  Login: admin / Admin@123"
Write-Host ""
Write-Host "Tip: after first build, reload is fast (seconds)." -ForegroundColor DarkGray
