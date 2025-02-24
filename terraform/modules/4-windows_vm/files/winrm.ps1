$installerUrl = "https://console.automox.com/installers/Automox_Installer-latest.msi"
$outputPath = "C:\terraform\Automox_Installer-latest.msi"

Invoke-WebRequest -Uri $installerUrl -OutFile $outputPath

msiexec.exe /i "C:\terraform\Automox_Installer-latest.msi" /qn /norestart ACCESSKEY=d5e39d9d-8e30-4684-9c0b-655d903df918
