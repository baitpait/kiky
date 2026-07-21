#Requires -Version 5.1
<#
.SYNOPSIS
  Reactivate phase test accounts (p2–p5) and clear stale live streams
#>
$mysql = "C:\xampp\mysql\bin\mysql.exe"
if (-not (Test-Path $mysql)) {
    Write-Host "[WARN] MySQL CLI not found - skip account reactivation" -ForegroundColor Yellow
    return
}

$userList = "'p2teacher','p2parent','p3teacher','p3parent','p4teacher','p4parent','p5teacher','p5parent'"
$teacherList = "'p2teacher','p3teacher','p4teacher','p5teacher'"
$parentList = "'p2parent','p3parent','p4parent','p5parent'"

& $mysql -u root kiddy_link -e "UPDATE users SET is_active = 1 WHERE username IN ($userList)" 2>$null | Out-Null
& $mysql -u root kiddy_link -e "UPDATE teachers t JOIN users u ON u.id = t.user_id SET t.is_active = 1 WHERE u.username IN ($teacherList)" 2>$null | Out-Null
& $mysql -u root kiddy_link -e "UPDATE parents p JOIN users u ON u.id = p.user_id SET p.is_active = 1 WHERE u.username IN ($parentList)" 2>$null | Out-Null
& $mysql -u root kiddy_link -e 'UPDATE live_streams SET status = ''ended'', ended_at = NOW() WHERE status = ''active''' 2>$null | Out-Null

Write-Host "[OK] Test accounts reactivated + stale live streams ended" -ForegroundColor Green
