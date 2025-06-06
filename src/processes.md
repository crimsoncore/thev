# Processes, Tokens & DLL's

## Primer on Windows Processes, DLLs, and Process Tokens for DFIR

This primer provides a concise, technical overview of Windows processes, Dynamic Link Libraries (DLLs), and process tokens. These fundamental operating system concepts are critical for professionals involved in digital forensics, threat hunting, and incident response, as they form the bedrock of understanding system activity, identifying anomalies, and tracing malicious behavior.

---

## Table of Contents

1. Introduction
2. Processes  
    2.1. What is a Process?  
    2.2. Key Process Structures and Components  
    2.3. Parent/Child Process Relationships  
    2.4. DFIR Relevance: Identifying Suspicious Process Creation  
3. Dynamic Link Libraries (DLLs)  
    3.1. What is a DLL?  
    3.2. How DLLs are Loaded  
    3.3. DLL Injection Techniques  
    3.4. DFIR Relevance: DLLs in Malware and Evasion  
4. Process Tokens  
    4.1. What is an Access Token?  
    4.2. Access Token Contents  
    4.3. Access Token Creation  
    4.4. Integrity Levels  
    4.5. DFIR Relevance: Token Manipulation and Privilege Escalation  
5. References

---

## 1. Introduction

In the complex landscape of cyber security, a deep understanding of operating system internals is paramount for effective digital forensics, proactive threat hunting, and decisive incident response. This document focuses on three core Windows OS components: processes, DLLs, and process tokens. We will explore their definitions, internal mechanisms, interrelationships, and, crucially, their significance in detecting and analyzing malicious activities.

---

## 2. Processes

### 2.1. What is a Process?

A process is an instance of a running program. It encapsulates the necessary resources to execute a program, providing an isolated environment for its operations. Each process has its own dedicated virtual address space, containing the executable code, data, heap, and stack. It also manages its own set of resources, such as open files, network connections, and security context.

### 2.2. Key Process Structures and Components

In Windows, a process is primarily represented by several kernel-mode and user-mode data structures:

- **EPROCESS (Executive Process Block):** The primary kernel-mode structure that represents a process. It contains pointers to other essential structures, security descriptors, and process-specific information like process ID (PID), parent PID, and creation time.
- **KPROCESS (Kernel Process Block):** A sub-structure within EPROCESS, containing thread-related information, scheduling parameters, and pointers to the process's page directory.
- **PEB (Process Environment Block):** A user-mode structure accessible to the process itself. It contains information like loaded modules (DLLs), process parameters, and OS loader data.
- **PID (Process ID):** A unique numerical identifier assigned to each active process.
- **Virtual Address Space:** Each process gets a private virtual address space (e.g., 4 GB for 32-bit processes, 8 TB for 64-bit on typical Windows), which maps to physical memory pages.

### 2.3. Parent/Child Process Relationships

Processes are typically created by other processes. The creating process is known as the parent process, and the newly created process is the child process. This relationship is hierarchical, forming a process tree where System (PID 4) is often the root, and smss.exe (Session Manager SubSystem) is a key early parent. explorer.exe is commonly the parent for user-launched applications.

When a new process is created (e.g., via CreateProcess API), the child process inherits certain attributes from its parent, including environment variables, some handles, and importantly, a duplicate of the parent's access token. This inheritance is crucial for understanding privilege propagation and potential abuse.

**Diagram: Simplified Process Creation Flow**

| Parent Process (e.g., cmd.exe) | --CreateProcess API--> | Child Process (e.g., powershell.exe) |
| :----------------------------: | :--------------------: | :----------------------------------: |
|      Inherits (copy of):       |                        |           New PID assigned           |
|       - Security Context       |                        |      Own Virtual Address Space       |
|    - Environment Variables     |                        |        Inherits some handles         |


### 2.4. DFIR Relevance: Identifying Suspicious Process Creation

- **Anomalous Parent-Child Chains:** Unexpected parent-child relationships are a prime indicator of malicious activity.
  - Example: `svchost.exe` spawning `cmd.exe` or `powershell.exe`. `svchost.exe` typically hosts services and should not directly launch user-interactive shells.
  - Example: Microsoft Office applications (`word.exe`, `excel.exe`) spawning `cmd.exe`, `powershell.exe`, or other executables. This is a common tactic for macro-enabled malware.
