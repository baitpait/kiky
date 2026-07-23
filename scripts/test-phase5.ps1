#Requires -Version 5.1
<#
.SYNOPSIS
  Phase 5 test - Agora live stream API
#>
$api = "http://localhost:3000/api"
$pass = "Test@123456"
$results = @()

. (Join-Path $PSScriptRoot "ensure-test-accounts.ps1")

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

Write-Host "=== Phase 5 Test (Live / Agora) ===" -ForegroundColor Cyan

try {
    $admin = Login "admin" "Admin@123"
    $ah = @{ Authorization = "Bearer $($admin.accessToken)" }
    Pass "Admin login"
} catch {
    Fail "Admin login" $_.Exception.Message
    exit 1
}

$studentId = $null
try {
    $teachers = Invoke-RestMethod -Uri "$api/admin/teachers" -Headers $ah
    $tUser = $teachers | Where-Object { $_.user.username -eq "p5teacher" } | Select-Object -First 1
    if (-not $tUser) {
        try {
            $tUser = Invoke-RestMethod -Uri "$api/admin/teachers" -Method POST -Headers $ah `
                -ContentType "application/json" `
                -Body (@{ username = "p5teacher"; password = $pass; name = "P5 Teacher" } | ConvertTo-Json)
        } catch {
            if ($_.Exception.Response.StatusCode.value__ -eq 409) {
                & (Join-Path $PSScriptRoot "ensure-test-accounts.ps1")
                $teachers = Invoke-RestMethod -Uri "$api/admin/teachers" -Headers $ah
                $tUser = $teachers | Where-Object { $_.user.username -eq "p5teacher" } | Select-Object -First 1
            }
            if (-not $tUser) { throw }
        }
    }

    $parents = Invoke-RestMethod -Uri "$api/admin/parents" -Headers $ah
    $pUser = $parents | Where-Object { $_.user.username -eq "p5parent" } | Select-Object -First 1
    if (-not $pUser) {
        try {
            $pUser = Invoke-RestMethod -Uri "$api/admin/parents" -Method POST -Headers $ah `
                -ContentType "application/json" `
                -Body (@{ username = "p5parent"; password = $pass; name = "P5 Parent" } | ConvertTo-Json)
        } catch {
            if ($_.Exception.Response.StatusCode.value__ -eq 409) {
                & (Join-Path $PSScriptRoot "ensure-test-accounts.ps1")
                $parents = Invoke-RestMethod -Uri "$api/admin/parents" -Headers $ah
                $pUser = $parents | Where-Object { $_.user.username -eq "p5parent" } | Select-Object -First 1
            }
            if (-not $pUser) { throw }
        }
    }

    $students = Invoke-RestMethod -Uri "$api/admin/students" -Headers $ah
    $student = $students | Where-Object { $_.name -eq "Phase5 Student" } | Select-Object -First 1
    if (-not $student) {
        $student = Invoke-RestMethod -Uri "$api/admin/students" -Method POST -Headers $ah `
            -ContentType "application/json" `
            -Body (@{ name = "Phase5 Student"; className = "KG-D" } | ConvertTo-Json)
    }

    try {
        Invoke-RestMethod -Uri "$api/admin/students/$($student.id)/link-teacher" -Method POST -Headers $ah `
            -ContentType "application/json" -Body (@{ teacherId = $tUser.id } | ConvertTo-Json) | Out-Null
    } catch {}
    try {
        Invoke-RestMethod -Uri "$api/admin/students/$($student.id)/link-parent" -Method POST -Headers $ah `
            -ContentType "application/json" -Body (@{ parentId = $pUser.id } | ConvertTo-Json) | Out-Null
    } catch {}

    $studentId = $student.id
    Pass "Test accounts ready (p5teacher/p5parent, student id=$studentId)"
} catch {
    Fail "Test setup" $_.Exception.Message
    exit 1
}

try {
    $teacher = Login "p5teacher" $pass
    $th = @{ Authorization = "Bearer $($teacher.accessToken)" }
    Pass "Teacher login"
} catch { Fail "Teacher login" $_.Exception.Message }

try {
    $parent = Login "p5parent" $pass
    $ph = @{ Authorization = "Bearer $($parent.accessToken)" }
    Pass "Parent login"
} catch { Fail "Parent login" $_.Exception.Message }

