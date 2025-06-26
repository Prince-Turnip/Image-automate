@echo off
setlocal enabledelayedexpansion

REM === Get the hostname using PowerShell ===
for /f "delims=" %%i in ('powershell -NoProfile -Command "hostname"') do (
    set "hostname=%%i"
)

echo The hostname is: !hostname!

REM === Create Shortcut to Configuration Manager on Desktop ===
powershell -NoProfile -Command " $s = New-Object -ComObject WScript.Shell; $d = [Environment]::GetFolderPath('Desktop'); $sc = $s.CreateShortcut(\"$d\\Configuration Manager.lnk\"); $sc.TargetPath = \"$env:WINDIR\\System32\\control.exe\"; $sc.Arguments = \"smscfgrc\"; $sc.IconLocation = \"$env:WINDIR\\System32\\imageres.dll,-102\"; $sc.Save(); Write-Host 'Shortcut created successfully!'"

REM === Run H:G exactly as written ===
powershell -Command "& {
h:g
}"

pause
