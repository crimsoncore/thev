using System;
using System.Diagnostics;
using System.Linq;

class Program
{
    static void Main()
    {
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
    }
}
