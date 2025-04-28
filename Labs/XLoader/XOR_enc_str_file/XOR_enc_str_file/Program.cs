using System;
using System.Text;
using System.IO;

namespace XorEncoder
{
    public class Program
    {
        public static void Main(string[] args)
        {
            // Read the byte array from a file
            Console.Write("Enter the path to the file containing the byte array: ");
            string filePath = Console.ReadLine();
            byte[] data = File.ReadAllBytes(filePath);

            // Print the byte array content to the screen as a C# array before encoding
            StringBuilder originalHex = new StringBuilder();
            for (int i = 0; i < data.Length; i++)
                originalHex.AppendFormat(i < data.Length - 1 ? "0x{0:x2}, " : "0x{0:x2}", data[i]);

            string originalOutput = $"Original C# shellcode:\nbyte[] buf = new byte[{data.Length}] {{{originalHex}}};";
            Console.WriteLine(originalOutput);

            Console.Write("Enter the XOR key: ");
            string keyInput = Console.ReadLine();
            byte[] key = Encoding.ASCII.GetBytes(keyInput);
            byte[] encoded = new byte[data.Length];

            for (int i = 0; i < data.Length; i++)
                encoded[i] = (byte)(data[i] ^ key[i % key.Length]);

            // Write the encoded binary to a file
            string binaryOutputPath = "encoded_binary.bin";
            File.WriteAllBytes(binaryOutputPath, encoded);
            Console.WriteLine($"Encoded binary written to {binaryOutputPath}");

            // Print the encoded byte array content to the screen as a C# array
            StringBuilder hex = new StringBuilder();
            for (int i = 0; i < encoded.Length; i++)
                hex.AppendFormat(i < encoded.Length - 1 ? "0x{0:x2}, " : "0x{0:x2}", encoded[i]);

            string encodedOutput = $"Encoded C# shellcode:\nbyte[] buf = new byte[{encoded.Length}] {{{hex}}};";
            Console.WriteLine(encodedOutput);

            // Write the encoded output to a text file
            File.WriteAllText("encoded_output.txt", encodedOutput);
            Console.WriteLine("Encoded output written to encoded_output.txt");
        }
    }
}
