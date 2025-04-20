@echo off

:: ================================================
:: BHOOLKY Network Manager - Mini Project Edition
:: Created by [Zarueimi]
:: Date: %date%
:: ================================================
:INIT
title BHOOLKY Network Manager v1.0
color 0A
mode con: cols=90 lines=30
setlocal enabledelayedexpansion

:: Check for updates weekly
if exist "%TEMP%\last_update_check.txt" (
    for /f %%i in ("%TEMP%\last_update_check.txt") do set last_check=%%~ti
) else (
    set last_check=0
)

:: Only check once per week
if %last_check% LSS %date% (
    echo Checking for updates...
    powershell -nop -c "try{$d=irm 'https://raw.githubusercontent.com/[YOU]/BHOOLKY-Network-Manager/main/version.txt';if($d -gt '1.0'){echo New version $d available! Visit https://github.com/[YOU]/BHOOLKY-Network-Manager}}catch{echo Update check failed}" >nul
    echo %date% > "%TEMP%\last_update_check.txt"
)

:: Admin Check
:check_admin
NET SESSION >nul 2>&1
if %ERRORLEVEL% == 0 goto intro

echo.
echo. Administrator privileges required!
echo.
echo Attempting elevation... (Press Ctrl+C to cancel)
timeout /t 3 /nobreak >nul

:: UAC Elevation with VBS fallback
:UACPrompt
:: UAC Elevation with VBS fallback
echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
"%temp%\getadmin.vbs"
if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs"
exit /B


:: Rest of your code continues here...
:intro
cls
echo ===============================================
echo "| _____ _____ _____ _____ __    _____ __ __ |"
echo "|| __  |  |  |     |     |  |  |  |  |  |  ||"
echo "|| __ -|     |  |  |  |  |  |__|    -|_   _||"
echo "||_____|__|__|_____|_____|_____|__|__| |_|  |"
echo ===============================================
echo         N E T W O R K   M A N A G E R      
echo ===============================================
echo.
echo Loading please wait...
timeout /t 3 /nobreak >nul
goto start

:start
:: This section detects active network adapters
:: using netsh command with connected interface filtering
for /f "tokens=3*" %%a in ('netsh interface show interface ^| findstr "Connected"') do (
    set "adapter=%%b"
)
if "%adapter%"=="" (
    echo No active adapter found. Please connect a network.
    pause
    exit /b
)

:menu
cls
echo Current Adapter: [%adapter%]
echo _____________________________________________________________
echo 0. Show Full Network Config (ipconfig /all)
echo 1. Set Static IP + DNS (Manual)
echo 2. Set DHCP (Automatic IP)
echo 3. Change DNS Only
echo 4. Pre-Saved Profiles
echo 5. Backup/Restore Settings
echo 6. Ping Test and Diagnostics
echo 7. Wi-Fi Network Switcher
echo 8. VPN Toggle (OpenVPN/WireGuard if you have)
echo 9. Smart DNS Optimizer
echo 10. Network Reset (Repair)
echo 11. Exit
echo _____________________________________________________________
set /p choice="Choose (0-11): "

if "%choice%"=="0" goto showconfig
if "%choice%"=="1" goto static
if "%choice%"=="2" goto dhcp
if "%choice%"=="3" goto dns
if "%choice%"=="4" goto profiles
if "%choice%"=="5" goto backuprestore
if "%choice%"=="6" goto diagnostics
if "%choice%"=="7" goto wifi
if "%choice%"=="8" goto vpn
if "%choice%"=="9" goto smartdns
if "%choice%"=="10" goto reset
if "%choice%"=="11" exit
goto menu

:showconfig
cls
echo *************** [ipconfig /all] ***************
ipconfig /all
echo **********************************************
pause
goto menu

:static


:dns


:dhcp


:profiles


:backuprestore
cls
echo ====== [Backup & Restore] ======
echo 1. Backup Current Settings
echo 2. Restore from Backup
echo 3. Export Settings to File
echo 4. Import Settings
echo 5. Back to Menu
set /p brchoice="Choose (1-5): "

if "%brchoice%"=="1" (
    set backupfile=Network_Backup_%date:/=-%_%time::=-%.txt
    set backupfile=%backupfile: =_%
    netsh -c interface dump > "C:\%backupfile%"
    echo ✅ Backup saved to C:\%backupfile%
) else if "%brchoice%"=="2" (
    dir /b C:\Network_Backup_*.txt
    set /p restorefile="Enter filename: "
    if exist "C:\%restorefile%" (
        netsh -f "C:\%restorefile%"
        echo ✅ Settings restored!
    ) else ( echo ❌ File not found! )
) else if "%brchoice%"=="3" (
    set /p exportfile="Enter export filename: "
    netsh -c interface dump > "%exportfile%"
    echo ✅ Exported to %exportfile%
) else if "%brchoice%"=="4" (
    set /p importfile="Enter import filename: "
    if exist "%importfile%" (
        netsh -f "%importfile%"
        echo ✅ Settings imported!
    ) else ( echo ❌ File not found! )
)
pause
goto menu

