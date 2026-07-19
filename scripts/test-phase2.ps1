#Requires -Version 5.1
<#
.SYNOPSIS
  Phase 2 test - photos, attendance, meals, banners, calendar
#>
$api = "http://localhost:3000/api"
$pass = "Test@123456"
$today = (Get-Date).ToString("yyyy-MM-dd")
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

Write-Host "=== Phase 2 Test ===" -ForegroundColor Cyan

try {
    $admin = Login "admin" "Admin@123"
    $ah = @{ Authorization = "Bearer $($admin.accessToken)" }
    Pass "Admin login"
} catch {
    Fail "Admin login" $_.Exception.Message
    exit 1
}

try {
    $teachers = Invoke-RestMethod -Uri "$api/admin/teachers" -Headers $ah
    $tUser = $teachers | Where-Object { $_.user.username -eq "p2teacher" } | Select-Object -First 1
    if (-not $tUser) {
        Invoke-RestMethod -Uri "$api/admin/teachers" -Method POST -Headers $ah `
            -ContentType "application/json" `
            -Body (@{ username = "p2teacher"; password = $pass; name = "P2 Teacher" } | ConvertTo-Json) | Out-Null
    }
    Pass "Test teacher ready (p2teacher)"
} catch { Fail "Test teacher" $_.Exception.Message }

try {
    $parents = Invoke-RestMethod -Uri "$api/admin/parents" -Headers $ah
    $pUser = $parents | Where-Object { $_.user.username -eq "p2parent" } | Select-Object -First 1
    if (-not $pUser) {
        Invoke-RestMethod -Uri "$api/admin/parents" -Method POST -Headers $ah `
            -ContentType "application/json" `
            -Body (@{ username = "p2parent"; password = $pass; name = "P2 Parent" } | ConvertTo-Json) | Out-Null
    }
    Pass "Test parent ready (p2parent)"
} catch { Fail "Test parent" $_.Exception.Message }

try {
    $students = Invoke-RestMethod -Uri "$api/admin/students" -Headers $ah
    $student = $students | Where-Object { $_.name -eq "Phase2 Student" } | Select-Object -First 1
    if (-not $student) {
        $student = Invoke-RestMethod -Uri "$api/admin/students" -Method POST -Headers $ah `
            -ContentType "application/json" `
            -Body (@{ name = "Phase2 Student"; className = "KG-A" } | ConvertTo-Json)
    }
    $teachers = Invoke-RestMethod -Uri "$api/admin/teachers" -Headers $ah
    $tUser = $teachers | Where-Object { $_.user.username -eq "p2teacher" } | Select-Object -First 1
    $parents = Invoke-RestMethod -Uri "$api/admin/parents" -Headers $ah
    $pUser = $parents | Where-Object { $_.user.username -eq "p2parent" } | Select-Object -First 1
    try {
        Invoke-RestMethod -Uri "$api/admin/students/$($student.id)/link-teacher" -Method POST -Headers $ah `
            -ContentType "application/json" -Body (@{ teacherId = $tUser.id } | ConvertTo-Json) | Out-Null
    } catch {}
    try {
        Invoke-RestMethod -Uri "$api/admin/students/$($student.id)/link-parent" -Method POST -Headers $ah `
            -ContentType "application/json" -Body (@{ parentId = $pUser.id } | ConvertTo-Json) | Out-Null
    } catch {}
    $studentId = $student.id
    Pass "Student linked (id=$studentId)"
} catch { Fail "Student setup" $_.Exception.Message; $studentId = 1 }

try {
    $teacher = Login "p2teacher" $pass
    $th = @{ Authorization = "Bearer $($teacher.accessToken)" }
    Pass "Teacher login"
} catch { Fail "Teacher login" $_.Exception.Message }

try {
    $parent = Login "p2parent" $pass
    $ph = @{ Authorization = "Bearer $($parent.accessToken)" }
    Pass "Parent login"
} catch { Fail "Parent login" $_.Exception.Message }

try {
    Invoke-RestMethod -Uri "$api/attendance" -Method POST -Headers $th `
        -ContentType "application/json" `
        -Body (@{ studentId = $studentId; type = "check_in"; date = $today } | ConvertTo-Json) | Out-Null
    $history = Invoke-RestMethod -Uri "$api/attendance/student/$studentId" -Headers $ph
    if ($history.Count -gt 0) { Pass "Attendance" }
    else { Fail "Attendance" "no parent history" }
} catch { Fail "Attendance" $_.Exception.Message }

