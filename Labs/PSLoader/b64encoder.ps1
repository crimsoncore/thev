try {
    # Prompt user for the path to the input file
    $assemblyPath = Read-Host "Please enter the full path to the .net assembly file"
    
    # Verify the file exists
    if (-not (Test-Path $assemblyPath)) {
        throw "File not found: $assemblyPath"
    }
    
    # Read the file as bytes
    $assemblyBytes = [System.IO.File]::ReadAllBytes($assemblyPath)
    Write-Output "Original file size: $($assemblyBytes.Length) bytes"
    
    # Convert to base64 string
    $base64Assembly = [System.Convert]::ToBase64String($assemblyBytes)
    Write-Output "Base64 string length: $($base64Assembly.Length) characters"
    
    # Derive output path using the input filename without extension and append .b64
    $fileInfo = [System.IO.FileInfo]$assemblyPath
    $outputPath = Join-Path -Path $fileInfo.DirectoryName -ChildPath ($fileInfo.BaseName + ".b64")
    
    # Save to a file
    $base64Assembly | Out-File -FilePath $outputPath -Encoding ASCII
    Write-Output "Base64 file saved to: $outputPath"
    
    # Verify the base64 string by decoding it back
    $decodedBytes = [System.Convert]::FromBase64String($base64Assembly)
    Write-Output "Decoded size: $($decodedBytes.Length) bytes"
    if ($decodedBytes.Length -eq $assemblyBytes.Length) {
        Write-Output "Verification successful: Decoded size matches original file size"
    } else {
        Write-Error "Verification failed: Decoded size does not match original file size"
    }
}
catch {
    Write-Error "Error encoding file: $_"
}