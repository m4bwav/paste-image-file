# Installation

## Requirements

- Windows 10 version 1809 or later, or Windows 11.
- Windows PowerShell 5.1, which every supported Windows already has. PowerShell 7 is not needed.
- No administrator rights.

## Install

1. Get the files: `git clone https://github.com/m4bwav/paste-image-file.git`, or **Code > Download ZIP** and extract it.
   Anywhere is fine: the installer copies the script to `%LOCALAPPDATA%\paste-image-file`, and the menu runs that copy.
2. If you downloaded a ZIP, unblock the scripts so Windows does not warn about internet files:
   ```powershell
   Get-ChildItem -Recurse *.ps1 | Unblock-File
   ```
3. Run the installer:
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\src\Install-PasteImageMenu.ps1
   ```
   It prints `Menu entries added. They run: <path>`.
4. Right-click any folder. On Windows 11, choose **Show more options** first (or Shift+right-click).

## Update

`git pull` (or download again), then run the installer again to refresh the installed copy.

## Move or delete the folder

Nothing to do: the menu runs the installed copy in `%LOCALAPPDATA%\paste-image-file`, not the downloaded folder.

## Uninstall

```powershell
.\src\Install-PasteImageMenu.ps1 -Uninstall
```

This removes both registry keys under `HKCU\Software\Classes\Directory` (see [[How it works]]) and `%LOCALAPPDATA%\paste-image-file`. The installer wrote nothing else.

## Install for every user

Not built in. Run the installer once per user (each gets their own copy under their own `%LOCALAPPDATA%`), or copy the script somewhere every user can read but only admins can write (for example `C:\Program Files\paste-image-file`), and export the two keys and import them under `HKLM\Software\Classes\Directory` as an administrator. Keep the folder admin-writable only: the menu runs whatever script is there.





