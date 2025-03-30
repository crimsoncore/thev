# Lab - Basic Loader
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

