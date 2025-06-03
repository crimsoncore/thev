# DLL Hijacking/Sideloading

> WHAT ARE DLLs : At its core, a Dynamic Link Library (DLL) is a file containing code and data that multiple programs can use simultaneously. DLLs are a crucial component in the Windows operating system because Windows heavily relies on them for pretty much anything. Think of it as a shared repository of functionality, accessible to any application that needs it. Unlike static libraries, which are integrated into an application at compile time, DLLs are loaded into memory at runtime, providing a level of flexibility and modularity that is essential for software integrity. Each process started on Windows uses DLLs in order to operate properly. Additionally, DLLs can be also custom made, which means that for different software vendors, dedicated DLLs can be encountered. Usually they are programmed in C/C++, however, this is not the only option. 

> ***IMPORTANT***: We achieve not only `Privilege Escalation`, but also `code-execution` and `persistence`!!!

> Additionally, DLL Hijacking bypasses application whitelisteng (applocker/WDAC) and breaks the EDR execution chain, as the DLL is loaded by a signed microsoft executable (i.e. Onedrive), dns/http requests are no longer abnormal

# DLL Hijack/Sideloading
<https://www.bordergate.co.uk/windows-privilege-escalation/#DLL-Hijacking>
The following code can be used to create a malicious DLL:

Bring your own vulnerable signed MS binary:

OLEVIEW

Why? EDR's will check if dll's loaded by LOL windows binaries happen from the right directory - by dropping a signed binary that is not present on the file system, we evding that detection.

Additionally OLEVIEW will

```c
#include <windows.h>

BOOL WINAPI DllMain(HINSTANCE h, DWORD r, LPVOID p) {
    if (r == DLL_PROCESS_ATTACH) {
        MessageBoxW(NULL, L"DLL sideload successful!", L"Debug", MB_OK | MB_ICONINFORMATION);
    }
    return TRUE;
}
```
Compile with:

```code
x86_64-w64-mingw32-gcc windows_dll.c -shared -o hijack.dll
```

# DLL Hijacking
onedrive -> Appdata -> cscapi.dll

- writeable by all users
- hijackable

> EXPORTS -> use exported functions in your dll (csharp dll's don't have a dllmain function)

### 1. NIRSOFT ddlexport viewer

![image](./images/dll_exportviewer.jpg)

### 2. ROHITAB API Monitor
![image](./images/dll_apimon.jpg)

### 3. SYSINTERNALS Process Monitor
![image](./images/dll_procmon.jpg)

### 4. DUMPBIN (Visual Studio)

Check which function onedrive actually imports from VERSION.dll

Open a visual studio developer prompt:

![image](./images/dll_devprompt.jpg)

```bash
cd C:\Users\Threatadmin\AppData\Local\Microsoft\OneDrive
dumpbin OneDrive.exe /imports:VERSION.dll
```
![image](./images/dll_dumpbin.jpg)


# AUTOMTING DLL Sideloadble applications
<https://github.com/Cybereason/siofra>

![image](./images/dll_siofra.jpg)


<https://hijacklibs.net/>

https://juggernaut-sec.com/dll-hijacking/#Hijacking_the_Service_DLL_to_get_a_SYSTEM_Shell

![image](./images/dllsearch.jpg)

# C dll

building your dll

<https://github.com/Pascal-0x90/sideloadr>
<https://github.com/Pascal-0x90/sideloadr/compare/master...WS-G:sideloadr:master>


```bash
rundll32 shell32.dll,Control_RunDLL c:\thev\labs\DLL_Sideloading\version.dll
```

LoaderLock!!!

<https://www.prodefense.io/blog/dll-sideloading>

# BYOB (Bring Your own Binary)
OLEVIEW

# DETECTION

Use sysmon to look for loading of known system32/syswow dll's that are :
- not signed
- not loaded from their usual locaction (system32/syswow)

<https://github.com/TactiKoolSec/SideLoadHunter>

```yaml
<Sysmon schemaversion="4.32">
   <!-- Capture all hashes -->
   <HashAlgorithms>*</HashAlgorithms>
   <DnsLookup>False</DnsLookup>
   <ArchiveDirectory>Archive</ArchiveDirectory>
   <EventFiltering>
		<RuleGroup name="onedrivestandaloneupdater_sideload" groupRelation="and">
			<!-- Log only image loads where modules match these conditions -->
			<ImageLoad onmatch="include">
				<Image condition="contains">onedrivestandaloneupdater.exe</Image>
				<ImageLoaded condition="contains">wofutil.dll</ImageLoaded>
				<Signature condition="is not">Microsoft Windows</Signature>
			</ImageLoad>
		</RuleGroup>
  </EventFiltering>
</Sysmon>
```
>Custom detection rules for known Windows DLLs being loaded from non Windows path’s such as System32 could also be used to identify DLL Sideloading attacks. Doing this for non Windows DLLs however is not that easy, as there are too many different vendors and binaries/DLLs to track all of them.