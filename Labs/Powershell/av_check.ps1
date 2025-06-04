[PSCustomObject]@{
    "Real-Time Prot."        = if ((Get-MpComputerStatus).RealTimeProtectionEnabled -eq $false) {"disabled"} else {"enabled"}
    "Behavioral Monitoring"  = if ((Get-MpComputerStatus).BehaviorMonitorEnabled -eq $false) {"disabled"} else {"enabled"}
    "AMSI Script scan"       = if ((Get-MpPreference).DisableScriptScanning -eq $true) {"disabled"} else {"enabled"}
    "Cloud-Delivered Prot."  = if ((Get-MpPreference).MAPSReporting -eq 0) { "disabled" } else { "enabled" }
    "Sample Submission"      = if ((Get-MpPreference).SubmitSamplesConsent -eq 2) { "disabled" } else { "enabled" }
    "Periodic File Scan"     = if ((Get-MpPreference).DisableScanningNetworkFiles -eq $true) {"disabled"} else {"enabled"}
} | Format-Table -AutoSize