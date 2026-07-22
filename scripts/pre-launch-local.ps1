#Requires -Version 5.1
<#
.SYNOPSIS
  Complete local pre-launch checks (before VPS deploy)
#>
$root = Split-Path -Parent $PSScriptRoot
$failed = 0

Write-Host '========================================' -ForegroundColor Cyan
Write-Host '  Kiddy Link - Pre-Launch Local' -ForegroundColor Cyan
Write-Host '========================================' -ForegroundColor Cyan
Write-Host ''

Write-Host '>>> Health check' -ForegroundColor DarkCyan
& (Join-Path $root 'scripts\health-check.ps1')
if ($LASTEXITCODE -ne 0) {
    Write-Host '[*] Starting stack...' -ForegroundColor Yellow
    & (Join-Path $root 'scripts\go.ps1')
    if ($LASTEXITCODE -ne 0) { exit 1 }
}

$checks = @(
    @{ Name = 'Storage (MinIO/local)'; Script = 'verify-minio.ps1'; Required = $true },
    @{ Name = 'Agora config'; Script = 'verify-agora.ps1'; Required = $false },
    @{ Name = 'FCM config'; Script = 'verify-fcm.ps1'; Required = $false },
    @{ Name = 'Notifications API'; Script = 'test-notifications.ps1'; Required = $true },
    @{ Name = 'FCM device register'; Script = 'test-fcm.ps1'; Required = $true },
    @{ Name = 'All phase tests'; Script = 'test-all.ps1'; Required = $true },
    @{ Name = 'Phase 6 launch prep'; Script = 'test-phase6.ps1'; Required = $true }
)

foreach ($check in $checks) {
    Write-Host ''
    Write-Host ('>>> ' + $check.Name) -ForegroundColor DarkCyan
    & (Join-Path $root ('scripts\' + $check.Script))
    if ($LASTEXITCODE -ne 0) {
        if ($check.Required) {
            $failed++
            Write-Host ('[FAIL] ' + $check.Name) -ForegroundColor Red
        } else {
            Write-Host ('[WARN] ' + $check.Name + ' - optional (needs credentials)') -ForegroundColor Yellow
        }
    }
}

Write-Host ''
Write-Host '========================================' -ForegroundColor Cyan
if ($failed -eq 0) {
    Write-Host 'PRE-LAUNCH LOCAL: COMPLETE' -ForegroundColor Green
    Write-Host ''
    Write-Host 'Ready locally. Before VPS deploy add:' -ForegroundColor Cyan
    Write-Host '  - Agora keys (SETUP-AGORA.bat)' -ForegroundColor White
    Write-Host '  - FCM keys (SETUP-FCM.bat)' -ForegroundColor White
    Write-Host '  - Official logo (docs/LOGO_SETUP.md)' -ForegroundColor White
    Write-Host '  - VPS deploy (docs/DEPLOYMENT.md)' -ForegroundColor White
} else {
    Write-Host ('PRE-LAUNCH LOCAL: ' + $failed + ' required check(s) FAILED') -ForegroundColor Red
    exit 1
}
