#Requires -Version 5.1
<#
.SYNOPSIS
  Run all Kiddy Link automated tests (phases 2-6 + parent UI)
#>
$root = Split-Path -Parent $PSScriptRoot
$scripts = @(
    "test-phase2.ps1",
    "test-phase3.ps1",
    "test-phase4.ps1",
    "test-phase5.ps1",
    "test-notifications.ps1",
    "test-fcm.ps1",
    "test-parent-ui.ps1"
)

Write-Host "=== Kiddy Link - All Tests ===" -ForegroundColor Cyan
$failed = 0

foreach ($s in $scripts) {
    Write-Host ""
    Write-Host ">>> $s" -ForegroundColor DarkCyan
    & powershell -ExecutionPolicy Bypass -File (Join-Path $root "scripts\$s")
    if ($LASTEXITCODE -ne 0) { $failed++ }
}

Write-Host ""
if ($failed -eq 0) {
    Write-Host "ALL TESTS PASSED" -ForegroundColor Green
} else {
    Write-Host "$failed test suite(s) FAILED" -ForegroundColor Red
    exit 1
}
