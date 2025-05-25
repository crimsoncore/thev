Set-MpPreference -DisableRealtimeMonitoring $true
Set-MpPreference -MAPSReporting Disable
Set-MpPreference -SubmitSamplesConsent NeverSend
Set-MpPreference -DisableScanningNetworkFiles $true

Start-Sleep -Seconds 3

[PSCustomObject]@{
    "Real-Time Protection"        = if ((Get-MpComputerStatus).RealTimeProtectionEnabled -eq $false) {"disabled"} else {"enabled"}
    "Cloud-Delivered Protection"  = if ((Get-MpPreference).MAPSReporting -eq 0) { "disabled" } else { "enabled" }
    "Automatic Sample Submission" = if ((Get-MpPreference).SubmitSamplesConsent -eq 2) { "disabled" } else { "enabled" }
    "Periodic File Scanning"      = if ((Get-MpPreference).DisableScanningNetworkFiles -eq $true) {"disabled"} else {"enabled"}
    "AMSI SCript scanning"        = if ((Get-MpPreference).DisableScriptScanning -eq $true) {"disabled"} else {"enabled"}
} | Format-Table -AutoSize
