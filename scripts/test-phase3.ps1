#Requires -Version 5.1
<#
.SYNOPSIS
  Phase 3 test - homework, stickers, AI flow
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

Write-Host "=== Phase 3 Test ===" -ForegroundColor Cyan

try {
    $admin = Login "admin" "Admin@123"
    $ah = @{ Authorization = "Bearer $($admin.accessToken)" }
    Pass "Admin login"
} catch {
    Fail "Admin login" $_.Exception.Message
    exit 1
}

try {
    $levels = Invoke-RestMethod -Uri "$api/admin/sticker-levels" -Headers $ah
    if ($levels.Count -gt 0) { Pass "Sticker levels ($($levels.Count))" }
    else { Fail "Sticker levels" "empty - run seed" }
} catch { Fail "Sticker levels" $_.Exception.Message }

try {
    $stickers = Invoke-RestMethod -Uri "$api/admin/stickers" -Headers $ah
    if ($stickers.Count -gt 0) { Pass "Stickers ($($stickers.Count))" }
    else { Fail "Stickers" "empty - run seed" }
} catch { Fail "Stickers" $_.Exception.Message }

try {
    $teachers = Invoke-RestMethod -Uri "$api/admin/teachers" -Headers $ah
    $tUser = $teachers | Where-Object { $_.user.username -eq "p3teacher" } | Select-Object -First 1
    if (-not $tUser) {
        Invoke-RestMethod -Uri "$api/admin/teachers" -Method POST -Headers $ah `
            -ContentType "application/json" `
            -Body (@{ username = "p3teacher"; password = $pass; name = "P3 Teacher" } | ConvertTo-Json) | Out-Null
    }
    Pass "Test teacher ready (p3teacher)"
} catch { Fail "Test teacher" $_.Exception.Message }

try {
    $parents = Invoke-RestMethod -Uri "$api/admin/parents" -Headers $ah
    $pUser = $parents | Where-Object { $_.user.username -eq "p3parent" } | Select-Object -First 1
    if (-not $pUser) {
        Invoke-RestMethod -Uri "$api/admin/parents" -Method POST -Headers $ah `
            -ContentType "application/json" `
            -Body (@{ username = "p3parent"; password = $pass; name = "P3 Parent" } | ConvertTo-Json) | Out-Null
    }
    Pass "Test parent ready (p3parent)"
} catch { Fail "Test parent" $_.Exception.Message }

try {
    $students = Invoke-RestMethod -Uri "$api/admin/students" -Headers $ah
    $student = $students | Where-Object { $_.name -eq "Phase3 Student" } | Select-Object -First 1
    if (-not $student) {
        $student = Invoke-RestMethod -Uri "$api/admin/students" -Method POST -Headers $ah `
            -ContentType "application/json" `
            -Body (@{ name = "Phase3 Student"; className = "KG-B" } | ConvertTo-Json)
    }
    $teachers = Invoke-RestMethod -Uri "$api/admin/teachers" -Headers $ah
    $tUser = $teachers | Where-Object { $_.user.username -eq "p3teacher" } | Select-Object -First 1
    $parents = Invoke-RestMethod -Uri "$api/admin/parents" -Headers $ah
    $pUser = $parents | Where-Object { $_.user.username -eq "p3parent" } | Select-Object -First 1
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
} catch { Fail "Student setup" $_.Exception.Message }

try {
    $teacher = Login "p3teacher" $pass
    $th = @{ Authorization = "Bearer $($teacher.accessToken)" }
    Pass "Teacher login"
} catch { Fail "Teacher login" $_.Exception.Message }

try {
    $parent = Login "p3parent" $pass
    $ph = @{ Authorization = "Bearer $($parent.accessToken)" }
    Pass "Parent login"
} catch { Fail "Parent login" $_.Exception.Message }

$homeworkId = $null

