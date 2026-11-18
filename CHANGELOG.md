# Changelog

## 0.1.0 - 2026-11-18

- First release.
- `Save-ClipboardImage.ps1`: saves the clipboard image (PNG stream, bitmap, or HTML `<img>`) to PNG, JPEG, BMP, GIF or TIFF; folder targets get a timestamped name; never overwrites.
- `Install-PasteImageMenu.ps1`: per-user Explorer entries "Paste image file into" (folder) and "Paste image file here" (folder background), run windowless through `conhost.exe --headless`; `-Uninstall` removes them.
- Tests for each clipboard source in Windows PowerShell 5.1 and PowerShell 7.
