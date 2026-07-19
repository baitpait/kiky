#Requires -Version 5.1
<#
.SYNOPSIS
  Quick health check - MySQL, API, Web, login
#>
$ok = $true

function Check($name, $test) {
    if ($test) {
        Write-Host "[OK] $name" -ForegroundColor Green
    } else {
        Write-Host "[FAIL] $name" -ForegroundColor Red
        $script:ok = $false
    }
}

Write-Host "=== Kiddy Link Health Check ===" -ForegroundColor Cyan

Check "MySQL (3306)" (Get-NetTCPConnection -LocalPort 3306 -State Listen -ErrorAction SilentlyContinue)
Check "API port (3000)" (Get-NetTCPConnection -LocalPort 3000 -State Listen -ErrorAction SilentlyContinue)
Check "Web port (8082)" (Get-NetTCPConnection -LocalPort 8082 -State Listen -ErrorAction SilentlyContinue)

try {
    Invoke-WebRequest -Uri "http://localhost:8082/login" -UseBasicParsing -TimeoutSec 8 | Out-Null
    Check "Web page /login" $true
} catch { Check "Web page /login" $false }

try {
    Invoke-RestMethod -Uri "http://localhost:3000/api/auth/login" -Method POST `
        -ContentType "application/json" `
        -Body '{"username":"admin","password":"Admin@123"}' `
        -TimeoutSec 8 | Out-Null
    Check "Login admin/Admin@123" $true
} catch { Check "Login admin/Admin@123" $false }

Write-Host ""
if ($ok) {
    Write-Host "ALL OK - open http://localhost:8082/login" -ForegroundColor Green
    exit 0
} else {
    Write-Host "PROBLEMS FOUND - run: scripts\start-all.ps1" -ForegroundColor Yellow
    exit 1
}
