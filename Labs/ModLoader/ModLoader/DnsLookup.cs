using System;
using System.Diagnostics;
using System.Net.Sockets;
using System.Text.RegularExpressions;

namespace ModLoader
{
    public static class DnsLookup
    {
        public static string GetTxtRecord(string hostname)
        {
            try
            {
                Process p = Process.Start(new ProcessStartInfo("nslookup", $"-type=txt {hostname}")
                {
                    RedirectStandardOutput = true,
                    UseShellExecute = false,
                    CreateNoWindow = true,
                });
                p.WaitForExit();
                string output = p.StandardOutput.ReadToEnd();

                // Improved parsing of nslookup output using Regex
                string txtRecord = null;
                Match match = Regex.Match(output, @"text = ""(.*?)"""); //standard
                if (!match.Success)
                {
                    match = Regex.Match(output, @"""(.*?)""");  //alternative
                }
                if (match.Success)
                {
                    txtRecord = match.Groups[1].Value;
                }
                return txtRecord;
            }
            catch (SocketException ex)
            {
                throw new Exception($"Socket error occurred: {ex.Message}");
            }
            catch (Exception ex)
            {
                throw new Exception($"An error occurred: {ex.Message}");
            }
        }
    }
}