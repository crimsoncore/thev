# .NET & CLR


> WARNING : Amsi.dll is loaded into every powershell.exe process, but when running dotnet (csharp) binaries, amsi integrates directly with the clr which loads AMSI on demand. Amsi Bypasses that work in powershell don't necessariy work for the CLR integration.

AmsiScanBuffer
AmsiScanString
AssemblyLoad

Show api calls made (user to kernel/syscall)

Languages
-- -
- powershell (scripting)
- vb.net (scripting)
- c# (compiled)
- f# (compiled)


![dotnet](./images/dotnet.jpeg)

Here's a simplified diagram:

![dotnet](./images/amsi_clr.jpg)


| **Perspective**         | **Advantages**                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          | **Disadvantages**                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| ----------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Detection/Forensics** | - **Fileless Execution**: Leverages .NET for in-memory execution (e.g., PowerShell, `Assembly.Load`), avoiding disk writes and evading file-based AV.<br>- **Living Off the Land**: Uses trusted Windows tools (e.g., PowerShell, WMI), blending with legitimate activity.<br>- **Obfuscation**: Supports runtime compilation (e.g., `CSharpCodeProvider`) to generate dynamic payloads, complicating static analysis.<br>- **Ephemeral Artifacts**: Memory-based attacks leave transient evidence, lost on reboot, challenging forensics without live memory captures. | - **.NET Telemetry**: CLR generates logs (e.g., PowerShell Script Block Logging, Event ID 4104), detectable by EDRs like Microsoft Defender.<br>- **Behavioral Detection**: High-level APIs (e.g., `System.Net.Http`) trigger EDR alerts for unusual process behavior.<br>- **Memory Forensics**: .NET’s structured memory (e.g., IL code, metadata) is easier to analyze than raw shellcode using tools like Volatility.<br>- **.NET Dependency**: Requires .NET runtime, which may be hardened or absent, increasing detectability.                                   |
| **Capabilities**        | - **Rapid Development**: High-level syntax and .NET libraries enable quick creation of complex tools (e.g., C2 clients, keyloggers).<br>- **Windows Integration**: Seamless use of PowerShell, WMI, and Windows APIs for fileless attacks and lateral movement.<br>- **Dynamic Payloads**: Runtime code generation (e.g., `Assembly.Load`) allows adaptive, stealthy payloads.<br>- **Obfuscation Ecosystem**: Tools like ConfuserEx enhance payload protection against reverse-engineering.                                                                            | - **Limited Low-Level Control**: Managed environment restricts raw memory manipulation (e.g., shellcode injection) without P/Invoke, increasing complexity.<br>- **Runtime Overhead**: .NET CLR (JIT, garbage collection) adds performance overhead, potentially noticeable in constrained environments.<br>- **Lack of Persistence**: Fileless attacks require disk-based persistence mechanisms (e.g., registry), risking detection.<br>- **Platform Dependency**: Primarily effective on Windows; limited portability to non-Windows systems without Mono/.NET Core. |