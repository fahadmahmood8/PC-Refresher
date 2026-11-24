@echo off
setlocal EnableExtensions
title Create PC Refresher Task
mode con: cols=110 lines=45 >nul 2>&1

rem ---- real ESC character and color support ----
for /f %%E in ('powershell -NoProfile -Command "[char]27"') do set "ESC=%%E"
reg add "HKCU\Console" /v VirtualTerminalLevel /t REG_DWORD /d 1 /f >nul 2>&1

set "CY=%ESC%[96m"
set "BCY=%ESC%[1;96m"
set "GR=%ESC%[92m"
set "BGR=%ESC%[1;92m"
set "YE=%ESC%[93m"
set "MA=%ESC%[95m"
set "RD=%ESC%[91m"
set "WH=%ESC%[1;97m"
set "RS=%ESC%[0m"

set "TASK=PC Refresher"

rem ---- must be elevated ----
net session >nul 2>&1
if errorlevel 1 (
    echo %RD%ERROR: Right-click this file and choose "Run as administrator".%RS%
    pause
    exit /b 1
)

cls
echo.
echo %BCY%   ____  ____  ____  ____  ____  ____  ____  ____  ____  %RS%
echo %BCY%  ^|  _ \^|  _ \^| ___^|^|  _ \^|  _ \^|  _ \^|  ___^|^|  _ \ %RS%
echo.
echo %MA%                 C R E A T E   T A S K %RS%
echo.

rem ---- get the folder or file path ----
set "TARGET=%~1"
if "%TARGET%"=="" set /p "TARGET=%YE%Folder or full path to refresher.bat: %RS%"
set "TARGET=%TARGET:"=%"

rem ---- remove a trailing backslash ----
if "%TARGET:~-1%"=="\" set "TARGET=%TARGET:~0,-1%"

rem ---- if a folder was given, add refresher.bat to it ----
if exist "%TARGET%\" set "TARGET=%TARGET%\refresher.bat"

if not exist "%TARGET%" (
    echo %RD%[ ERROR ] File not found: %TARGET%%RS%
    pause
    exit /b 1
)
for %%F in ("%TARGET%") do set "TARGET=%%~fF"
echo %GR%[  OK  ] Found script:%RS% %WH%%TARGET%%RS%

rem ---- optional run time as 2nd argument, default 03:00 ----
set "RUNTIME=%~2"
if "%RUNTIME%"=="" set "RUNTIME=03:00"

rem ---- create (or replace) the weekly task ----
schtasks /create /tn "%TASK%" /tr "\"%TARGET%\" /quiet" /sc weekly /d SUN /st %RUNTIME% /ru SYSTEM /rl HIGHEST /f >nul 2>&1
if errorlevel 1 (
    echo %RD%[ ERROR ] Could not create the task.%RS%
    pause
    exit /b 1
)
echo %GR%[  OK  ] Task created:%RS% %WH%%TASK%%RS%
echo %GR%[  OK  ] Linked to:%RS% %WH%%TARGET% /quiet%RS%

rem ---- extra settings: 1 hour limit, run if a run was missed ----
powershell -NoProfile -Command "$s = New-ScheduledTaskSettingsSet -ExecutionTimeLimit (New-TimeSpan -Hours 1) -StartWhenAvailable -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries; Set-ScheduledTask -TaskName '%TASK%' -Settings $s | Out-Null"
if errorlevel 1 (
    echo %YE%[ WARN ] Could not apply extra settings. The task still works.%RS%
) else (
    echo %GR%[  OK  ] Settings applied: 1 hour limit, run if missed%RS%
)

echo.
echo %BGR%  ==========================================================%RS%
echo %BGR%   TASK DETAILS%RS%
echo %BGR%  ==========================================================%RS%
powershell -NoProfile -Command "$t=Get-ScheduledTask -TaskName '%TASK%'; $i=$t|Get-ScheduledTaskInfo; $a=$t.Actions[0]; Write-Host ('   Status     : ' + $t.State) -ForegroundColor Green; Write-Host ('   Next run   : ' + $i.NextRunTime) -ForegroundColor Cyan; Write-Host ('   Runs as    : ' + $t.Principal.UserId) -ForegroundColor Yellow; Write-Host ('   Task to run: ' + $a.Execute + ' ' + $a.Arguments) -ForegroundColor White"
echo %BGR%  ==========================================================%RS%

echo.
pause
exit /b 0