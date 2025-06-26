@echo off
setlocal enabledelayedexpansion

REM === Get the hostname using PowerShell ===
for /f "delims=" %%i in ('powershell -NoProfile -Command "hostname"') do (
    set "hostname=%%i"
)

echo The hostname is: !hostname!

REM === Install the 'Impero' Application via WMI ===
powershell -NoProfile -Command "& {
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
powershell -NoProfile -Command "& {
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

REM === Trigger ConfigMgr Client Action ===
powershell -NoProfile -Command "& {
    try {
        Invoke-CMClientAction -DeviceName '!hostname!' -Action MachinePolicyRetrievalEvalCycle
        Write-Host 'Client action triggered successfully!'
    } catch {
        Write-Host 'Failed to trigger ConfigMgr action.' -ForegroundColor Red
    }
}"

REM === Run H:G as originally written ===
powershell -Command "& {
h:g
}"

pause





