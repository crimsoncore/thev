using System;
using System.IO;

class Program
{
    static void Main(string[] args)
    {
        // Prompt the user for the file path
        Console.Write("Please enter the path to the text file: ");
        string filePath = Console.ReadLine();

        // Escape backslashes by replacing them with double backslashes
        filePath = filePath.Replace("\\", "\\\\");

        // Check if the user input is not empty or null
        if (!string.IsNullOrEmpty(filePath))
        {
            try
            {
                // Read the contents of the file
                string fileContents = File.ReadAllText(filePath);

                // Output the contents to the console
                Console.WriteLine("\nFile Contents:\n");
                Console.WriteLine(fileContents);
            }
            catch (FileNotFoundException)
            {
                Console.WriteLine("Error: The file was not found.");
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
            Console.WriteLine("Invalid path entered.");
        }
    }
}
