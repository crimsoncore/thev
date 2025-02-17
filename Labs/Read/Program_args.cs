using System;
using System.IO;

class Program
{
    static void Main(string[] args)
    {
        // Check if the user has provided a command-line argument
        if (args.Length > 0)
        {
            // Get the file path from the first argument
            string filePath = args[0];

            // Escape backslashes by replacing them with double backslashes
            filePath = filePath.Replace("\\", "\\\\");

            try
            {
                // Check if the file exists
                if (File.Exists(filePath))
                {
                    // Read the contents of the file
                    string fileContents = File.ReadAllText(filePath);

                    // Output the contents to the console
                    Console.WriteLine("\nFile Contents:\n");
                    Console.WriteLine(fileContents);
                }
                else
                {
                    Console.WriteLine("Error: The file does not exist.");
                }
            }
            catch (UnauthorizedAccessException)
            {
                Console.WriteLine("Error: You do not have permission to access this file.");
            }
            catch (Exception ex)
            {
                // Handle any other errors
                Console.WriteLine($"An error occurred: {ex.Message}");
            }
        }
        else
        {
            Console.WriteLine("Error: No file path argument provided.");
        }
    }
}
