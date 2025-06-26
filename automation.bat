@echo off
setlocal enabledelayedexpansion

REM === Elevation Check ===
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo This script requires administrative privileges.
    powershell -Command "Start-Process -Verb runAs -FilePath '%~f0'"
    exit /b
)

REM === Get the hostname using PowerShell ===
for /f "delims=" %%i in ('powershell -NoProfile -Command "hostname"') do (
    set "hostname=%%i"
)

echo The hostname is: !hostname!

REM === Install the 'Impero' Application via CIM ===
REM powershell -NoProfile -Command "try {
REM    \$computerName = '!hostname!';
REM    \$applicationName = 'Impero Client - 8.6.28 (New)';
REM    \$namespace = 'root\ccm\ClientSDK';
REM    \$apps = Get-CimInstance -Namespace \$namespace -ComputerName \$computerName -ClassName CCM_Application -ErrorAction Stop;
REM    \$application = \$apps | Where-Object { \$_.DisplayName -eq \$applicationName };
REM    if (\$application -and \$application.Status -eq 'Available') {
REM        Invoke-CimMethod -InputObject \$application -MethodName 'Install';
REM        Write-Host 'Application installation triggered.';
REM    } else {
REM        Write-Host 'Application not available for installation.';
REM    }
REM } catch {
REM    Write-Host

REM === Create Shortcut to Configuration Manager on Desktop ===
powershell -NoProfile -Command " \$s = New-Object -ComObject WScript.Shell; \$d = [Environment]::GetFolderPath('Desktop'); \$sc = \$s.CreateShortcut(\"\$d\\Configuration Manager.lnk\"); \$sc.TargetPath = \"\$env:WINDIR\\System32\\control.exe\"; \$sc.Arguments = \"smscfgrc\"; \$sc.IconLocation = \"\$env:WINDIR\\System32\\imageres.dll,-102\"; \$sc.Save(); Write-Host 'Shortcut created successfully!'"

REM === Trigger ALL SCCM Client Actions from the Actions Tab ===
powershell -NoProfile -Command " \$ids = @(
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
); foreach (\$id in \$ids) {
    try {
        Invoke-CimMethod -Namespace 'root\ccm' -ClassName 'SMS_Client' -MethodName 'TriggerSchedule' -Arguments @{sScheduleID = \$id};
        Write-Host \"Triggered action: \$id\";
    } catch {
        Write-Host \"Failed to trigger action: \$id\" -ForegroundColor Red;
    }
}"

REM === Run H:G exactly as written ===
powershell -Command "& {
h:g
}"

pause
