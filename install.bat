@echo off
setlocal

echo Triggering elevated SCCM actions...
schtasks /run /tn "RunSCCMActions"

REM === Create user shortcut ===
powershell -NoProfile -Command " $s = New-Object -ComObject WScript.Shell; $d = [Environment]::GetFolderPath('Desktop'); $sc = $s.CreateShortcut(\"$d\\Configuration Manager.lnk\"); $sc.TargetPath = \"$env:WINDIR\\System32\\control.exe\"; $sc.Arguments = \"smscfgrc\"; $sc.IconLocation = \"$env:WINDIR\\System32\\imageres.dll,-102\"; $sc.Save();"

REM === Run H:G exactly as written ===
powershell -Command "& { h:g }"

pause