try {
    $hw = Invoke-RestMethod -Uri "$api/homeworks" -Method POST -Headers $th `
        -ContentType "application/json" `
        -Body (@{
            studentId = $studentId
            title = "Phase3 Numbers"
            description = "Write numbers 1 to 10"
        } | ConvertTo-Json)
    $homeworkId = $hw.id
    Pass "Create homework (id=$homeworkId)"
} catch { Fail "Create homework" $_.Exception.Message }

try {
    $list = Invoke-RestMethod -Uri "$api/homeworks/student/$studentId" -Headers $ph
    $hw = $list | Where-Object { $_.id -eq $homeworkId } | Select-Object -First 1
    if ($hw.status -eq "assigned") { Pass "Parent sees homework (assigned)" }
    else { Fail "Parent homework" "status=$($hw.status)" }
} catch { Fail "Parent homework list" $_.Exception.Message }

try {
    Invoke-RestMethod -Uri "$api/homeworks/$homeworkId/confirm" -Method PUT -Headers $ph | Out-Null
    $list = Invoke-RestMethod -Uri "$api/homeworks/student/$studentId" -Headers $ph
    $hw = $list | Where-Object { $_.id -eq $homeworkId } | Select-Object -First 1
    if ($hw.status -eq "submitted") { Pass "Parent confirm homework" }
    else { Fail "Parent confirm" "status=$($hw.status)" }
} catch { Fail "Parent confirm" $_.Exception.Message }

try {
    $gradeResult = Invoke-RestMethod -Uri "$api/homeworks/$homeworkId/grade" -Method PUT -Headers $th `
        -ContentType "application/json" `
        -Body (@{ teacherGrade = "Excellent"; teacherNote = "Great job!" } | ConvertTo-Json)
    if ($gradeResult.ai.sticker_id) { Pass "Grade + AI sticker (id=$($gradeResult.ai.sticker_id))" }
    else { Fail "Grade + AI" "no sticker_id" }
} catch { Fail "Grade + AI" $_.Exception.Message }

try {
    $sticker = Invoke-RestMethod -Uri "$api/homeworks/$homeworkId/sticker" -Headers $ph
    if ($sticker.sticker) { Pass "Homework sticker (parent)" }
    else { Fail "Homework sticker" "empty" }
} catch { Fail "Homework sticker" $_.Exception.Message }

try {
    $studentStickers = Invoke-RestMethod -Uri "$api/students/$studentId/stickers" -Headers $ph
    if ($studentStickers.Count -gt 0) { Pass "Student stickers album ($($studentStickers.Count))" }
    else { Fail "Student stickers" "empty" }
} catch { Fail "Student stickers" $_.Exception.Message }

try {
    $active = Invoke-RestMethod -Uri "$api/stickers/active" -Headers $th
    if ($active.Count -gt 0) { Pass "Active stickers for teacher ($($active.Count))" }
    else { Fail "Active stickers" "empty" }
} catch { Fail "Active stickers" $_.Exception.Message }

try {
    $record = $studentStickers | Select-Object -First 1
    $alt = $active | Where-Object { $_.id -ne $record.stickerId } | Select-Object -First 1
    if ($alt) {
        Invoke-RestMethod -Uri "$api/student-stickers/$($record.id)" -Method PUT -Headers $th `
            -ContentType "application/json" `
            -Body (@{ stickerId = $alt.id; note = "Teacher edit" } | ConvertTo-Json) | Out-Null
        Pass "Teacher edit sticker"
    } else {
        Pass "Teacher edit sticker (skipped - one sticker only)"
    }
} catch { Fail "Teacher edit sticker" $_.Exception.Message }

Write-Host ""
Write-Host "=== Summary ===" -ForegroundColor Cyan
$results | ForEach-Object { Write-Host $_ }
$failed = @($results | Where-Object { $_ -like '[FAIL]*' }).Count
Write-Host ""
if ($failed -eq 0) {
    Write-Host "Phase 3 API: ALL PASSED" -ForegroundColor Green
    exit 0
} else {
    Write-Host "Phase 3 API: $failed FAILED" -ForegroundColor Red
    exit 1
}
