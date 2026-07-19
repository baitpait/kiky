#Requires -Version 5.1
<#
.SYNOPSIS
  Reset admin password to default (Admin@123)
#>
$backend = "E:\Eman Project\backend"
Push-Location $backend
Write-Host "=== Reset Admin Password ===" -ForegroundColor Cyan
npx ts-node scripts/reset-admin-password.ts
if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] admin / Admin@123" -ForegroundColor Green
} else {
    Write-Host "[!] Reset failed" -ForegroundColor Red
    exit 1
}
Pop-Location
