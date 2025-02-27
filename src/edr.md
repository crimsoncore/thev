# EDR Stuff

> HINT : Writing your payloads in something else that c, C++, CSharp typically has more evasive results. So exactly the same functionality, just switching the languags throw a lot of AV/EDR's off, or at least decrease the detection rate (i.e golang, nim, ...)
> When using shellcode, DLL's het better by EDR's than Exe's.

https://blog.deeb.ch/posts/how-edr-works/

DLL Sideloading, powershellshell SharpDDL Proxy, DDLHijacks.net
Cyphercon 6
windows SKD Libraries - signed by MS (EDR's track default DLL's and their execution paths)
use procmon to see DLL's not found

Evading AV (signatures), by downloading the shellcode remotely, instead of embedded it might trigger behavioural detections (unsigned process, making a network connection). So maybe we can embed the encrypted shellcode in an .ico file, in a resource file.