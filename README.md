# paste-image-file

[![tests](https://github.com/m4bwav/paste-image-file/actions/workflows/tests.yml/badge.svg)](https://github.com/m4bwav/paste-image-file/actions/workflows/tests.yml)

![A folder, an image card and a mouse cursor on a right-click menu, in teal and orange on dark navy](https://raw.githubusercontent.com/m4bwav/paste-image-file/main/.github/images/banner.jpg)

Copy an image in your browser, right-click a folder in Windows Explorer, choose **Paste image file into**, and the image is saved there as a PNG. No window opens.

Two small PowerShell scripts, no install beyond a per-user registry entry, no admin rights, nothing running in the background.

| Right-click on | Menu entry | Saves to |
|---|---|---|
| a folder | **Paste image file into** | inside that folder |
| empty space in an open folder | **Paste image file here** | the folder you are looking at |

Files are named `clipboard_yyyyMMdd_HHmmss.png`. An existing file is never overwritten.

## Install

1. Download or clone this repository somewhere it can stay (the menu points at the script's location).
2. In PowerShell, from the repository folder:

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\src\Install-PasteImageMenu.ps1
   ```

3. On Windows 11 the entries are under **Show more options** (or hold Shift while you right-click).

To remove the entries: `.\src\Install-PasteImageMenu.ps1 -Uninstall`. Moved the folder? Run the installer again.

## Use from the command line

```powershell
.\src\Save-ClipboardImage.ps1                          # clipboard_<timestamp>.png in the current folder
.\src\Save-ClipboardImage.ps1 -Path D:\Pictures         # same, into a folder
.\src\Save-ClipboardImage.ps1 -Path D:\Pictures\cat.jpg # format follows the extension
```

Supported extensions: `.png`, `.jpg`/`.jpeg`, `.bmp`, `.gif`, `.tif`/`.tiff`. Exit code 0 on success, 1 when there is no image or the save fails.

## What it can read from the clipboard

1. **PNG data**, which Chrome, Edge and Firefox put there on *Copy image*. Saved to `.png` byte for byte, so transparency survives.
2. **A bitmap**, from screenshots (Win+Shift+S), Paint, Office and most programs.
3. **HTML only**, from some sites and "copy" buttons: the first `<img src>` is downloaded, or decoded if it is a `data:` URI.

Copying a *file* in Explorer (Ctrl+C on a .png) puts a file reference on the clipboard, not image data, so there is nothing to paste; use Explorer's own Paste for that.

## Why no window appears

Explorer starts the script through `conhost.exe --headless`, which runs PowerShell without creating a console window. `-WindowStyle Hidden` on its own still flashes a window, because the console exists before PowerShell gets to hide it. Details and other options on the wiki: [How it works](https://github.com/m4bwav/paste-image-file/wiki/How-it-works).

## Requirements

Windows 10 (1809 or later) or Windows 11, with the built-in Windows PowerShell 5.1. PowerShell 7 works for command-line use too.

## Documentation

The [wiki](https://github.com/m4bwav/paste-image-file/wiki) covers installation, every clipboard format, how the menu entry is built, troubleshooting and development. Design notes are in [docs/](docs/).

## Tests

```powershell
.\tests\Run-AllTests.ps1   # static, installer and clipboard tests in PowerShell 5.1 and 7; replaces your clipboard
```

CI runs the same on every push. Details: [Development](https://github.com/m4bwav/paste-image-file/wiki/Development).

## Licence

MIT. See [LICENSE](LICENSE). The banner was made with Z-Image Turbo on a local ComfyUI; prompt, seed and workflow are in [.github/images/banner-src/](.github/images/banner-src/).


