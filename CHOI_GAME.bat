@echo off
title Vuc Tham Vinh Cuu - Di San Hu Khong
cd /d "%~dp0"

:: Start backend server if not already running on port 8787
netstat -ano | findstr :8787 >nul
if %errorlevel% neq 0 (
    echo [Khoi dong Server Backend tren cong 8787...]
    start /b "" node "%~dp0server\server.js"
    timeout /t 1 /nobreak >nul
)

:: Launch Game
echo [Dang khoi dong Vuc Tham Vinh Cuu...]
start "" "%~dp0VucThamVinhCuu.exe" --path "%~dp0"
exit
