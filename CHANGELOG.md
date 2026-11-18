# Changelog

## 0.2.0 - 2026-11-18

- The installer now copies the script to `%LOCALAPPDATA%\paste-image-file` and the menu runs that copy, so the downloaded folder can be moved or deleted. Re-run the installer after updating. `-Uninstall` also removes the copy.
- `-InstallDir` parameter (for tests); installer tests cover the copy and its removal.

## 0.1.1 - 2026-11-18

- Tests: installer suite (scratch registry key), static checks (ASCII, parse, PSScriptAnalyzer), 13 more clipboard cases (http download, file: refusal, GIF/TIFF, extensions, JPEG white background, MTA relaunch), `tests/Run-AllTests.ps1`.
- CI on windows-latest for every push and pull request.
- `Install-PasteImageMenu.ps1 -RegistryBase` for testing.
- `tools/Publish-Wiki.ps1`; wiki published.

## 0.1.0 - 2026-11-18

- First release.
- `Save-ClipboardImage.ps1`: saves the clipboard image (PNG stream, bitmap, or HTML `<img>`) to PNG, JPEG, BMP, GIF or TIFF; folder targets get a timestamped name; never overwrites.
- `Install-PasteImageMenu.ps1`: per-user Explorer entries "Paste image file into" (folder) and "Paste image file here" (folder background), run windowless through `conhost.exe --headless`; `-Uninstall` removes them.
- Tests for each clipboard source in Windows PowerShell 5.1 and PowerShell 7.