- **Process Renaming/Masquerading:** Malware often renames itself to commonly seen processes (e.g., `svchost.exe`, `explorer.exe`) to blend in. Analyzing the process path, command line arguments, and parent process can reveal masquerading.
- **Execution from Unusual Locations:** Processes running from temporary directories (`%TEMP%`, `C:\Windows\Temp`), user profile directories (`%APPDATA%`, `%LOCALAPPDATA%`), or non-standard system paths are highly suspicious.
- **Unusual Command Line Arguments:** Many legitimate processes have predictable command line arguments. Malicious processes might use unusual flags, obfuscated strings, or encoded commands (e.g., base64 encoded PowerShell).

---

## 3. Dynamic Link Libraries (DLLs)

### 3.1. What is a DLL?

A Dynamic Link Library (DLL) is a type of executable file that contains code and data that can be used by multiple programs simultaneously. Unlike static libraries, which are linked into an executable at compile time, DLLs are loaded into memory at runtime, either when a program starts or on demand. This allows for:

- **Code Reusability:** Multiple applications can use the same DLL, reducing memory footprint and disk space.
- **Modularity:** Applications can be updated by simply replacing DLLs without recompiling the entire executable.
- **Resource Sharing:** DLLs can contain resources (icons, strings) that are shared across applications.

### 3.2. How DLLs are Loaded

DLLs can be loaded into a process in two primary ways:

- **Implicit (Static) Linking:** When an executable is compiled, if it's designed to use functions from a specific DLL, a record of this dependency is stored in the executable's import address table (IAT). When the executable loads, the Windows loader automatically finds and maps these required DLLs into the process's virtual address space.
- **Explicit (Dynamic) Linking:** A program can explicitly load a DLL at runtime using functions like `LoadLibrary` or `LoadLibraryEx`. This allows programs to load DLLs conditionally or load DLLs whose names are determined at runtime.

Once loaded, the DLL's code and data become part of the process's virtual address space, and the process can call functions exported by the DLL.

**Diagram: DLL Loading into a Process's Virtual Address Space**

| Process Virtual Address Space        |
| ------------------------------------ |
| Process Executable (Code, Data)      |
| DLL A Code/Data (e.g., ntdll.dll)    |
| DLL B Code/Data (e.g., kernel32.dll) |
| Heap / Stack                         |


### 3.3. DLL Injection Techniques

DLL injection is a widely used technique by malware to execute arbitrary code within the context of another process. Common methods include:

- **Remote Thread Injection:** The most common. A malicious process writes the path to a malicious DLL into the target process's memory and then creates a remote thread in the target process that calls `LoadLibrary` to load the DLL.
- **SetWindowsHookEx:** Exploits Windows hooking mechanisms to inject a DLL into processes that receive certain window messages.
- **APCs (Asynchronous Procedure Calls):** Enqueuing a DLL loading routine into a target thread's APC queue.
- **Process Hollowing/RunPE:** Creating a suspended process, hollowing out its legitimate code, and injecting malicious code (often including DLLs) before resuming.
- **Reflective DLL Injection:** The DLL is loaded directly from memory without touching the disk, making detection harder.

### 3.4. DFIR Relevance: DLLs in Malware and Evasion

- **Malware Persistence:** DLLs can be registered as services, run via `AppInit_DLLs` registry key, or hijacked through DLL search order flaws to achieve persistence.
- **Evasion:** Reflective DLL injection or techniques that load DLLs from non-standard locations can bypass traditional endpoint detection mechanisms that monitor file system activity.
- **Privilege Escalation:** Some DLLs might be vulnerable to hijacking, allowing a lower-privileged process to load a malicious DLL that then executes with higher privileges.
- **Code Injection:** DLLs are the primary vehicle for code injection into legitimate processes, allowing malware to masquerade, hide, and access resources with the target process's privileges.
- **Forensic Artifacts:** Analyzing loaded DLLs in memory dumps, Prefetch files, ShimCache, and registry keys related to DLL loading can reveal malicious activity.

---

## 4. Process Tokens

### 4.1. What is an Access Token?

An access token is a kernel object that describes the security context of a process or thread. It contains all the security-relevant information about the user account under which the process or thread is running. When a process tries to access a secured object (e.g., a file, registry key, or another process), the operating system performs an access check by comparing the information in the process's (or thread's) access token against the object's Security Descriptor.

### 4.2. Access Token Contents

A typical access token contains:

- **User SID (Security Identifier):** Identifies the user account.
- **Group SIDs:** Identifies all security groups the user is a member of (e.g., Administrators, Domain Users).
- **Privileges:** A list of special rights assigned to the user or group (e.g., SeDebugPrivilege for debugging, SeBackupPrivilege for backing up files).
- **Integrity Level (IL):** A security attribute that defines the trustworthiness of a process (discussed below).
- **Default DACL (Discretionary Access Control List):** Specifies default permissions for objects created by the process.
- **Authentication ID:** Unique identifier for the logon session.

