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
            byte[] buf = File.ReadAllBytes(filePath);

            Console.Write("Enter the XOR key: ");
            string keyInput = Console.ReadLine();
            byte[] key = Encoding.ASCII.GetBytes(keyInput);
            byte[] encoded = new byte[buf.Length];

            // XOR encode the data
            for (int i = 0; i < buf.Length; i++)
                encoded[i] = (byte)(buf[i] ^ key[i % key.Length]);

            StringBuilder hex = new StringBuilder();
            for (int i = 0; i < encoded.Length; i++)
                hex.AppendFormat(i < encoded.Length - 1 ? "0x{0:x2}, " : "0x{0:x2}", encoded[i]);

            string encodedOutput = $"Encoded C# shellcode:\nbyte[] buf = new byte[{encoded.Length}] {{{hex}}};";
            Console.WriteLine(encodedOutput);

            // Write the encoded output to a binary file
            File.WriteAllBytes("encoded_output.bin", encoded);
            Console.WriteLine("Encoded output written to encoded_output.bin");

            // XOR decode the encoded data
            byte[] decoded = new byte[encoded.Length];
            for (int i = 0; i < encoded.Length; i++)
                decoded[i] = (byte)(encoded[i] ^ key[i % key.Length]);

            StringBuilder decodedHex = new StringBuilder();
            for (int i = 0; i < decoded.Length; i++)
                decodedHex.AppendFormat(i < decoded.Length - 1 ? "0x{0:x2}, " : "0x{0:x2}", decoded[i]);

            string decodedOutput = $"Decoded C# shellcode:\nbyte[] buf = new byte[{decoded.Length}] {{{decodedHex}}};";
            Console.WriteLine(decodedOutput);

            // Write the decoded output to a binary file
            File.WriteAllBytes("decoded_output.bin", decoded);
            Console.WriteLine("Decoded output written to decoded_output.bin");

            // Verify if the decoded data matches the original data
            bool isMatch = true;
            for (int i = 0; i < buf.Length; i++)
            {
                if (buf[i] != decoded[i])
                {
                    isMatch = false;
                    break;
                }
            }

            if (isMatch)
                Console.WriteLine("The decoded data matches the original data.");
            else
                Console.WriteLine("The decoded data does not match the original data.");
        }
    }
}