$streamId = $null
try {
    $start = Invoke-RestMethod -Uri "$api/live/start" -Method POST -Headers $th `
        -ContentType "application/json" `
        -Body (@{ title = "Phase5 Live Test" } | ConvertTo-Json)
    $streamId = $start.stream.id
    if ($start.agora.token -and $start.agora.role -eq "publisher") {
        Pass "Teacher start live (id=$streamId, demo=$($start.agora.demo))"
    } else {
        Fail "Teacher start live" "missing agora publisher token"
    }
} catch { Fail "Teacher start live" $_.Exception.Message }

try {
    $myActive = Invoke-RestMethod -Uri "$api/live/my-active" -Headers $th
    $activeId = if ($myActive.stream) { [int]$myActive.stream.id } else { [int]$myActive.id }
    if ($activeId -eq $streamId) { Pass "Teacher my-active stream" }
    else { Fail "Teacher my-active" "stream id mismatch" }
} catch { Fail "Teacher my-active" $_.Exception.Message }

try {
    $dup = Invoke-RestMethod -Uri "$api/live/start" -Method POST -Headers $th `
        -ContentType "application/json" `
        -Body (@{ title = "Duplicate" } | ConvertTo-Json)
    if ($dup.resumed -eq $true -and [int]$dup.stream.id -eq $streamId) {
        Pass "Duplicate start resumes same stream"
    } else {
        Fail "Duplicate start resumes" "expected resumed=true same id"
    }
} catch { Fail "Duplicate start resumes" $_.Exception.Message }

try {
    $active = Invoke-RestMethod -Uri "$api/live/active" -Headers $ph
    $found = $active | Where-Object { $_.id -eq $streamId }
    if ($found) { Pass "Parent list active streams" }
    else { Fail "Parent list active" "stream not visible" }
} catch { Fail "Parent list active" $_.Exception.Message }

try {
    $join = Invoke-RestMethod -Uri "$api/live/$streamId/join" -Method POST -Headers $ph
    if ($join.agora.role -eq "audience" -and $join.agora.token) {
        Pass "Parent join as audience"
    } else {
        Fail "Parent join" "missing audience token"
    }
} catch { Fail "Parent join" $_.Exception.Message }

try {
    try {
        Invoke-RestMethod -Uri "$api/live/start" -Method POST -Headers $ph `
            -ContentType "application/json" `
            -Body (@{ title = "Parent hack" } | ConvertTo-Json) -ErrorAction Stop | Out-Null
        Fail "Parent blocked from start" "parent should be forbidden"
    } catch {
        if ($_.Exception.Response.StatusCode.value__ -eq 403) {
            Pass "Parent blocked from start (403)"
        } else {
            Fail "Parent blocked from start" $_.Exception.Message
        }
    }
} catch { Fail "Parent blocked from start" $_.Exception.Message }

try {
    Invoke-RestMethod -Uri "$api/live/end" -Method POST -Headers $th `
        -ContentType "application/json" `
        -Body (@{ streamId = $streamId } | ConvertTo-Json) | Out-Null
    Pass "Teacher end live"
} catch { Fail "Teacher end live" $_.Exception.Message }

try {
    $activeAfter = Invoke-RestMethod -Uri "$api/live/active" -Headers $ph
    $stillActive = $activeAfter | Where-Object { $_.id -eq $streamId }
    if (-not $stillActive) { Pass "Stream removed from active list" }
    else { Fail "Stream removed from active" "still listed" }
} catch { Fail "Stream removed from active" $_.Exception.Message }

try {
    try {
        Invoke-RestMethod -Uri "$api/live/$streamId/join" -Method POST -Headers $ph -ErrorAction Stop | Out-Null
        Fail "Join ended stream blocked" "should fail"
    } catch {
        if ($_.Exception.Response.StatusCode.value__ -eq 404) {
            Pass "Join ended stream blocked (404)"
        } else {
            Fail "Join ended stream blocked" $_.Exception.Message
        }
    }
} catch { Fail "Join ended stream blocked" $_.Exception.Message }

Write-Host ""
Write-Host "=== Summary ===" -ForegroundColor Cyan
$results | ForEach-Object { Write-Host $_ }
$failed = @($results | Where-Object { $_ -like '[FAIL]*' }).Count
if ($failed -eq 0) {
    Write-Host ""
    Write-Host "Phase 5 API: ALL PASSED" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "Phase 5 API: $failed failed" -ForegroundColor Red
    exit 1
}
