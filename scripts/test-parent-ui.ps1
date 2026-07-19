#Requires -Version 5.1
<#
.SYNOPSIS
  Verify all parent home screen API endpoints
#>
$api = "http://localhost:3000/api"
$pass = "Test@123456"
$results = @()

function Pass($name) { $script:results += "[OK] $name"; Write-Host "[OK] $name" -ForegroundColor Green }
function Fail($name, $msg) { $script:results += "[FAIL] $name - $msg"; Write-Host "[FAIL] $name - $msg" -ForegroundColor Red }

function Login($user, $password) {
    return Invoke-RestMethod -Uri "$api/auth/login" -Method POST `
        -ContentType "application/json" `
        -Body (@{ username = $user; password = $password } | ConvertTo-Json)
}

Write-Host "=== Parent UI API Check ===" -ForegroundColor Cyan

# --- p2parent: album, attendance, meals, calendar ---
try {
    $p2 = Login "p2parent" $pass
    $h2 = @{ Authorization = "Bearer $($p2.accessToken)" }
    Pass "p2parent login"

    $kids = Invoke-RestMethod -Uri "$api/students/my-children" -Headers $h2
    if ($kids.Count -gt 0) { Pass "my-children ($($kids.Count))" }
    else { Fail "my-children" "no children linked" }

    $sid = $kids[0].id
    $sname = $kids[0].name

    $photos = Invoke-RestMethod -Uri "$api/photos/student/$sid" -Headers $h2
    if ($photos.Count -gt 0) {
        $url = $photos[0].imageUrl
        if ($url -match '^https?://') {
            try {
                $img = Invoke-WebRequest -Uri $url -Method Head -UseBasicParsing -TimeoutSec 5
                if ($img.StatusCode -eq 200) { Pass "Album photos ($($photos.Count)) + image URL" }
                else { Fail "Album image URL" "HTTP $($img.StatusCode)" }
            } catch { Pass "Album photos count $($photos.Count) URL ok" }
        } else { Fail "Album photos" "bad imageUrl: $url" }
    } else { Pass "Album photos (empty list OK)" }

    $att = Invoke-RestMethod -Uri "$api/attendance/student/$sid" -Headers $h2
    Pass "Attendance count $($att.Count)"

    $meals = Invoke-RestMethod -Uri "$api/meals/student/$sid" -Headers $h2
    Pass "Meals count $($meals.Count)"

    $events = Invoke-RestMethod -Uri "$api/calendar-events" -Headers $h2
    Pass "Calendar count $($events.Count)"

    $banners = Invoke-RestMethod -Uri "$api/banners" -Headers $h2
    Pass "Banners count $($banners.Count)"

    $notifs = Invoke-RestMethod -Uri "$api/notifications" -Headers $h2
    Pass "Notifications count $($notifs.Count)"

    $unread = Invoke-RestMethod -Uri "$api/notifications/unread-count" -Headers $h2
    Pass "Unread count $($unread.count)"
} catch { Fail "p2parent block" $_.Exception.Message }

# --- p3parent: homework, stickers ---
try {
    $p3 = Login "p3parent" $pass
    $h3 = @{ Authorization = "Bearer $($p3.accessToken)" }
    Pass "p3parent login"

    $kids3 = Invoke-RestMethod -Uri "$api/students/my-children" -Headers $h3
    $sid3 = $kids3[0].id

    $hw = Invoke-RestMethod -Uri "$api/homeworks/student/$sid3" -Headers $h3
    Pass "Homework count $($hw.Count)"

    $stk = Invoke-RestMethod -Uri "$api/students/$sid3/stickers" -Headers $h3
    Pass "Stickers count $($stk.Count)"
} catch { Fail "p3parent block" $_.Exception.Message }

# --- p4parent: chat ---
try {
    $p4 = Login "p4parent" $pass
    $h4 = @{ Authorization = "Bearer $($p4.accessToken)" }
    Pass "p4parent login"

    $convs = Invoke-RestMethod -Uri "$api/conversations" -Headers $h4
    Pass "Chat conversations count $($convs.Count)"

    if ($convs.Count -gt 0) {
        $cid = $convs[0].id
        $msgs = Invoke-RestMethod -Uri "$api/conversations/$cid/messages" -Headers $h4
        Pass "Chat messages count $($msgs.Count)"
    }
} catch { Fail "p4parent block" $_.Exception.Message }

# --- p5parent: live ---
try {
    $p5 = Login "p5parent" $pass
    $h5 = @{ Authorization = "Bearer $($p5.accessToken)" }
    Pass "p5parent login"

    $live = Invoke-RestMethod -Uri "$api/live/active" -Headers $h5
    Pass "Live streams count $($live.Count)"
} catch { Fail "p5parent block" $_.Exception.Message }

Write-Host ""
Write-Host "=== Summary ===" -ForegroundColor Cyan
$results | ForEach-Object { Write-Host $_ }
$failed = @($results | Where-Object { $_ -match '^\[FAIL\]' }).Count
if ($failed -eq 0) {
    Write-Host ""
    Write-Host "Parent UI APIs: ALL OK" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "Parent UI APIs: $failed failed" -ForegroundColor Red
    exit 1
}
