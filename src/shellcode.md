# Shellcode

    What is Shellcode

    **What is AMSI/Dotnet (managed/unmanaged code)**
        The .NET Framework provides the Assembly.Load method which allows loading Common Object 
        File Format (COFF) images like such as DLL’s and EXE’s. Assembly.Load can be supplied 
        with a file path to load a DLL from disk, or with a byte array to load directly in memory.

    Threatcheck/AMSI Trigger

    ClamAV
        dotpeek/hexdump --canonical
        strings -n 5

Shelcode formats (shellcode formatter etc)

On Windows:

***csc.exe (CSharp/dotnet)***
---
```code
c:\windows\Microsoft.NET\Framework\v3.5\bin\csc.exe /t:exe /out:loader.exe loader.cs
csc.exe /t:exe /out:$utilName /unsafe $katzPath
```




***msbuild.exe (CSharp, C++)***
---
```code
msbuild buildapp.csproj -t:HelloWorld
msbuild mimidogz.sln /t:Build /p:Configuration=Release /p:Platform=x64
```

```code
@echo off
set msBuildExe="C:\Windows\Microsoft.NET\Framework64\v4.0.30319\MSBuild.exe"
set solutionsFile="C:\TestProject\mySln.sln"
rem Build the solutions:  
%msBuildExe% /t:Build /p:Configuration=Release /p:Platform=x64 %solutionsFile%
```

***CL.exe (C)***
---
```code
Developer Prompt Visual Studio
cl.exe hello.c /out:hello.exe /exe

git clone https://github.com/gentilkiwi/mimikatz.git

cl.exe /Zi /I inc\ mimikatz\modules\misc\kuhl_m_misc_citrix.c modules\kull_m_kernel.c 
modules\kull_m_memory.c modules\kull_m_minidump.c modules\kull_m_output.c 
modules\kull_m_process.c modules\kull_m_string.c lib\x64\ntdll.min.lib 
/link kernel32.lib user32.lib advapi32.lib shell32.lib crypt32.lib rpcrt4.lib vcruntime.lib ucrt.lib 
/entry:kuhl_m_misc_citrix_logonpasswords 
/subsystem:console
```