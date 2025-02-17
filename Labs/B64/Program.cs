using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace B64
{
    class Program
    {
        static void Main(string[] args)
        {
            string filePath = @"C:\file.txt";
            byte[] bytes = File.ReadAllBytes(filePath);
            string base64File = Convert.ToBase64String(bytes);
            Console.WriteLine(base64File);
        }
    }
}
