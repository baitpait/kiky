#Requires -Version 5.1
<#
.SYNOPSIS
  One command: stop + start + test Kiddy Link
#>
$root = "E:\Eman Project"
Write-Host "=== Kiddy Link - Clean Start ===" -ForegroundColor Cyan

& "$root\scripts\stop-all.ps1"
Start-Sleep -Seconds 2
& "$root\scripts\start-all.ps1"
Start-Sleep -Seconds 6
& "$root\scripts\health-check.ps1"
