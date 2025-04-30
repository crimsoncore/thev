# EDR Stuff

> HINT : Writing your payloads in something else that c, C++, CSharp typically has more evasive results. So exactly the same functionality, just switching the languags throw a lot of AV/EDR's off, or at least decrease the detection rate (i.e golang, nim, ...)
> When using payloads, DLL's evade EDR's than Exe's. -> Shellcode = not exe/dll!!!

https://blog.deeb.ch/posts/how-edr-works/

DLL Sideloading, powershellshell SharpDDL Proxy, DDLHijacks.net
Cyphercon 6
windows SKD Libraries - signed by MS (EDR's track default DLL's and their execution paths)
use procmon to see DLL's not found

Evading AV (signatures), by downloading the shellcode remotely, instead of embedded it might trigger behavioural detections (unsigned process, making a network connection). So maybe we can embed the encrypted shellcode in an .ico file, in a resource file.

>  ***OPSEC Hint*** : EDR's will look at Entropy, so anything that is encrypted/packed/compressed (high level of randomization), will have a very high entropy (randomness level). We can optimize our shellcode by adding nullbytes to decrease the entropy. This is REALLY important
>
> https://github.com/gmh5225/shellcode-EntropyFix
> sigcheck.exe -h -a "D:\Malware\11"
>
> As compression and encryption algorithms' output usually consists of high entropy data, one can say any file with entropy greater than 7.0 is likely compressed, encrypted, or packed (in case of executables).

> Also remember static/signature/heuristic detection can flag suspicious elements of code, so the cleaner we bypass, the less EDR gets a headstart with suspicious detections passed on from the static engine.

1. code-signed files are more losely inspected
2. it's all about adding weight of malicious indicators

How EDR's do their thing

| Feature                | Description                                                       |
| ---------------------- | ----------------------------------------------------------------- |
| Kernell callbacks      | Process creation, dll loading etc                                 |
| ETW                    | System events                                                     |
| AMSI                   | Jscript, vbscript, dotnet, powershell -> scanning with signatures |
| System call Monitoring | Hooking API's in process memory                                   |

> 1. https://frida.re/docs/frida-trace/
> 2. https://github.com/CCob/SylantStrike
> 3. https://www.vaadata.com/blog/antivirus-and-edr-bypass-techniques/
> 4. https://github.com/Xacone/BestEdrOfTheMarket
> 