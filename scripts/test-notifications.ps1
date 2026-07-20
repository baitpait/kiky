#Requires -Version 5.1
<#
.SYNOPSIS
  Notification spec test — per-user records + bell count decreases on markRead
#>
$api = "http://localhost:3000/api"
$pass = "Test@123456"
$results = @()

function Pass($name) {
    $script:results += "[OK] $name"
    Write-Host "[OK] $name" -ForegroundColor Green
}

function Fail($name, $msg) {
    $script:results += "[FAIL] $name - $msg"
    Write-Host "[FAIL] $name - $msg" -ForegroundColor Red
}

function Login($user, $password) {
    return Invoke-RestMethod -Uri "$api/auth/login" -Method POST `
        -ContentType "application/json" `
        -Body (@{ username = $user; password = $password } | ConvertTo-Json)
}

Write-Host "=== Notifications Spec Test ===" -ForegroundColor Cyan

try {
    $admin = Login "admin" "Admin@123"
    $ah = @{ Authorization = "Bearer $($admin.accessToken)" }
    Pass "Admin login"
} catch {
    Fail "Admin login" $_.Exception.Message
    exit 1
}

try {
    $parent = Login "p2parent" $pass
    $ph = @{ Authorization = "Bearer $($parent.accessToken)" }
    Pass "Parent login (p2parent)"
} catch {
    Fail "Parent login" $_.Exception.Message
    exit 1
}

$before = 0
try {
    $beforeResp = Invoke-RestMethod -Uri "$api/notifications/unread-count" -Headers $ph
    $before = [int]$beforeResp.count
    Pass "Unread before send: $before"
} catch { Fail "Unread before" $_.Exception.Message }

$title = "Spec test $(Get-Date -Format 'HHmmss')"
try {
    $sent = Invoke-RestMethod -Uri "$api/admin/notifications/send" -Method POST -Headers $ah `
        -ContentType "application/json" `
        -Body (@{ title = $title; body = "Bell spec test"; target = "parents" } | ConvertTo-Json)
    if ($sent.sent -gt 0) { Pass "Admin broadcast to parents (sent=$($sent.sent))" }
    else { Fail "Admin broadcast" "sent=0" }
} catch { Fail "Admin broadcast" $_.Exception.Message }

Start-Sleep -Seconds 1

$after = 0
$notifId = $null
try {
    $afterResp = Invoke-RestMethod -Uri "$api/notifications/unread-count" -Headers $ph
    $after = [int]$afterResp.count
    if ($after -gt $before) { Pass "Unread increased ($before -> $after)" }
    else { Fail "Unread increase" "expected > $before, got $after" }

    $list = Invoke-RestMethod -Uri "$api/notifications" -Headers $ph
    $mine = $list | Where-Object { $_.title -eq $title } | Select-Object -First 1
    if ($mine -and $mine.id) {
        $notifId = $mine.id
        Pass "Parent list contains own notification (id=$notifId)"
        if ($mine.category -eq 'announcement') {
            Pass "Notification category=announcement (API field)"
        } else {
            Fail "Notification category" "expected announcement, got $($mine.category)"
        }
    } else {
        Fail "Parent list" "notification not found"
    }
} catch { Fail "Unread after send" $_.Exception.Message }

if ($notifId) {
    try {
        Invoke-RestMethod -Uri "$api/notifications/$notifId/read" -Method PUT -Headers $ph | Out-Null
        $finalResp = Invoke-RestMethod -Uri "$api/notifications/unread-count" -Headers $ph
        $final = [int]$finalResp.count
        if ($final -eq ($after - 1)) {
            Pass "markRead decreased bell ($after -> $final)"
        } else {
            Fail "markRead bell" "expected $($after - 1), got $final"
        }
    } catch { Fail "markRead" $_.Exception.Message }

    try {
        $teacher = Login "p2teacher" $pass
        $th = @{ Authorization = "Bearer $($teacher.accessToken)" }
        Invoke-RestMethod -Uri "$api/notifications/$notifId/read" -Method PUT -Headers $th -ErrorAction Stop | Out-Null
        Fail "Cross-user markRead blocked" "teacher could mark parent's notification"
    } catch {
        if ($_.Exception.Response.StatusCode.value__ -in @(403, 404)) {
            Pass "Cross-user markRead blocked ($($_.Exception.Response.StatusCode.value__))"
        } else {
            Fail "Cross-user markRead" $_.Exception.Message
        }
    }
}

Write-Host ""
Write-Host "=== Summary ===" -ForegroundColor Cyan
$results | ForEach-Object { Write-Host $_ }
$failed = @($results | Where-Object { $_ -like '[FAIL]*' }).Count
if ($failed -eq 0) {
    Write-Host ""
    Write-Host "Notifications spec: ALL PASSED" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "Notifications spec: $failed failed" -ForegroundColor Red
    exit 1
}
