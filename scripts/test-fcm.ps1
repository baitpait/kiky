#Requires -Version 5.1
<#
.SYNOPSIS
  FCM device token registration API test
#>
$api = "http://localhost:3000/api"
$pass = "Test@123456"

function Pass($name) {
    Write-Host "[OK] $name" -ForegroundColor Green
}

function Fail($name, $msg) {
    Write-Host "[FAIL] $name - $msg" -ForegroundColor Red
    exit 1
}

Write-Host "=== FCM Device Register Test ===" -ForegroundColor Cyan

try {
    $parent = Invoke-RestMethod -Uri "$api/auth/login" -Method POST -ContentType "application/json" `
        -Body (@{ username = "p2parent"; password = $pass } | ConvertTo-Json)
    Pass "Parent login"
} catch {
    Fail "Parent login" $_.Exception.Message
}

$ph = @{ Authorization = "Bearer $($parent.accessToken)" }
$token = "test-fcm-$(Get-Date -Format 'yyyyMMddHHmmss')"

try {
    $reg = Invoke-RestMethod -Uri "$api/devices/register" -Method POST -Headers $ph `
        -ContentType "application/json" `
        -Body (@{ token = $token; platform = "android" } | ConvertTo-Json)
    if ($reg.token -eq $token) { Pass "Register device token" }
    else { Fail "Register device token" "unexpected response" }
} catch {
    Fail "Register device token" $_.Exception.Message
}

try {
    $reg2 = Invoke-RestMethod -Uri "$api/devices/register" -Method POST -Headers $ph `
        -ContentType "application/json" `
        -Body (@{ token = $token; platform = "android" } | ConvertTo-Json)
    Pass "Upsert same token (idempotent)"
} catch {
    Fail "Upsert same token" $_.Exception.Message
}

try {
    Invoke-RestMethod -Uri "$api/devices/register" -Method POST -Headers $ph `
        -ContentType "application/json" `
        -Body (@{ token = ""; platform = "android" } | ConvertTo-Json) | Out-Null
    Fail "Empty token validation" "expected 400"
} catch {
    if ($_.Exception.Response.StatusCode.value__ -eq 400) {
        Pass "Empty token rejected (400)"
    } else {
        Fail "Empty token validation" $_.Exception.Message
    }
}

Write-Host ""
Write-Host "FCM API: ALL PASSED" -ForegroundColor Green
exit 0
