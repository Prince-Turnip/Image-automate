@echo off
setlocal enabledelayedexpansion

REM === Get the hostname using PowerShell ===
for /f "delims=" %%i in ('powershell -NoProfile -Command "hostname"') do (
    set "hostname=%%i"
)

echo The hostname is: !hostname!

REM === Install the 'Impero' Application via WMI ===
powershell -NoProfile -Command ^
"& {
    $computerName = '!hostname!'
    $applicationName = 'Impero'
    $namespace = 'root\ccm\ClientSDK'

    try {
        $wmiObject = Get-WmiObject -Namespace $namespace -ComputerName $computerName -Class CCM_Application -ErrorAction Stop
        $application = $wmiObject | Where-Object { $_.DisplayName -eq $applicationName }

        if ($application -and $application.Status -eq 'Available') {
            $application.Install()
            Write-Host 'Application installation triggered.'
        } else {
            Write-Host 'Application not available for installation.'
        }
    } catch {
        Write-Host 'Failed to query WMI or application not found.' -ForegroundColor Red
    }
}"

REM === Create Shortcut to Configuration Manager on Desktop ===
powershell -NoProfile -Command ^
"& {
    $shortcutPath = Join-Path -Path $env:USERPROFILE -ChildPath 'Desktop\\Configuration Manager.lnk'
    $targetPath = '%windir%\system32\control.exe'
    $argument = 'smscfgrc'
    $iconPath = '%windir%\system32\imageres.dll,-102'

    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = $targetPath
    $shortcut.Arguments = $argument
    $shortcut.IconLocation = $iconPath
    $shortcut.Save()

    Write-Host 'Shortcut created successfully!'
}"

REM === Trigger ALL SCCM Client Actions from the Actions Tab ===
powershell -NoProfile -Command ^
"& {
    $allActions = @(
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

    foreach ($id in $allActions) {
        try {
            Invoke-CimMethod -Namespace 'root\ccm' -ClassName 'SMS_Client' -MethodName 'TriggerSchedule' -Arguments @{sScheduleID = $id}
            Write-Host \"Triggered action: $id\"
        } catch {
            Write-Host \"Failed to trigger action: $id\" -ForegroundColor Red
        }
    }
}"

REM === Run H:G exactly as written ===
powershell -Command "& {
h:g
}"

pause



