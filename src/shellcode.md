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

> OPSEC HINT: Make sure your binaries loog legit, add metadata and and icon to the file!

On Windows (requires SDK):
<https://dotnet.microsoft.com/en-us/>

***csc.exe (CSharp/dotnet)***
---
```code
c:\windows\Microsoft.NET\Framework\v3.5\bin\csc.exe /t:exe /out:loader.exe loader.cs
csc.exe /t:exe /out:$utilName /unsafe $katzPath
```

```csharp
// AssemblyInfo.cs
[assembly: AssemblyTitle("YourProductName")]
[assembly: AssemblyDescription("Some description")]
[assembly: AssemblyConfiguration("")]
[assembly: AssemblyCompany("YourCompanyName")]
[assembly: AssemblyProduct("YourProductName")]
[assembly: AssemblyCopyright("© YourCompanyName")]
[assembly: AssemblyTrademark("")]
[assembly: AssemblyCulture("")]
[assembly: AssemblyVersion("1.0.0.0")]
[assembly: AssemblyFileVersion("1.0.0.0")]
```

```powershell
csc -out:evil.exe -optimize- -win32icon:app.ico Program.cs AssemblyInfo.cs
```

You can extract metadata from any binary with this simple program.

```powershell
dotnet new console -n AssemblyInfoExtractor
cd AssemblyInfoExtractor
```

Create a "Program.cs" file here

```csharp
using System;
using System.Reflection;

namespace AssemblyInfoExtractor
{
    class Program
    {
        static void Main(string[] args)
        {
            if (args.Length == 0)
            {
                Console.WriteLine("Please provide the path to the assembly.");
                return;
            }

            string assemblyPath = args[0];
            try
            {
                var assembly = Assembly.LoadFile(assemblyPath);
                var assemblyName = assembly.GetName();

                Console.WriteLine($"Assembly Full Name: {assemblyName.FullName}");
                Console.WriteLine($"Version: {assemblyName.Version}");

                var attributes = assembly.GetCustomAttributesData();
                foreach (var attr in attributes)
                {
                    if (attr.AttributeType == typeof(AssemblyCompanyAttribute))
                    {
                        Console.WriteLine($"Company: {attr.ConstructorArguments[0].Value}");
                    }
                    if (attr.AttributeType == typeof(AssemblyProductAttribute))
                    {
                        Console.WriteLine($"Product: {attr.ConstructorArguments[0].Value}");
                    }
                    if (attr.AttributeType == typeof(AssemblyCopyrightAttribute))
                    {
                        Console.WriteLine($"Copyright: {attr.ConstructorArguments[0].Value}");
                    }
                    if (attr.AttributeType == typeof(AssemblyTitleAttribute))
                    {
                        Console.WriteLine($"Title: {attr.ConstructorArguments[0].Value}");
                    }
                    if (attr.AttributeType == typeof(AssemblyDescriptionAttribute))
                    {
                        Console.WriteLine($"Description: {attr.ConstructorArguments[0].Value}");
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error: {ex.Message}");
            }
        }
    }
}
```

```powershell
dotnet build
dotnet run --project C:\Temp\AssemblyInfoExtractor\AssemblyInfoExtractor.csproj C:\Temp\LocalLoader.exe
```

or run the exe:

```powershell
C:\Temp\AssemblyInfoExtractor\bin\Debug\net9.0>dir
 Volume in drive C is Windows
 Volume Serial Number is 368D-BFAA

 Directory of C:\Temp\AssemblyInfoExtractor\bin\Debug\net9.0

02/21/2025  04:35 PM    <DIR>          .
02/21/2025  04:35 PM    <DIR>          ..
02/21/2025  04:31 PM               455 AssemblyInfoExtractor.deps.json
02/21/2025  04:35 PM             6,656 AssemblyInfoExtractor.dll
02/21/2025  04:35 PM           145,408 AssemblyInfoExtractor.exe
02/21/2025  04:35 PM            11,080 AssemblyInfoExtractor.pdb
02/21/2025  04:31 PM               268 AssemblyInfoExtractor.runtimeconfig.json
               5 File(s)        163,867 bytes
               2 Dir(s)   2,280,939,520 bytes free

C:\Temp\AssemblyInfoExtractor\bin\Debug\net9.0>AssemblyInfoExtractor.exe C:\Temp\LocalLoader.exe
Assembly Full Name: LocalLoader, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null
Version: 1.0.0.0
Title: LocalLoader
Description:
Company:
Product: LocalLoader
Copyright: Copyright ©  2025
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
--- 
***CL.exe (C)*** Visual Studio
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