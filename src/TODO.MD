TODO WINDOWS

- git clone THEV
- [PJ] C:\Windows\System32\drivers\etc\hosts -> x.x.x.x kali
- [PJ] %PATH% \THEV\SYSINTERNALSSUITE
- Powershell Keyboard
[LUK] - GPO's -> Regkeys powershell logging, proc/cmd line logging, windows updates
- Student, Student_adm, ThreatAdmin (password = Threathunt25)
- copy VulnService.exe to C:\MyPrograms\Vulnerable Service
- [PJ] directory permissions /opt subdirectories -> sudo chown -R Threatadmin:Threatadmin /opt/msf

TODO KALI



WINDOWS INSTALLATION PROCEDURES

[-] AZERTY/QWERTY Language Toggle
```powershell
Get-WinUserLanguageList
$LangList = Get-WinUserLanguageList
$LangList.Add("nl-BE")
Set-WinUserLanguageList $LangList -Force
```

[-] Registry keys autoupdate, process and commandline logging, powershell logging
```bash
# --- Disable Automatic Windows Updates Completely ---
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Force -ErrorAction SilentlyContinue | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "NoAutoUpdate" -Value 1 -Force

# --- Restart Windows Update service for changes to take immediate effect ---
Restart-Service -Name wuauserv -Force

# --- Enable PowerShell Script Block Logging ---
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" -Force -ErrorAction SilentlyContinue | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" -Name "EnableScriptBlockLogging" -Value 1 -Force

# --- Enable PowerShell Module Logging ---
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ModuleLogging" -Force -ErrorAction SilentlyContinue | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ModuleLogging" -Name "EnableModuleLogging" -Value 1 -Force

# --- Specify which modules to log (e.g., '*' for all modules) ---
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ModuleLogging\ModuleNames" -Force -ErrorAction SilentlyContinue | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ModuleLogging\ModuleNames" -Name "*" -Value "*" -Force

# --- Set the Registry key to include command-line in process creation events ---
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit" `
    -Name "ProcessCreationIncludeCommandLine" `
    -Value 1 `
    -Force -ErrorAction SilentlyContinue

# Create the 'Audit' key if it doesn't exist (Set-ItemProperty -Force does this for values, but New-Item is explicit for keys)
# Note: If the key already exists, New-Item will throw an error unless -ErrorAction SilentlyContinue is used,
# or you can check for existence first. The 'reg add' command handles key creation automatically.
if (-not (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit")) {
    New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit" -Force | Out-Null
}

# --- Optional: Force Group Policy update to ensure audit policy changes apply ---
gpupdate /force
```

KALI INSTALLATION PROCEDURES

[-] SET LOCALE
```bash 
sudo locale-gen en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
```

[-] AZERTY/QWERTY Language Toggle
```bash
sudo nano ~/.xprofile
setxkbmap -layout be,us -option grp:alt_shift_toggle
```

[-] Updog 2 Install
```bash
pip install updog2 --break-system-packages
```
[-] HAVOC Install
```bash
git clone https://github.com/voidvxvt/Havoc.git

sudo chown -R Threatadmin:Threatadmin Havoc

sudo apt install -y git build-essential apt-utils cmake libfontconfig1 libglu1-mesa-dev libgtest-dev libspdlog-dev libboost-all-dev libncurses5-dev libgdbm-dev libssl-dev libreadline-dev libffi-dev libsqlite3-dev libbz2-dev mesa-common-dev qtbase5-dev qtchooser qt5-qmake qtbase5-dev-tools libqt5websockets5 libqt5websockets5-dev qtdeclarative5-dev golang-go qtbase5-dev libqt5websockets5-dev python3-dev libboost-all-dev mingw-w64 nasm

cd teamserver
go mod download golang.org/x/sys
cd ..

# Install musl Compiler & Build Binary (From Havoc Root Directory)
make ts-build

# Build the client Binary (From Havoc Root Directory)
make client-build

```

[-] METASPLOIT Install
```bash
sudo apt install metasploit-framework -y
sudo mkdir /msf
sudo mkdir /msf/payloads
sudo chown -R Threatadmin:Threatadmin /opt/msf
```
