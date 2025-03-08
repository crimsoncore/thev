# Chapter 1.2.1 - Functions

learn.micorosoft.com

WIN32 api functions (slides)

https://malapi.io/

Api monitor
x64dbg

![Screenshot](./images/functions_flow.jpg)
<https://redops.at/en/blog/direct-syscalls-vs-indirect-syscalls>


![Screenshot](./images/functions_virtualalloc.jpg)

![Screenshot](./images/functions_createthread.jpg)

![Screenshot](./images/functions_waitforsingleobject.jpg)


Let's build a dummy shellcode:

hello world dialog

<https://github.com/hasherezade/pe_to_shellcode/releases/tag/v1.2>

```bash
sudo msfvenom -a x64 --platform windows -p windows/x64/messagebox TEXT="Successful Execution :)" TITLE="CrimsonCORE"  -f exe -o msg.exe
```

https://www.youtube.com/watch?v=0PUZbgcIMzg
create a dialogbox with metadata






```csharp
using System;
using System.Diagnostics;
using System.Linq;

class Program
{
    static void Main()
    {

        // Buffer with our shellcode
        byte[] shellCode;
        shellCode = new byte[] 
        { 
            0xfc,0xfc 
        };
        Console.Clear();
        Console.Write("Shellcode: ");

        foreach (byte b in shellCode)
        {
            Console.Write($"0x{b:X2}, ");  // X2 formats as two-character uppercase hex
        }

        Console.WriteLine();  // To add a newline at the end
        Console.WriteLine();  // To add a newline at the end

        // Find the process with the name "explorer"
        var explorerProcess = Process.GetProcessesByName("explorer").FirstOrDefault();

        if (explorerProcess != null)
        {
            Console.WriteLine($"Process ID of explorer.exe: {explorerProcess.Id}");
        }
        else
        {
            Console.WriteLine("explorer.exe not found.");
        }
        Console.WriteLine();  // To add a newline at the end

        // Wait for any key to be pressed
        Console.WriteLine("Press any key to stop...");
        Console.ReadKey();

    }
}
```