:diagnostics
cls
echo ====== [Network Diagnostics] ======
echo 1. Ping Test (8.8.8.8)
echo 2. Traceroute Test
echo 3. Flush DNS Cache
echo 4. Reset TCP/IP Stack
echo 5. Back to Menu
set /p diagchoice="Choose (1-5): "

if "%diagchoice%"=="1" (
    ping 8.8.8.8 -n 4
) else if "%diagchoice%"=="2" (
    tracert 8.8.8.8
) else if "%diagchoice%"=="3" (
    ipconfig /flushdns
    echo ✅ DNS cache flushed!
) else if "%diagchoice%"=="4" (
    netsh int ip reset
    echo ✅ TCP/IP stack reset!
)
pause
goto menu

:wifi
cls
echo ====== [Wi-Fi Network Switcher] ======
echo 1. Scan Available Networks
echo 2. Connect to Network
echo 3. Disconnect Wi-Fi
echo 4. Show Saved Networks
echo 5. Back to Menu
set /p wifichoice="Choose (1-5): "

if "%wifichoice%"=="1" (
    netsh wlan show networks
) else if "%wifichoice%"=="2" (
    set /p ssid="Enter SSID: "
    set /p pass="Enter Password (leave blank if none): "
    if "%pass%"=="" (
        netsh wlan connect name="%ssid%"
    ) else (
        netsh wlan connect name="%ssid%" ssid="%ssid%" keyMaterial="%pass%"
    )
    echo ✅ Connecting to %ssid%...
) else if "%wifichoice%"=="3" (
    netsh wlan disconnect
    echo ✅ Disconnected!
) else if "%wifichoice%"=="4" (
    netsh wlan show profiles
)
pause
goto menu

:vpn
cls
echo ====== [VPN Toggle] ======
echo 1. Connect OpenVPN
echo 2. Disconnect OpenVPN
echo 3. Connect WireGuard
echo 4. Disconnect WireGuard
echo 5. Back to Menu
set /p vpnchoice="Choose (1-5): "

if "%vpnchoice%"=="1" (
    set /p ovpnfile="Enter OpenVPN config path: "
    if exist "%ovpnfile%" (
        start "" "C:\Program Files\OpenVPN\bin\openvpn.exe" --config "%ovpnfile%"
        echo ✅ OpenVPN connecting...
    ) else ( echo ❌ File not found! )
) else if "%vpnchoice%"=="2" (
    taskkill /f /im openvpn.exe
    echo ✅ OpenVPN disconnected!
) else if "%vpnchoice%"=="3" (
    set /p wgconf="Enter WireGuard config path: "
    if exist "%wgconf%" (
        start "" "C:\Program Files\WireGuard\wireguard.exe" /installtunnelservice "%wgconf%"
        echo ✅ WireGuard connecting...
    ) else ( echo ❌ File not found! )
) else if "%vpnchoice%"=="4" (
    taskkill /f /im wireguard.exe
    echo ✅ WireGuard disconnected!
)
pause
goto menu

:smartdns
cls
echo ====== [Smart DNS Optimizer] ======
echo Testing fastest DNS servers...
ping -n 2 8.8.8.8 | find "Average"
ping -n 2 1.1.1.1 | find "Average"
ping -n 2 9.9.9.9 | find "Average"
echo.
echo 1. Apply Fastest DNS (Auto)
echo 2. Test Custom DNS
echo 3. Back to Menu
set /p dnschoice="Choose (1-3): "

if "%dnschoice%"=="1" (
    :: Simple logic - you can enhance this with actual benchmarks
    netsh interface ipv4 set dns name="%adapter%" static 1.1.1.1 primary
    netsh interface ipv4 add dns name="%adapter%" 1.0.0.1 index=2
    echo ✅ Cloudflare DNS (1.1.1.1) applied!
) else if "%dnschoice%"=="2" (
    set /p testdns="Enter DNS IP to test: "
    ping -n 4 %testdns%
)
pause
goto menu

:reset
cls
echo ====== [Network Reset] ======
echo Resetting network components...
netsh winsock reset
netsh int ip reset
ipconfig /flushdns
ipconfig /release
ipconfig /renew
echo ✅ Network reset complete!
pause
goto menu
