# Static Analysis

> Visual Studio `2019` Components:


![Screenshot](./images/vs_sharpkatz.jpg)



> SysinternalsSuite (<https://learn.microsoft.com/en-us/sysinternals/downloads/sysinternals-suite>)
>
> GoCheck (<https://github.com/gatariee/gocheck/releases/tag/v1.5.0>)
> Move GoCheck to C:\Sysinternals
> Add c:\SysinternalsSuite to PATH
>
> Install Python3x ?
> Install Yara ? (<https://github.com/VirusTotal/yara/releases/download/v4.5.2/yara-v4.5.2-2326-win64.zip>)
> Install Yara and Hex editor plugin *VS CODE*?

```code
For Yara Download and Install Visual C++ Redistributable:
Go to the official Microsoft download page for the Visual C++ Redistributable
(,https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist?view=msvc-170>)
Download and install the Visual C++ Redistributable for Visual Studio 2015, 2017, 2019, and 2022:
Visual C++ Redistributable x64
```

How to make a new project:

```csharp
dotnet new console -n MyApp
cd MyApp
dotnet build
dotnet run
```

Let's take a common attack tool "Rubeus", compile it and see what Defender thinks of it.

<https://www.youtube.com/watch?v=sP2XH8YI20c&t=1042s>

<https://github.com/GhostPack/Rubeus.git>

https://github.com/gatariee/gocheck/releases

On your windows machine:

```powershell
cd git
git clone https://github.com/GhostPack/Rubeus.git
```

![Screenshot](./images/rubeus_git.jpg)

Let's compile this with <mark>Visual Studio 2022</mark>

![Screenshot](./images/rubeus_vs.jpg)

Browse to your Rubeus solution file (C:\git\Rubeus)

![Screenshot](./images/rubeus_sln.jpg)

select the Program.cs file on the right side in your `Solution Explorer`

![Screenshot](./images/rubeus_prg.jpg)

In order to compile let's change "debug" to "release" and compile as a x64 bit application. Click on "Configuration Manager", 

![Screenshot](./images/rubeus_config.jpg)

![Screenshot](./images/rubeus_x64.jpg)

Save the project, and let's compile (build).

![Screenshot](./images/rubeus_build.jpg)

![Screenshot](./images/rubeus_output.jpg)

Let's see if it works by running rubeus with a simple command:

![Screenshot](./images/rubeus_logon.jpg)

If we copy the file to our "C:\\" directory, we'll see that Defender immediately detects it as malicious!!!

![Screenshot](./images/rubeus_detected.jpg)

> ***HINT :*** Defender didn't detect this as malicious when we compiled it since we made some ,<mark>exclusions</mark> ("C:\Git", "C:\Temp", "C:\Desktop", ...) in Defender to avoid scanning those directories, you can check the exclusions with the following powershell command:

```powershell
Get-MpPreference | Select-Object -ExpandProperty ExclusionPath
```

So now what, how did Defender exactly detect this file as malicious, as we can see it was scanned upon being written to disk - this is static (signature based detection), we'll need to make some changes to our source code to bypass these signatures.

We'll use ***GoCheck*** (based of DefenderCheck and ThreatCheck) to analyze our rubeus file.

Open a new powershell prompt and type the following command:

```powershell
gocheck64.exe C:\Git\Rubeus\Rubeus\bin\x64\Release\Rubeus.exe --defender
```

![Screenshot](./images/rubeus_gocheck_token.jpg)

We can see exactly which strings has caused Defender to detect this as malicious, <mark>ticket</mark>. So all we have to do is go back to our Visual Studio source code and find/replace all TICKET strings by something else, i.e. "***token***".

![Screenshot](./images/rubeus_replace.jpg)

Make sure you select the "Look in" to ***Entire Solution***, and click "Replace All".

![Screenshot](./images/rubeus_replace_ticket.jpg)
![Screenshot](./images/rubeus_replaced_ticket.jpg)

We can see 1294 References have been renamed. Save the file and let's `REBUILD` the solution. 

![Screenshot](./images/rubeus_rebuild_token.jpg)

And now we'll scan it with GoCheck again:

```powershell
gocheck64.exe C:\Git\Rubeus\Rubeus\bin\x64\Release\Rubeus.exe --defender
```

![Screenshot](./images/rubeus_gocheck_tokenfixed.jpg)

We can see there old detection for TICKET is gone, but we have a new one: <mark>DiffieHellmanKey</mark>, alright let's fix that one, just like we did before.

Open Find/Replace and change DiffieHellmanKey to "***dhkey***". Save the project, rebuild and let's scan again with GoCheck (it should replace 12 occurrences).

![Screenshot](./images/rubeus_gocheck_impuser.jpg)

**Another hit :** <mark>impersonateuser</mark>,  we'll replace this with "***impuser***". (it should replace 7 occurrences). Save the file and let's `REBUILD` the solution, and scan again with GoCheck.

```powershell
gocheck64.exe C:\Git\Rubeus\Rubeus\bin\x64\Release\Rubeus.exe --defender
```

![Screenshot](./images/rubeus_gocheck_b64.jpg)

**Another one?** Now defender seems to dislike <mark>base64</mark>. We need to be careful with replacing this as there are functions using base64 as part of the name (i.e. Frombase64String). Let's replace this with ***base_64***, but selecting "match word" to avoid renaming functions and breaking our application. (it should replace 78 occurrences)

![Screenshot](./images/rubeus_b64.jpg)

Save the file and let's `REBUILD` the solution, and scan again with GoCheck.

![Screenshot](./images/rubeus_gocheck_clean.jpg)

Tadaa!!!! Victory!!! No more detections, we can now drop the clean rubeus file to our "C:\\" drive and defender won't detect it. Let's try:

![Screenshot](./images/rubeus_defenderscan.jpg)

![Screenshot](./images/rubeus_defender_clean.jpg)
------

https://github.com/Matthew-IE/XObfuscator.git
add to Havoc C2





strings, threatcheck, gocheck, floss, yara

C:\Temp>gocheck64.exe C:\Git\Rubeus\Rubeus\bin\x64\Release\Rubeus.exe --defender
c:\Git\ThreatCheck\ThreatCheck\bin\x64\Release>ThreatCheck.exe -f C:\Git\Rubeus\Rubeus\bin\x64\Release\Rubeus.exe

# YARA


Let's first install YARA support in VSCODE

![Screenshot](./images/yaracode.jpg)

```yara
rule PE_Detected
{
    meta:
        description = "Detects 'MZ header'"
        author = "Peter Girnus"
            web = "https://www.petergirnus.com/blog"

    condition:
        uint16(0) == 0x5a4d
}
```

<mark>Marked text</mark>

Run strings on NativeDump
HxD or XXD on NativeDump.exe

LitterBox

threatcheck/GoCheck on rubeus (make sure defender execption is off for the folder both files are located)

Check output threatcheck/gocheck

erase with 0x00's

use visual studio find all/replace all (match word)

-----
# Notes
install code 

install sdk (<https://dotnet.microsoft.com/en-us/download/dotnet/thank-you/sdk-9.0.201-windows-x64-installer>)

install C# Dev Kit and .NET Install Tool extensions from the VS Code marketplace.

![Screenshot](./images/code_csharpdev.jpg)

![Screenshot](./images/code_csharinstalltool.jpg)

How to make a new project:

```csharp
dotnet new console -n MyApp
cd MyApp
dotnet build
dotnet run
```