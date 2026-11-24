@echo off
setlocal EnableExtensions EnableDelayedExpansion
title PC Refresher
mode con: cols=120 lines=60 >nul 2>&1

rem --- real ESC character (fixes colors) ---
for /f %%E in ('powershell -NoProfile -Command "[char]27"') do set "ESC=%%E"

rem --- make sure this console understands color codes ---
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

set "LOG=%SystemRoot%\Temp\cleanup_log.txt"
set "BARFULL=############################################################"
set "BARLEFT=------------------------------------------------------------"

net session >nul 2>&1
if errorlevel 1 (
    echo %RD%ERROR: Run this file as Administrator ^(right-click, Run as administrator^).%RS%
    if /i not "%~1"=="/quiet" pause
    exit /b 1
)

cls
echo.
echo %BCY%    ####   ####   ####  ####  ####  ####  ####  ####  ####  ####  %RS%
echo %BCY%    #   #  #   #  #     #     #     #     #  #  #     #      #   %RS%
echo %BCY%    ####   ####   #     ####  ####  #  #  ###   ####  ####  #   %RS%
echo.
echo %BGR%   ____  ____  ____  ____  ____  ____  ____  ____  ____  ____  ____  %RS%
echo.
echo %BCY%         ####   ####   ####  ####  ####  ####  ####  ####  ####  ####  %RS%
echo.
echo %MA%                         P C   R E F R E S H E R %RS%
echo %WH%                    Cache and temp cleanup%RS%
echo.
echo %YE%                    Running on %COMPUTERNAME%, drive %SystemDrive%%RS%
echo.

set /a USERS=0
for /d %%U in ("%SystemDrive%\Users\*") do set /a USERS+=1
set /a TOTAL=6+8*USERS
set /a DONE=0

call :freemb FREE_START

echo %YE%Stopping update services...%RS%
for %%S in (wuauserv bits dosvc) do net stop %%S /y >nul 2>&1

call :wipe "%SystemRoot%\Temp" "Windows temp"
call :wipe "%SystemRoot%\SoftwareDistribution\Download" "Windows Update download cache"
call :wipe "%ProgramData%\Microsoft\Windows\WER\ReportQueue" "Error report queue"
call :wipe "%ProgramData%\Microsoft\Windows\WER\ReportArchive" "Error report archive"
call :wipe "%TEMP%" "Current user temp"

call :step "Recycle bin"
powershell -NoProfile -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue" >nul 2>&1
echo %GR%   emptied%RS%

for /d %%U in ("%SystemDrive%\Users\*") do (
    call :wipe "%%~U\AppData\Local\Temp" "%%~nxU temp"
    call :wipe "%%~U\AppData\Local\D3DSCache" "%%~nxU D3D shader cache"
    call :wipe "%%~U\AppData\Local\Microsoft\Windows\INetCache" "%%~nxU internet cache"
    call :wipe "%%~U\AppData\Local\Google\Chrome\User Data\Default\Cache" "%%~nxU Chrome cache"
    call :wipe "%%~U\AppData\Local\Google\Chrome\User Data\Default\Code Cache" "%%~nxU Chrome code cache"
    call :wipe "%%~U\AppData\Local\Microsoft\Edge\User Data\Default\Cache" "%%~nxU Edge cache"
    call :wipe "%%~U\AppData\Local\Microsoft\Edge\User Data\Default\Code Cache" "%%~nxU Edge code cache"
    call :step "%%~nxU thumbnail cache"
    del /f /q "%%~U\AppData\Local\Microsoft\Windows\Explorer\thumbcache_*.db" >nul 2>&1
    echo %GR%   done%RS%
)

echo.
echo %YE%Restarting update services...%RS%
for %%S in (dosvc bits wuauserv) do net start %%S >nul 2>&1

call :freemb FREE_END
set /a FREED=FREE_END-FREE_START

echo.
echo %BGR%  ==============================================================%RS%
echo %BGR%  ||                                                          ||%RS%
echo %WH%  ||   FREE SPACE ON %SystemDrive%   %FREE_START% MB  -^>  %FREE_END% MB%RS%
echo %BGR%  ||                                                          ||%RS%
echo %BGR%  ||   %BGR%SPACE RECOVERED:  %BCY%%FREED% MB%BGR%                           ||%RS%
echo %BGR%  ||                                                          ||%RS%
echo %BGR%  ==============================================================%RS%

echo %date% %time% START - recovered %FREED% MB (free %FREE_START% to %FREE_END% MB)>>"%LOG%"
echo.
if /i not "%~1"=="/quiet" pause
exit /b 0


:step
set /a DONE+=1
if %DONE% GTR %TOTAL% set /a TOTAL=DONE
set /a PCT=DONE*100/TOTAL
set /a FILL=PCT*60/100
set /a REST=60-FILL
echo.
echo %BCY%[!BARFULL:~0,%FILL%!!BARLEFT:~0,%REST%!] %PCT%%%%RS%
echo %YE%  %~1%RS%
exit /b 0


:wipe
call :step "%~2"
if not exist "%~1" (
    echo %WH%   skipped, not found%RS%
    exit /b 0
)
set "WIPEPATH=%~1"
set "SZ=0"
for /f %%s in ('powershell -NoProfile -Command "$p=$env:WIPEPATH; $s=(Get-ChildItem -LiteralPath $p -Recurse -File -Force -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum; if(-not $s){$s=0}; [math]::Round($s/1MB,1)"') do set "SZ=%%s"
del /f /s /q "%~1\*" >nul 2>&1
for /d %%D in ("%~1\*") do rd /s /q "%%~D" >nul 2>&1
echo %GR%   found %SZ% MB, cleared%RS%
exit /b 0


:freemb
for /f %%f in ('powershell -NoProfile -Command "[math]::Floor((Get-PSDrive -Name %SystemDrive:~0,1%).Free/1MB)"') do set "%~1=%%f"
exit /b 0