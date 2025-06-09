# Get the last two threat detections from Windows Defender
$threatDetections = Get-MpThreatDetection | 
    Sort-Object -Property InitialDetectionTime -Descending | 
    Select-Object -First 2

if ($threatDetections) {
    $threatDetections | ForEach-Object {
        Write-Output "Detection ID: $($_.DetectionID)"
        Write-Output "Threat ID: $($_.ThreatID)"
        Write-Output "Initial Detection Time: $($_.InitialDetectionTime)"
        Write-Output "Resources: $($_.Resources -join ', ')"
        Write-Output "Process Name: $($_.ProcessName)"
        Write-Output "Threat Status: $($_.ThreatStatusID)"
        Write-Output "----------------------------------------"
    }
} else {
    Write-Output "No threat detections found."
}