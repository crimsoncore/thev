using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Base64
{
    class Program
    {
        static void Main(string[] args)
        {
            var plainTextBytes = System.Text.Encoding.UTF8.GetBytes("TestString");
            Console.WriteLine(Convert.ToBase64String(plainTextBytes));
            var base64EncodedBytes = Convert.FromBase64String(System.Convert.ToBase64String(plainTextBytes));
            Console.WriteLine(System.Text.Encoding.UTF8.GetString(base64EncodedBytes));
        }
    }
}
