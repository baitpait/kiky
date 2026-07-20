#Requires -Version 5.1
<#
.SYNOPSIS
  Start Kiddy Link on LAN for mobile testing
#>
$projectRoot = "E:\Eman Project"

function Get-LanIp {
    $ip = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
        Where-Object {
            $_.IPAddress -notmatch '^127\.' -and
            $_.IPAddress -notmatch '^169\.254\.' -and
            $_.PrefixOrigin -ne 'WellKnown'
        } |
        Sort-Object InterfaceMetric |
        Select-Object -First 1 -ExpandProperty IPAddress
    if ($ip) { return $ip }
    return 'localhost'
}

Write-Host "=== Kiddy Link - Network Mode ===" -ForegroundColor Cyan
& "$projectRoot\scripts\go.ps1"

$lan = Get-LanIp

Write-Host ""
Write-Host "=== PC ===" -ForegroundColor Green
Write-Host "  http://localhost:8082/login"
Write-Host ""
Write-Host "=== Phone (same Wi-Fi) ===" -ForegroundColor Green
Write-Host "  http://${lan}:8082/login"
Write-Host ""
Write-Host "=== API ===" -ForegroundColor Green
Write-Host "  http://${lan}:3000/api"
Write-Host ""
Write-Host "Login: admin / Admin@123" -ForegroundColor Cyan
