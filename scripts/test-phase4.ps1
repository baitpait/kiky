#Requires -Version 5.1
<#
.SYNOPSIS
  Phase 4 test - chat REST + WebSocket
#>
$api = "http://localhost:3000/api"
$pass = "Test@123456"
$results = @()
$root = Split-Path -Parent $PSScriptRoot

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

Write-Host "=== Phase 4 Test (Chat) ===" -ForegroundColor Cyan

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
    $tUser = $teachers | Where-Object { $_.user.username -eq "p4teacher" } | Select-Object -First 1
    if (-not $tUser) {
        $tUser = Invoke-RestMethod -Uri "$api/admin/teachers" -Method POST -Headers $ah `
            -ContentType "application/json" `
            -Body (@{ username = "p4teacher"; password = $pass; name = "P4 Teacher" } | ConvertTo-Json)
    }

    $parents = Invoke-RestMethod -Uri "$api/admin/parents" -Headers $ah
    $pUser = $parents | Where-Object { $_.user.username -eq "p4parent" } | Select-Object -First 1
    if (-not $pUser) {
        $pUser = Invoke-RestMethod -Uri "$api/admin/parents" -Method POST -Headers $ah `
            -ContentType "application/json" `
            -Body (@{ username = "p4parent"; password = $pass; name = "P4 Parent" } | ConvertTo-Json)
    }

    $students = Invoke-RestMethod -Uri "$api/admin/students" -Headers $ah
    $student = $students | Where-Object { $_.name -eq "Phase4 Student" } | Select-Object -First 1
    if (-not $student) {
        $student = Invoke-RestMethod -Uri "$api/admin/students" -Method POST -Headers $ah `
            -ContentType "application/json" `
            -Body (@{ name = "Phase4 Student"; className = "KG-C" } | ConvertTo-Json)
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
    Pass "Test accounts ready (p4teacher/p4parent, student id=$studentId)"
} catch {
    Fail "Test setup" $_.Exception.Message
    exit 1
}

try {
    $teacher = Login "p4teacher" $pass
    $th = @{ Authorization = "Bearer $($teacher.accessToken)" }
    Pass "Teacher login"
} catch { Fail "Teacher login" $_.Exception.Message }

try {
    $parent = Login "p4parent" $pass
    $ph = @{ Authorization = "Bearer $($parent.accessToken)" }
    Pass "Parent login"
} catch { Fail "Parent login" $_.Exception.Message }

$convId = $null
try {
    $conv = Invoke-RestMethod -Uri "$api/conversations" -Method POST -Headers $ph `
        -ContentType "application/json" `
        -Body (@{ studentId = $studentId } | ConvertTo-Json)
    $convId = $conv.id
    if ($convId) { Pass "Parent open conversation (id=$convId)" }
    else { Fail "Open conversation" "no id returned" }
} catch { Fail "Open conversation" $_.Exception.Message }

try {
    $msg = Invoke-RestMethod -Uri "$api/conversations/$convId/messages" -Method POST -Headers $ph `
        -ContentType "application/json" `
        -Body (@{ body = "Hello from parent REST" } | ConvertTo-Json)
    if ($msg.body -eq "Hello from parent REST") { Pass "Parent send message REST" }
    else { Fail "Parent send message" "unexpected body" }
} catch { Fail "Parent send message" $_.Exception.Message }

try {
    $tConvs = Invoke-RestMethod -Uri "$api/conversations" -Headers $th
    $found = $tConvs | Where-Object { $_.id -eq $convId }
    if ($found) { Pass "Teacher list conversations" }
    else { Fail "Teacher list conversations" "conversation not visible" }
} catch { Fail "Teacher list conversations" $_.Exception.Message }

try {
    $tMsg = Invoke-RestMethod -Uri "$api/conversations/$convId/messages" -Method POST -Headers $th `
        -ContentType "application/json" `
        -Body (@{ body = "Hello from teacher REST" } | ConvertTo-Json)
    if ($tMsg.body -eq "Hello from teacher REST") { Pass "Teacher send message REST" }
    else { Fail "Teacher send message" "unexpected body" }
} catch { Fail "Teacher send message" $_.Exception.Message }

try {
    $history = Invoke-RestMethod -Uri "$api/conversations/$convId/messages" -Headers $ph
    if ($history.Count -ge 2) { Pass "Get messages ($($history.Count))" }
    else { Fail "Get messages" "expected at least 2 messages" }
} catch { Fail "Get messages" $_.Exception.Message }

try {
    Invoke-RestMethod -Uri "$api/conversations/$convId/read" -Method PUT -Headers $ph | Out-Null
    Pass "Mark conversation read"
} catch { Fail "Mark read" $_.Exception.Message }

try {
    $pngPath = Join-Path $env:TEMP "phase4-chat.png"
    [IO.File]::WriteAllBytes($pngPath, [byte[]](
        0x89,0x50,0x4E,0x47,0x0D,0x0A,0x1A,0x0A,0x00,0x00,0x00,0x0D,
        0x49,0x48,0x44,0x52,0x00,0x00,0x00,0x01,0x00,0x00,0x00,0x01,
        0x08,0x06,0x00,0x00,0x00,0x1F,0x15,0xC4,0x89,0x00,0x00,0x00,
        0x0A,0x49,0x44,0x41,0x54,0x78,0x9C,0x63,0x00,0x01,0x00,0x00,
        0x05,0x00,0x01,0x0D,0x0A,0x2D,0xB4,0x00,0x00,0x00,0x00,0x49,
        0x45,0x4E,0x44,0xAE,0x42,0x60,0x82
    ))
    $curlOut = curl.exe -s -X POST "$api/conversations/$convId/attachments" `
        -H "Authorization: Bearer $($parent.accessToken)" `
        -F "body=phase4 image" `
        -F "file=@$pngPath;type=image/png"
    $attach = $curlOut | ConvertFrom-Json
    if ($attach.attachments -and $attach.attachments.Count -gt 0) {
        Pass "Chat image attachment"
    } else {
        Fail "Chat image attachment" "no attachments in response"
    }
} catch { Fail "Chat image attachment" $_.Exception.Message }

try {
    try {
        Invoke-RestMethod -Uri "$api/conversations" -Headers $ah -ErrorAction Stop | Out-Null
        Fail "Admin blocked from chat" "admin should be forbidden"
    } catch {
        if ($_.Exception.Response.StatusCode.value__ -eq 403) {
            Pass "Admin blocked from chat (403)"
        } else {
            Fail "Admin blocked from chat" $_.Exception.Message
        }
    }
} catch { Fail "Admin blocked from chat" $_.Exception.Message }

if ($convId) {
    try {
        $wsScript = Join-Path $root "scripts\ws-chat-test.js"
        $wsMsg = "WS test $(Get-Date -Format 'HHmmss')"
        $wsOut = node $wsScript $teacher.accessToken $convId $wsMsg 2>&1
        if ($LASTEXITCODE -eq 0 -and ($wsOut -match "OK")) {
            Pass "WebSocket send/receive"
        } else {
            Fail "WebSocket send/receive" ($wsOut -join " ")
        }
    } catch {
        Fail "WebSocket send/receive" $_.Exception.Message
    }
}

Write-Host ""
Write-Host "=== Summary ===" -ForegroundColor Cyan
$results | ForEach-Object { Write-Host $_ }
$failed = @($results | Where-Object { $_ -like '[FAIL]*' }).Count
if ($failed -eq 0) {
    Write-Host ""
    Write-Host "Phase 4 API: ALL PASSED" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "Phase 4 API: $failed failed" -ForegroundColor Red
    exit 1
}
