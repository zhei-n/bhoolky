# 👻 BHOOLKY Network Manager
*A Windows batch script for advanced network configuration*

## 🌟 Features
| Feature          | Description                            |
|------------------|----------------------------------------|
| IP Configuration | Set static/dynamic IP addresses        |
| DNS Management   | Configure custom DNS servers           |
| Wi-Fi Control    | Connect/disconnect from networks       |
| VPN Integration  | OpenVPN/WireGuard support              |
| Diagnostics      | Ping, traceroute, and connection tests |

## 🖥️ Installation
1. Download the `.bat` file
2. Right-click → "Run as administrator"
3. Follow on-screen menu

## 🖥️ Requirements
- Windows 10/11
- Administrator access
  
## Steps
🖥️ (PowerShell)

$url = "https://raw.githubusercontent.com/Zhei-n/bhoolky/main/BHOOLKY_Network.bat"
$output = "$env:USERPROFILE\Downloads\BHOOLKY_Network.bat"
(New-Object System.Net.WebClient).DownloadFile($url, $output)
Start-Process $output -Verb RunAs

1. [Download the script](BHOOLKY_Network.bat)
2. Right-click → "Run as administrator"
3. Accept UAC prompt
4. Follow menu options

## Troubleshooting
If blocked by Windows:
1. Right-click the file → Properties
2. Check "Unblock" under Security
3. Click "Apply"
