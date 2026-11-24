@echo off
setlocal EnableExtensions
title Remove PC Refresher Task

rem ---- must be elevated ----
net session >nul 2>&1
if errorlevel 1 (
    echo ERROR: Right-click this file and choose "Run as administrator".
    pause
    exit /b 1
)

set "TASK=PC Refresher"

schtasks /query /tn "%TASK%" >nul 2>&1
if errorlevel 1 (
    echo Task "%TASK%" does not exist. Nothing to remove.
    pause
    exit /b 0
)

schtasks /delete /tn "%TASK%" /f
if errorlevel 1 (
    echo ERROR: Could not remove the task.
    pause
    exit /b 1
)

echo.
echo Task "%TASK%" removed.
pause
exit /b 0