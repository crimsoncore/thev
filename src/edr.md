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
# ETW Stuff 

Provider|                                 GUID|
|----------------------------------|---------------------------------------------|
|Microsoft-Windows-Kernel-Process|         {22FB2CD6-0E7B-422B-A0C7-2FAD1FD0E716}|

```code
logman start mysession -p {22FB2CD6-0E7B-422B-A0C7-2FAD1FD0E716} -o mytest.etl -ets
logman start mysession -p Microsoft-Windows-Kernel-Process -o mytest.etl -ets
logman stop mysession -ets
tracerpt mytest.etl
```


https://github.com/Microsoft/perfview/releases


logman create trace MyETWSession -p "Microsoft-Windows-Kernel-Process" 0x8 -o "C:\temp\kernel-process.etl" -ets

.\filebeat.exe -e -c filebeat.yml -d "*"



-----

```powershell 
logman start Microsoft-Windows-Kernel-Memory -p Microsoft-Windows-Kernel-Memory 0xffffffffffffffff win:informational -ets
logman stop Microsoft-Windows-Kernel-Memory -ets 
```

tracerpt .\Microsoft-Windows-Kernel-Memory.etl -o Microsoft-Windows-Kernel-Memory.evtx -of evtx -lr

Provider                                 GUID
-------------------------------------------------------------------------------
Microsoft-Windows-Threat-Intelligence    {F4E1897C-BB5D-5668-F1D8-040F4D8DD344}

-----

