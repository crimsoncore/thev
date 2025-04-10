# Additional Havoc
# Havoc Modules
***dotnet***
    inline-execute
    execute

***Inline - execute (BOF Loader!!!)***


>OPSEC Hint : When running the shell command, the process hosting your beacon/implant will spawn a child process, run the command and exit the child process. This is quite noisy compared to running everything in memory in the same process. Also command-line logging (eventlogs, sysmon and EDR's will log the commands.)

***shell***

***shellcode*** 
```code
shellcode inject x64 6556 /opt/havoc/payloads/demon.x64.bin
```

> Explain sacrificial process - advatages/disadvantages (command line logging, stability, patching, not touching other processes)