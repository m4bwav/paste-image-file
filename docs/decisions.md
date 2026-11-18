# Design decisions

Each entry: what was chosen, what else was considered, why.

## 2026-11-18 Hide the window with `conhost.exe --headless`

- **Chosen:** prefix the command with `conhost.exe --headless`.
- **Considered:** `-WindowStyle Hidden` alone (still flashes, tested); a VBScript `wscript` wrapper (works, but VBScript is deprecated and being removed from Windows); a compiled C# launcher (an .exe in a script repo is harder to trust and needs building); `pwsh -WindowStyle Hidden` (same flash, and needs PowerShell 7 installed).
- **Why:** no extra file, nothing deprecated, verified on Windows 11 26200 to save the file with no window.

## 2026-11-18 Per-user registry keys, classic context menu

- **Chosen:** `HKCU\Software\Classes\Directory\shell` and `...\Background\shell`.
- **Considered:** HKLM (all users; needs admin); an `IExplorerCommand` MSIX package for the top-level Windows 11 menu (needs signing and packaging).
- **Why:** no admin, trivially removable, works on Windows 10 and 11.

## 2026-11-18 Never overwrite

A suffix is added when the target exists. A paste tool that silently replaces a file is worse than one that leaves an extra file.

## 2026-11-18 Prefer the PNG clipboard format

Browsers put both a PNG stream and a bitmap on the clipboard. The bitmap loses transparency, so PNG is read first and written byte for byte.

## 2026-11-18 Install a copy to %LOCALAPPDATA%

- **Chosen:** the installer copies `Save-ClipboardImage.ps1` to `%LOCALAPPDATA%\paste-image-file` and the menu runs that copy.
- **Considered:** pointing at the downloaded folder (0.1.x; the menu broke when the folder moved or a ZIP download was deleted); `Program Files` (needs admin).
- **Why:** the download can go anywhere or be deleted; per-user, no admin; updating means re-running the installer, which is explicit.