| Value              | Keyword                                                        | Description                                                                                           |
| ------------------ | -------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------- |
| 0x0000000000000001 | KERNEL_THREATINT_KEYWORD_ALLOCVM_LOCAL                         | Allocates virtual memory in the local process.                                                        |
| 0x0000000000000002 | KERNEL_THREATINT_KEYWORD_ALLOCVM_LOCAL_KERNEL_CALLER           | Allocates virtual memory in the local process, called from kernel mode.                               |
| 0x0000000000000004 | KERNEL_THREATINT_KEYWORD_ALLOCVM_REMOTE                        | Allocates virtual memory in a remote process.                                                         |
| 0x0000000000000008 | KERNEL_THREATINT_KEYWORD_ALLOCVM_REMOTE_KERNEL_CALLER          | Allocates virtual memory in a remote process, called from kernel mode.                                |
| 0x0000000000000010 | KERNEL_THREATINT_KEYWORD_PROTECTVM_LOCAL                       | Changes the protection on a region of virtual memory in the local process.                            |
| 0x0000000000000020 | KERNEL_THREATINT_KEYWORD_PROTECTVM_LOCAL_KERNEL_CALLER         | Changes the protection on a region of virtual memory in the local process, called from kernel mode.   |
| 0x0000000000000040 | KERNEL_THREATINT_KEYWORD_PROTECTVM_REMOTE                      | Changes the protection on a region of virtual memory in a remote process.                             |
| 0x0000000000000080 | KERNEL_THREATINT_KEYWORD_PROTECTVM_REMOTE_KERNEL_CALLER        | Changes the protection on a region of virtual memory in a remote process, called from kernel mode.    |
| 0x0000000000000100 | KERNEL_THREATINT_KEYWORD_MAPVIEW_LOCAL                         | Maps a view of a file mapping into the address space of the local process.                            |
| 0x0000000000000200 | KERNEL_THREATINT_KEYWORD_MAPVIEW_LOCAL_KERNEL_CALLER           | Maps a view of a file mapping into the address space of the local process, called from kernel mode.   |
| 0x0000000000000400 | KERNEL_THREATINT_KEYWORD_MAPVIEW_REMOTE                        | Maps a view of a file mapping into the address space of a remote process.                             |
| 0x0000000000000800 | KERNEL_THREATINT_KEYWORD_MAPVIEW_REMOTE_KERNEL_CALLER          | Maps a view of a file mapping into the address space of a remote process, called from kernel mode.    |
| 0x0000000000001000 | KERNEL_THREATINT_KEYWORD_QUEUEUSERAPC_REMOTE                   | Queues an asynchronous procedure call (APC) to a thread in a remote process.                          |
| 0x0000000000002000 | KERNEL_THREATINT_KEYWORD_QUEUEUSERAPC_REMOTE_KERNEL_CALLER     | Queues an asynchronous procedure call (APC) to a thread in a remote process, called from kernel mode. |
| 0x0000000000004000 | KERNEL_THREATINT_KEYWORD_SETTHREADCONTEXT_REMOTE               | Sets the context of a thread in a remote process.                                                     |
| 0x0000000000008000 | KERNEL_THREATINT_KEYWORD_SETTHREADCONTEXT_REMOTE_KERNEL_CALLER | Sets the context of a thread in a remote process, called from kernel mode.                            |
| 0x0000000000010000 | KERNEL_THREATINT_KEYWORD_READVM_LOCAL                          | Reads virtual memory in the local process.                                                            |
| 0x0000000000020000 | KERNEL_THREATINT_KEYWORD_READVM_REMOTE                         | Reads virtual memory in a remote process.                                                             |
| 0x0000000000040000 | KERNEL_THREATINT_KEYWORD_WRITEVM_LOCAL                         | Writes to virtual memory in the local process.                                                        |
| 0x0000000000080000 | KERNEL_THREATINT_KEYWORD_WRITEVM_REMOTE                        | Writes to virtual memory in a remote process.                                                         |
| 0x0000000000100000 | KERNEL_THREATINT_KEYWORD_SUSPEND_THREAD                        | Suspends a thread.                                                                                    |
| 0x0000000000200000 | KERNEL_THREATINT_KEYWORD_RESUME_THREAD                         | Resumes a suspended thread.                                                                           |
| 0x0000000000400000 | KERNEL_THREATINT_KEYWORD_SUSPEND_PROCESS                       | Suspends all threads in a process.                                                                    |
| 0x0000000000800000 | KERNEL_THREATINT_KEYWORD_RESUME_PROCESS                        | Resumes all threads in a suspended process.                                                           |
| 0x0000000001000000 | KERNEL_THREATINT_KEYWORD_FREEZE_PROCESS                        | Freezes a process, preventing it from executing.                                                      |
| 0x0000000002000000 | KERNEL_THREATINT_KEYWORD_THAW_PROCESS                          | Thaws a frozen process, allowing it to execute.                                                       |
| 0x0000000004000000 | KERNEL_THREATINT_KEYWORD_CONTEXT_PARSE                         | Parses the context of a process or thread.                                                            |
| 0x0000000008000000 | KERNEL_THREATINT_KEYWORD_EXECUTION_ADDRESS_VAD_PROBE           | Probes the virtual address descriptor (VAD) for an execution address.                                 |
| 0x0000000010000000 | KERNEL_THREATINT_KEYWORD_EXECUTION_ADDRESS_MMF_NAME_PROBE      | Probes the memory-mapped file (MMF) name for an execution address.                                    |
| 0x0000000020000000 | KERNEL_THREATINT_KEYWORD_READWRITEVM_NO_SIGNATURE_RESTRICTION  | Reads or writes virtual memory without signature restrictions.                                        |
| 0x0000000040000000 | KERNEL_THREATINT_KEYWORD_DRIVER_EVENTS                         | Logs events related to kernel-mode drivers.                                                           |
| 0x0000000080000000 | KERNEL_THREATINT_KEYWORD_DEVICE_EVENTS                         | Logs events related to device operations.                                                             |
| 0x8000000000000000 | Microsoft-Windows-Threat-Intelligence/Analytic                 | Logs analytic events for threat intelligence.                                                         |

| Value | Level             | Description |
| ----- | ----------------- | ----------- |
| 0x04  | win:Informational | Information |

| PID        | Image |
| ---------- | ----- |
| 0x00000000 |       |

https://github.com/Lsecqt-Sponsors/Haunt_Agent/blob/main/Payload_Type/haunt/haunt/agent_code/etw.ps1
https://github.com/MHaggis/PowerShell-Hunter

https://www.mdsec.co.uk/2020/03/hiding-your-net-etw/