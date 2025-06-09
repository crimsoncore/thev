using System;
using System.Net.NetworkInformation;
using System.Threading;

class Program
{
    static void Main()
    {
        while (true)
        {
            Ping ping = new Ping();
            PingReply reply = ping.Send("8.8.8.8");
            Console.WriteLine(reply.Status);
            Thread.Sleep(5000);
        }
    }
}
