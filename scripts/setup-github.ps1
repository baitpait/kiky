#Requires -Version 5.1
<#
.SYNOPSIS
  Create GitHub repo and push Kiddy Link (first-time setup)
#>
$ErrorActionPreference = "Stop"
$root = "E:\Eman Project"

# Refresh PATH after gh install
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host "[FAIL] GitHub CLI (gh) not installed." -ForegroundColor Red
    Write-Host "Install: winget install GitHub.cli" -ForegroundColor Yellow
    exit 1
}

Push-Location $root

Write-Host "=== Kiddy Link — GitHub Setup ===" -ForegroundColor Cyan

# Login check
try {
    gh auth status 2>&1 | Out-Null
} catch {
    Write-Host ""
    Write-Host "[*] Not logged in to GitHub. Browser login will open..." -ForegroundColor Yellow
    Write-Host "    Choose: GitHub.com -> HTTPS -> Login with browser" -ForegroundColor DarkGray
    gh auth login -h github.com -p https -w
}

$login = $null
try {
    $login = gh api user -q .login 2>$null
} catch {}

if (-not $login) {
    $login = "nahlahalbostnje"
    Write-Host "[*] Using GitHub username: $login (login with: gh auth login)" -ForegroundColor Yellow
} else {
    Write-Host "[OK] GitHub user: $login" -ForegroundColor Green
}

$repoName = "kiddy-link"
if (git remote get-url origin 2>$null) {
    Write-Host "[OK] Remote origin already set" -ForegroundColor Green
    git remote -v
} else {
    Write-Host "[*] Creating repo: $login/$repoName (private)..." -ForegroundColor Yellow
    gh repo create $repoName `
        --private `
        --source=. `
        --remote=origin `
        --description "Kiddy Link — Connecting Home & Kindergarten (Flutter + NestJS)" `
        --push
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[!] Create failed — maybe repo exists. Trying to link..." -ForegroundColor Yellow
        git remote add origin "https://github.com/$login/$repoName.git" 2>$null
        git push -u origin master
    }
}

if (-not (git remote get-url origin 2>$null)) {
    Write-Host "[FAIL] Could not set remote" -ForegroundColor Red
    exit 1
}

# Push if not pushed yet
$branch = git branch --show-current
$ahead = git rev-list --count "origin/$branch" 2>$null
if ($LASTEXITCODE -ne 0 -or (git status -sb | Select-String '\[ahead')) {
    Write-Host "[*] Pushing to origin/$branch ..." -ForegroundColor Yellow
    git push -u origin $branch
}

$url = gh repo view --json url -q .url
Write-Host ""
Write-Host "[OK] GitHub ready: $url" -ForegroundColor Green
Pop-Location
