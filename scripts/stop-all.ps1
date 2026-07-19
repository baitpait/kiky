#Requires -Version 5.1
<#
.SYNOPSIS
  Stop Kiddy Link API + Web (keeps MySQL/XAMPP running)
#>
Write-Host "=== Stop Kiddy Link ===" -ForegroundColor Cyan

foreach ($port in @(3000, 8082)) {
    Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty OwningProcess -Unique |
        ForEach-Object {
            Write-Host "[*] Stopping port $port (PID $_)..."
            Stop-Process -Id $_ -Force -ErrorAction SilentlyContinue
        }
}

Start-Sleep -Seconds 2
Write-Host "[OK] API and Web stopped. MySQL/XAMPP left running." -ForegroundColor Green
