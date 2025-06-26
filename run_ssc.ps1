$applicationName = 'Impero Client - 8.6.28 (New)'
$namespace = 'root\ccm\ClientSDK'

try {
    $apps = Get-CimInstance -Namespace $namespace -ClassName CCM_Application -ErrorAction Stop
    $application = $apps | Where-Object { $_.DisplayName -eq $applicationName }

    if ($application -and $application.Status -eq 'Available') {
        Invoke-CimMethod -InputObject $application -MethodName 'Install'
        Write-Host "Application installation triggered."
    } else {
        Write-Host "Application not available for installation."
    }
} catch {
    Write-Host "Failed to query WMI or application not found: $_"
}

# Trigger SCCM actions
$scheduleIDs = @(
    '00000000-0000-0000-0000-000000000121',
    '00000000-0000-0000-0000-000000000003',
    '00000000-0000-0000-0000-000000000010',
    '00000000-0000-0000-0000-000000000001',
    '00000000-0000-0000-0000-000000000021',
    '00000000-0000-0000-0000-000000000002',
    '00000000-0000-0000-0000-000000000031',
    '00000000-0000-0000-0000-000000000113',
    '00000000-0000-0000-0000-000000000114',
    '00000000-0000-0000-0000-000000000022',
    '00000000-0000-0000-0000-000000000032'
)

foreach ($id in $scheduleIDs) {
    try {
        Invoke-CimMethod -Namespace "root\ccm" -ClassName "SMS_Client" -MethodName "TriggerSchedule" -Arguments @{sScheduleID = $id}
        Write-Host "Triggered action: $id"
    } catch {
        Write-Host "Failed to trigger action: $id"
    }
}