try {
    Invoke-RestMethod -Uri "$api/meals/teacher-confirm" -Method POST -Headers $th `
        -ContentType "application/json" `
        -Body (@{ studentId = $studentId; date = $today; mealType = "lunch" } | ConvertTo-Json) | Out-Null
    Invoke-RestMethod -Uri "$api/meals/parent-confirm" -Method POST -Headers $ph `
        -ContentType "application/json" `
        -Body (@{ studentId = $studentId; date = $today; mealType = "lunch" } | ConvertTo-Json) | Out-Null
    $meals = Invoke-RestMethod -Uri "$api/meals/student/$studentId" -Headers $ph
    $todayMeal = $meals | Where-Object { $_.mealType -eq "lunch" } | Select-Object -First 1
    if ($todayMeal.teacherConfirmed -and $todayMeal.parentConfirmed) {
        Pass "Meals dual confirm"
    } else { Fail "Meals" "confirm flags missing" }
} catch { Fail "Meals" $_.Exception.Message }

try {
    Invoke-RestMethod -Uri "$api/admin/banners" -Method POST -Headers $ah `
        -ContentType "application/json" `
        -Body (@{ title = "P2 Banner"; body = "phase 2 test"; target = "all" } | ConvertTo-Json) | Out-Null
    Invoke-RestMethod -Uri "$api/admin/calendar-events" -Method POST -Headers $ah `
        -ContentType "application/json" `
        -Body (@{ title = "P2 Event"; eventType = "event"; startDate = $today } | ConvertTo-Json) | Out-Null
    $pubBanners = Invoke-RestMethod -Uri "$api/banners" -Headers $ph
    $pubEvents = Invoke-RestMethod -Uri "$api/calendar-events" -Headers $ph
    if ($pubBanners.Count -gt 0 -and $pubEvents.Count -gt 0) {
        Pass "Banners and Calendar"
    } else { Fail "Banners/Calendar" "public lists empty" }
} catch { Fail "Banners/Calendar" $_.Exception.Message }

try {
    $pngPath = Join-Path $env:TEMP "phase2-test.png"
    [IO.File]::WriteAllBytes($pngPath, [byte[]](
        0x89,0x50,0x4E,0x47,0x0D,0x0A,0x1A,0x0A,0x00,0x00,0x00,0x0D,
        0x49,0x48,0x44,0x52,0x00,0x00,0x00,0x01,0x00,0x00,0x00,0x01,
        0x08,0x06,0x00,0x00,0x00,0x1F,0x15,0xC4,0x89,0x00,0x00,0x00,
        0x0A,0x49,0x44,0x41,0x54,0x78,0x9C,0x63,0x00,0x01,0x00,0x00,
        0x05,0x00,0x01,0x0D,0x0A,0x2D,0xB4,0x00,0x00,0x00,0x00,0x49,
        0x45,0x4E,0x44,0xAE,0x42,0x60,0x82
    ))
    $curlOut = curl.exe -s -X POST "$api/photos" `
        -H "Authorization: Bearer $($teacher.accessToken)" `
        -F "studentId=$studentId" `
        -F "caption=phase2 test" `
        -F "image=@$pngPath;type=image/png"
    $upload = $curlOut | ConvertFrom-Json
    $photoId = $upload.id
    Invoke-RestMethod -Uri "$api/admin/photos/$photoId/approve" -Method PUT -Headers $ah | Out-Null
    $parentPhotos = Invoke-RestMethod -Uri "$api/photos/student/$studentId" -Headers $ph
    if ($parentPhotos.Count -gt 0) { Pass "Photos upload approve album" }
    else { Fail "Photos" "parent album empty" }
} catch { Fail "Photos" $_.Exception.Message }

Write-Host ""
Write-Host "=== Summary ===" -ForegroundColor Cyan
$results | ForEach-Object { Write-Host $_ }
$failed = @($results | Where-Object { $_ -like '[FAIL]*' }).Count
if ($failed -eq 0) {
    Write-Host ""
    Write-Host "Phase 2 API: ALL PASSED" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "Phase 2 API: $failed failed" -ForegroundColor Red
    exit 1
}
