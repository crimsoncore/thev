using System;
using System.Threading;

namespace ModLoader
{
    public static class Sleep
    {
        private static readonly Random rnd = new Random();

        public static void RandomSleep()
        {
            int sleepInterval = rnd.Next(1000, 5000);
            Console.WriteLine($"Sleeping for {sleepInterval} milliseconds...");
            Thread.Sleep(sleepInterval);
        }
    }
}
