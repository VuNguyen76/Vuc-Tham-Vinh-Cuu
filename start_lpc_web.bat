@echo off
title Universal LPC Spritesheet Generator
echo ===================================================
echo   Dang khoi chay Universal LPC Spritesheet Generator
echo   Truy cap trinh duyet tai: http://localhost:5173
echo ===================================================
cd /d "%~dp0tools\lpc_generator"
call npm run dev -- --open
pause
