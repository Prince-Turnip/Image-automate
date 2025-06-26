
# School Device Post-Imaging Setup Automation

This repo contains scripts used to automate SCCM software installations, Configuration Manager client actions, and common post-imaging setup tasks on student or staff Windows devices.

## Purpose

After imaging school devices, these scripts allow:

- Triggering SCCM app installations (e.g. Impero)
- Running Configuration Manager actions (Machine Policy, Software Inventory, etc.)
- Creating a shortcut to Configuration Manager on the user's desktop
- Prompting for and creating a custom-named desktop folder
- Executing a custom network drive command (`h:g`)
- All **without requiring admin privileges** from the end user

## File Structure

| File                  | Purpose |
|-----------------------|---------|
| `run_sccm.ps1`        | PowerShell script to install Impero and trigger SCCM actions (runs as SYSTEM) |
| `register_task.ps1`   | One-time script to create a scheduled task for `run_sccm.ps1` |
| `install.bat`         | User-facing script that triggers the task and runs post-setup actions |
| `README.md`           | This documentation |

## Setup Instructions (Imaging/Deployment Time)

Run the following steps once on each imaged machine — ideally during your MDT or SCCM task sequence:

1. **Copy all files to a local folder**, e.g.:
   powershell
   mkdir "C:\ProgramData\setup"
   Copy-Item -Path ".\*" -Destination "C:\ProgramData\setup"


2. **Register the elevated scheduled task (run as admin):**

   powershell
   powershell -ExecutionPolicy Bypass -File "C:\ProgramData\setup\register_task.ps1"
   

3. (Optional) Add `install.bat` to run once per user on login using GPO, login script, or task scheduler.

---

## How It Works (For Staff/Techs)

1. The **user logs in** and runs `install.bat` (can be triggered automatically).
2. They are **prompted to enter a folder name**, which is created on their desktop.
3. The script:

   * Triggers the `RunSCCMActions` task (runs `run_sccm.ps1` as SYSTEM)
   * Creates a shortcut to **Configuration Manager** on the desktop
   * Runs a command to access the `H:` drive (e.g. mapped drive scripts)

No admin rights are needed from the user.

---

## Testing the Setup

To test manually:

```bash
# As admin:
powershell -File register_task.ps1

# As standard user:
.\install.bat
```

Watch for the following:

* Desktop folder is created after prompt
* "Configuration Manager" shortcut appears
* `run_sccm.ps1` is executed (can log to file if needed)
* `h:g` runs without error (ensure `H:` is available)

---

## Customization

You can customize:

* SCCM app name in `run_sccm.ps1`
* Which SCCM actions are triggered (edit `$scheduleIDs`)
* Any additional user-facing automation (e.g. registry edits, copied files)

---

## Requirements

* Windows 10/11 Education or Pro
* SCCM client installed and configured
* Devices joined to domain (if using domain accounts)
* One-time admin rights to register task
