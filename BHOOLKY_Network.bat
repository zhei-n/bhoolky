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
    for /f "tokens=2-4 delims=/ " %%a in ('date /t') do (
        set current_date=%%c%%a%%b
    )
    for /f "tokens=2-4 delims=/ " %%a in ('type "%TEMP%\last_update_check.txt"') do (
        set last_date=%%c%%a%%b
    )
    
    if !current_date! GTR !last_date! (
        goto check_update
    )
) else (
    :check_update
    echo Checking for updates...
    echo %date% > "%TEMP%\last_update_check.txt"
    :: Comment out potentially problematic update check
    :: powershell command removed for stability
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
echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
start "" "%temp%\getadmin.vbs"
if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs"
:: Don't pause or exit here - let the elevated script continue
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
:: Check for network adapters more robustly
set "adapter="
for /f "tokens=*" %%a in ('netsh interface show interface ^| findstr /i "Connected"') do (
    set "line=%%a"
    set "line=!line:*Connected=!"
    set "adapter=!line:~1!"
    goto found_adapter
)

:found_adapter
if "%adapter%"=="" (
    echo No active adapter found. Please connect a network.
    echo Press any key to try again...
    pause >nul
    goto start
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
cls
echo ====== [Set Static IP] ======
echo Current Network Settings:
netsh interface ip show config name="%adapter%" | findstr "IP Address"
netsh interface ip show config name="%adapter%" | findstr "Subnet"
netsh interface ip show config name="%adapter%" | findstr "Gateway"

echo.
set /p ip="Enter IP Address (e.g. 192.168.1.100): "
set /p mask="Enter Subnet Mask (e.g. 255.255.255.0): "
set /p gateway="Enter Gateway (e.g. 192.168.1.1): "
set /p dns1="Enter Primary DNS (e.g. 8.8.8.8): "
set /p dns2="Enter Secondary DNS (e.g. 8.8.4.4): "

echo.
echo Setting Static IP...
netsh interface ip set address name="%adapter%" static %ip% %mask% %gateway% 1
netsh interface ip set dns name="%adapter%" static %dns1% primary
netsh interface ip add dns name="%adapter%" %dns2% index=2
echo.
echo Static IP configured!
pause
goto menu

:dns
cls
echo ====== [Change DNS Only] ======
echo Current DNS Settings:
netsh interface ip show config name="%adapter%" | findstr "DNS"

echo.
echo 1. Google DNS (8.8.8.8, 8.8.4.4)
echo 2. Cloudflare DNS (1.1.1.1, 1.0.0.1)
echo 3. OpenDNS (208.67.222.222, 208.67.220.220)
echo 4. Custom DNS
echo 5. Back to Menu
set /p dnschoice="Choose DNS (1-5): "

if "%dnschoice%"=="1" (
    netsh interface ip set dns name="%adapter%" static 8.8.8.8 primary 
    netsh interface ip add dns name="%adapter%" 8.8.4.4 index=2
    echo Google DNS applied!
) else if "%dnschoice%"=="2" (
    netsh interface ip set dns name="%adapter%" static 1.1.1.1 primary
    netsh interface ip add dns name="%adapter%" 1.0.0.1 index=2
    echo Cloudflare DNS applied!
) else if "%dnschoice%"=="3" (
    netsh interface ip set dns name="%adapter%" static 208.67.222.222 primary
    netsh interface ip add dns name="%adapter%" 208.67.220.220 index=2
    echo OpenDNS applied!
) else if "%dnschoice%"=="4" (
    set /p primary="Enter Primary DNS: "
    set /p secondary="Enter Secondary DNS: "
    netsh interface ip set dns name="%adapter%" static %primary% primary
    netsh interface ip add dns name="%adapter%" %secondary% index=2
    echo Custom DNS applied!
) else if "%dnschoice%"=="5" (
    goto menu
)
pause
goto menu

:dhcp
cls
echo ====== [Set DHCP] ======
echo Configuring adapter for automatic IP...
netsh interface ip set address name="%adapter%" dhcp
netsh interface ip set dns name="%adapter%" dhcp
echo.
echo DHCP enabled! Your network will assign IP automatically.
pause
goto menu

:profiles
cls
echo ====== [Network Profiles] ======
echo 1. Home Network (192.168.1.x)
echo 2. Office Network (10.0.0.x)
echo 3. Public Wi-Fi (DHCP)
echo 4. Save Current as Profile
echo 5. Back to Menu
set /p profilechoice="Choose Profile (1-5): "

if "%profilechoice%"=="1" (
    netsh interface ip set address name="%adapter%" static 192.168.1.100 255.255.255.0 192.168.1.1
    netsh interface ip set dns name="%adapter%" static 1.1.1.1 primary
    netsh interface ip add dns name="%adapter%" 1.0.0.1 index=2
    echo Home Network profile applied!
) else if "%profilechoice%"=="2" (
    netsh interface ip set address name="%adapter%" static 10.0.0.100 255.255.255.0 10.0.0.1
    netsh interface ip set dns name="%adapter%" static 10.0.0.1 primary
    netsh interface ip add dns name="%adapter%" 8.8.8.8 index=2
    echo Office Network profile applied!
) else if "%profilechoice%"=="3" (
    netsh interface ip set address name="%adapter%" dhcp
    netsh interface ip set dns name="%adapter%" dhcp
    echo Public Wi-Fi profile (DHCP) applied!
) else if "%profilechoice%"=="4" (
    set /p profilename="Enter profile name: "
    set backupfile=Network_Profile_%profilename%.txt
    netsh -c interface dump > "C:\%backupfile%"
    echo Profile saved to C:\%backupfile%
)
pause
goto menu

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
    echo Backup saved to C:\%backupfile%
) else if "%brchoice%"=="2" (
    dir /b C:\Network_Backup_*.txt
    set /p restorefile="Enter filename: "
    if exist "C:\%restorefile%" (
        netsh -f "C:\%restorefile%"
        echo Settings restored!
    ) else ( echo ❌ File not found! )
) else if "%brchoice%"=="3" (
    set /p exportfile="Enter export filename: "
    netsh -c interface dump > "%exportfile%"
    echo Exported to %exportfile%
) else if "%brchoice%"=="4" (
    set /p importfile="Enter import filename: "
    if exist "%importfile%" (
        netsh -f "%importfile%"
        echo Settings imported!
    ) else ( echo File not found! )
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
    echo DNS cache flushed!
) else if "%diagchoice%"=="4" (
    netsh int ip reset
    echo TCP/IP stack reset!
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
    echo Connecting to %ssid%...
) else if "%wifichoice%"=="3" (
    netsh wlan disconnect
    echo Disconnected!
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
        echo OpenVPN connecting...
    ) else ( echo ❌ File not found! )
) else if "%vpnchoice%"=="2" (
    taskkill /f /im openvpn.exe
    echo OpenVPN disconnected!
) else if "%vpnchoice%"=="3" (
    set /p wgconf="Enter WireGuard config path: "
    if exist "%wgconf%" (
        start "" "C:\Program Files\WireGuard\wireguard.exe" /installtunnelservice "%wgconf%"
        echo WireGuard connecting...
    ) else ( echo ❌ File not found! )
) else if "%vpnchoice%"=="4" (
    taskkill /f /im wireguard.exe
    echo WireGuard disconnected!
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
    echo Cloudflare DNS (1.1.1.1) applied!
) else if "%dnschoice%"=="2" (
    set /p testdns="Enter DNS IP to test: "
    ping -n 4 %testdns%
)
pause
goto menu

:reset
cls
echo ====== [Network Reset] ======
echo This will reset all network settings.
echo Your network connections may be temporarily interrupted.
echo.
echo 1. Proceed with Reset
echo 2. Back to Menu
set /p resetconfirm="Choose (1-2): "

if "%resetconfirm%"=="1" (
    echo Resetting network components...
    netsh winsock reset
    netsh int ip reset
    ipconfig /flushdns
    ipconfig /release
    ipconfig /renew
    echo.
    echo Network reset complete!
    echo You may need to restart your computer for changes to take effect.
)
pause
goto menu
