using System;
using System.Runtime.InteropServices;
using System.Linq;

namespace ModLoader
{
    public static class ETWCheck
    {
        [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        private static extern IntPtr GetModuleHandle(string lpModuleName);

        [DllImport("kernel32.dll", CharSet = CharSet.Ansi, SetLastError = true)]
        private static extern IntPtr GetProcAddress(IntPtr hModule, string lpProcName);

        public static bool ETWChecking()
        {
            string ntdllModuleName = "ntdll.dll";
            string etwEventWriteFunctionName = "EtwEventWrite";

            IntPtr ntdllModuleHandle = GetModuleHandle(ntdllModuleName);
            if (ntdllModuleHandle == IntPtr.Zero)
            {
                Console.WriteLine($"Failed to retrieve module handle: {ntdllModuleName}. Error: {Marshal.GetLastWin32Error()}");
                return false;
            }

            IntPtr etwEventWriteAddress = GetProcAddress(ntdllModuleHandle, etwEventWriteFunctionName);
            if (etwEventWriteAddress == IntPtr.Zero)
            {
                Console.WriteLine($"Failed to retrieve function address: {etwEventWriteFunctionName}. Error: {Marshal.GetLastWin32Error()}");
                return false;
            }

            byte[] expectedBytes = { 0xC3 };
            byte[] actualBytes = new byte[expectedBytes.Length];

            try
            {
                Marshal.Copy(etwEventWriteAddress, actualBytes, 0, expectedBytes.Length);
                Console.WriteLine($"ETW Actual bytes: {BitConverter.ToString(actualBytes)}"); // Debug
            }
            catch (AccessViolationException)
            {
                Console.WriteLine("Access violation reading EtwEventWrite address. Ensure sufficient permissions.");
                return false;
            }

            bool isPatched = actualBytes.SequenceEqual(expectedBytes);

            if (isPatched)
            {
                Console.ForegroundColor = ConsoleColor.Green;
                Console.WriteLine($"ETW is still patched: EtwEventWrite patched at {DateTime.Now:yyyy-MM-dd HH:mm:ss}");
                Console.ResetColor();
            }
            else
            {
                Console.WriteLine("ETW is not patched: EtwEventWrite not modified.");
            }

            return isPatched;
        }
    }
}