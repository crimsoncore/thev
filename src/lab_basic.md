# Lab - Basic Loader

> When building a shellcode loader, you can use any coding language, c, c++, c#, powershell, rust, golang and so on. In general, detection rates for languages like golang, rust and nim are lower, they are much harder to analyze and reverse than standard c or c# code. In this training we''l be using C as our language, as it is a low level programming language (no CLR that does JIT compiling like with C# or powershell), remember most windows API functions are written in C/C++ as well.

## Advantages of Using C on Windows

### Direct Access to Windows API:
- Native integration with core Windows features like process management, file I/O, and security.
- Low-level control over kernel objects, memory, and hardware for system-level tasks.

### High Performance:
- Extremely fast and efficient due to minimal runtime overhead.
- No garbage collection, allowing full control over memory and reducing latency.

### Portability and Compatibility:
- Backward compatibility with older Windows versions.
- Portable language that can be adapted for other operating systems with adjustments.

### Small Footprint:
- Lightweight programs with smaller memory and disk usage, ideal for resource-limited scenarios.

### Extensive Tooling and Libraries:
- Access to the Windows SDK, C headers, and libraries optimized for Windows development.
- Support for third-party C libraries like OpenSSL and SQLite.

### Control Over System Resources:
- Fine-grained memory management (e.g., `malloc`, `free`) for optimization.
- Direct use of Windows threading and synchronization APIs for efficient multitasking.

Generate havoc shellcode/helloworld dialog


Note on compiling:

![Screenshot](./images/assemblyinformation.jpg)

Convert the shellcode to a CSharp array:

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

Load this shellcode into you basic loader template:

```CSHARP

```

To build our own shellcode loader we need 4 functions:

VirtualAlloc (Kernel32.dll)
CreateRemoteThread (Kernel32.dll)
MarshallCopy
WaitForSingleObject (Kernel32.dll)

