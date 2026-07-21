@echo off
title Kiddy Link - GitHub Upload
echo.
echo === رفع Kiddy Link على GitHub ===
echo    حساب: nahlahalbostnje
echo    repo:  kiddy-link
echo.

where gh >nul 2>&1
if errorlevel 1 (
    echo [!] GitHub CLI غير مثبت. شغّل: winget install GitHub.cli
    pause
    exit /b 1
)

echo [1/3] تسجيل الدخول في GitHub...
echo       اختر: GitHub.com - HTTPS - Login with browser
gh auth login -h github.com -p https -w
if errorlevel 1 (
    echo [!] فشل تسجيل الدخول
    pause
    exit /b 1
)

echo.
echo [2/3] انشاء repo ورفع الكود...
cd /d "E:\Eman Project"
gh repo create kiddy-link --private --source=. --remote=origin --description "Kiddy Link - Flutter + NestJS" --push 2>nul
if errorlevel 1 (
    echo       Repo موجود — رفع مباشر...
    git push -u origin master
)

echo.
echo [3/3] تم!
echo       https://github.com/nahlahalbostnje/kiddy-link
echo.
start https://github.com/nahlahalbostnje/kiddy-link
pause
