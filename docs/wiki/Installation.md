# Installation

## Requirements

- Windows 10 version 1809 or later, or Windows 11.
- Windows PowerShell 5.1, which every supported Windows already has. PowerShell 7 is not needed.
- No administrator rights.

## Install

1. Get the files: `git clone https://github.com/m4bwav/paste-image-file.git`, or **Code > Download ZIP** and extract it.
   Put the folder somewhere permanent, such as `C:\Tools\paste-image-file`. The menu entry points at the script inside it.
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

`git pull` (or replace the files). If the folder did not move, nothing else is needed: the menu runs the script from disk every time.

## Move the folder

Run the installer again from the new place. It overwrites the old entries.

## Uninstall

```powershell
.\src\Install-PasteImageMenu.ps1 -Uninstall
```

Then delete the folder. The installer wrote nothing else: two keys under `HKCU\Software\Classes\Directory` (see [[How it works]]).

## Install for every user

Not built in. Copy the folder somewhere every user can read but only admins can write (for example `C:\Program Files\paste-image-file`), and run the installer once per user, or export the two keys and import them under `HKLM\Software\Classes\Directory` as an administrator. Keep the folder admin-writable only: the menu runs whatever script is there.