### 4.3. Access Token Creation

Access tokens are primarily created during the user logon process. When a user successfully authenticates, the Local Security Authority (LSA) creates an initial access token for that logon session.

When a new process is created, by default, it inherits a copy of its parent's access token. This means a child process runs with the same security context as its parent. However, processes can also be created with a different token (e.g., `CreateProcessAsUser`, `ShellExecuteAsUser`, or `CreateRestrictedToken`).

### 4.4. Integrity Levels (IL)

Integrity Levels (ILs) are a core component of Windows Mandatory Integrity Control (MIC), introduced in Windows Vista. They add another layer of security beyond traditional Discretionary Access Control Lists (DACLs) by assigning a "trustworthiness" level to processes and objects.

There are several standard Integrity Levels:

- **Untrusted (0x0000):** Very low trust (e.g., for anonymous logon).
- **Low (0x1000):** Restricted processes, often for internet-facing applications (e.g., Internet Explorer in Protected Mode). Cannot write to most user directories.
- **Medium (0x2000):** Default for most user-launched applications.
- **High (0x3000):** For processes launched with administrative privileges (e.g., "Run as administrator" or UAC elevated processes).
- **System (0x4000):** For core operating system processes and services.
- **TrustedInstaller (0x5000):** The highest integrity level, reserved for Windows Update and Windows Modules Installer Service, allowing modification of critical system files.

**Key Principle of MIC:**  
A process at a lower integrity level cannot write to or modify objects (files, registry keys, other processes) at a higher integrity level. This is known as "no write up." However, a process at a higher IL can write to objects at a lower IL.

**Diagram: Simplified Process Token Structure with Integrity Level**

| Access Token                          |
| ------------------------------------- |
| User SID: S-1-5-21-XXX-YYY-ZZZ...     |
| Groups:                               |
| - S-1-5-32-544 (Administrators)       |
| - S-1-5-21-YYY-ZZZ-AAA (Domain Users) |
| Privileges:                           |
| - SeImpersonatePrivilege              |
| - SeDebugPrivilege                    |
| - SeShutdownPrivilege                 |
| Integrity Level (IL): High (0x3000)   |
| Default DACL:                         |
| - (Allows Read/Write for Owner)       |
| - (Allows Read for Everyone)          |
| Authentication ID: 0:12345            |

### 4.5. DFIR Relevance: Token Manipulation and Privilege Escalation

- **Token Theft/Impersonation:** Attackers often steal or impersonate tokens from privileged processes (e.g., `lsass.exe`, `services.exe`) to gain elevated privileges without needing credentials. This is a common post-exploitation technique.  
  *Tools: Mimikatz, Incognito.*
- **Bypassing UAC (User Account Control):** Many UAC bypasses involve finding ways to launch processes with a High integrity token from a Medium integrity context, often by abusing legitimate Windows binaries that auto-elevate.
- **Integrity Level Analysis:** In threat hunting, observing a process running at an unexpectedly low or high integrity level can be suspicious.

  **Example:** A standard user application running at System integrity level (a strong indicator of compromise).

  **Example:** Malware attempting to drop files into a Program Files directory (which requires High integrity) from a Medium integrity process, which would fail due to MIC unless a privilege escalation occurred.

  **Parent-Child Integrity Discrepancy:** While children typically inherit the parent's IL, a sudden jump in integrity level without a legitimate UAC prompt or `CreateProcessAsUser` could indicate a UAC bypass or other privilege escalation.

---

## 5. References

- [Microsoft Docs: About Processes and Threads](https://learn.microsoft.com/en-us/windows/win32/procthread/about-processes-and-threads)
- [Microsoft Docs: Dynamic-Link Library Concepts](https://learn.microsoft.com/en-us/windows/win32/dlls/dynamic-link-library-concepts)
- [Microsoft Docs: Access Tokens](https://learn.microsoft.com/en-us/windows/win32/secauthz/access-tokens)
- [Microsoft Docs: Understanding and Working with Integrity Levels](https://learn.microsoft.com/en-us/windows/security/threat-protection/security-policy-settings/understanding-and-working-with-integrity-levels)
- [SpecterOps Blog - Access Tokens](https://posts.specterops.io/understanding-and-abusing-access-tokens-on-windows-9195b4c19799)
- [SANS GIAC Papers (search for "process forensics", "DLL injection", "access token")](https://www.sans.org/reading-room/whitepapers/)