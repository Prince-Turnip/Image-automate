@echo off
REM sets the hostname as a variable
set "powershell_output="

for /f "usebackq delims=" %%i in (`powershell.exe -NoProfile -Command "wmic computersystem get name"`) do (
    set "powershell_output=%%i"
)
echo The hostname is: %powershell_output%

$computerName = %powershell_output%
$applicationName = "Impero"
$namespace = "root\ccm\ClientSDK"
$wmiObject = Get-WmiObject -Namespace $namespace -ComputerName $computerName -Class CCM_Application
    
REM Find the application object
$application = $wmiObject | Where-Object {$_.DisplayName -eq $applicationName}
    
REM Check if the application is available for installation
if ($application.Status -eq "Available") {
    $application.Install()
  } else {
    Write-Host "Application '$applicationName' is not available for installation."
}

REM Puts Configuration Manager on the desktop
powershell -Command "& {
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
}"
echo Shortcut created successfully!

REM Runs the actions
powershell -Command "& {
Invoke-CMClientAction -DeviceName %powershell_output% -Action MachinePolicyRetrievalEvalCycle
}"
echo Actions all run successfully!



REM Finally runs the h:g 
powershell -Command "& {
h:g
}"

pause





