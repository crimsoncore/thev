# Chapter 1.3 - Evasion


Tips and tricks

strings - HxD/xxd
entropy

IAT & String obfuscation

# Build as release and disable optimization (debug includes symbols)

# Fake Certs
Add face code-signing certs
https://github.com/jfmaes/LazySign

# compilation meta data

# Renaming functions

```csharp
[DllImport("kernel32.dll", EntryPoint ="VirtualAlloc", SetLastError = false, ExactSpelling = true)]
        private static extern IntPtr VirtualAlloc(
            IntPtr lpStartAddr, 
            UInt32 size, 
            UInt32 flAllocationType, 
            UInt32 flProtect);
```

Change to : 
```csharp
[DllImport("kernel32.dll", EntryPoint ="VirtualAlloc", SetLastError = false, ExactSpelling = true)]
        private static extern IntPtr MemReserve(
            IntPtr lpStartAddr, 
            UInt32 size, 
            UInt32 flAllocationType, 
            UInt32 flProtect);
```
Entrypoint -> Specific entrypoint in kernel32.dll basically creating an alias to the function
Add some options to evade AV -> SetLastError, ExactSpelling

# Base64 Encoding

# XOR Encoding

# Array Reversing

# Syscalls

# Unhooking