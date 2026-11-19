# Usage

## From Explorer

1. Copy an image: right-click it in a browser and choose **Copy image**, take a screenshot with Win+Shift+S, or copy from any image program.
2. In Explorer, right-click:
   - a **folder** and choose **Paste image file into**, to save inside that folder, or
   - **empty space** in the folder you have open and choose **Paste image file here**.
3. The file appears as `clipboard_20261118_143005.png`.

If there is no image on the clipboard, a message box says so and nothing is written.

## Pasting text

Copy any text, then right-click a folder and choose **Paste text file into**, or empty space and choose **Paste text file here**. The text is saved as `clipboard_20261118_143005.txt`, UTF-8 without a byte order mark, with line endings as copied. With no text on the clipboard, a message box says so and nothing is written.

```powershell
.\src\Save-ClipboardText.ps1 -Path D:\Notes            # timestamped .txt in a folder
.\src\Save-ClipboardText.ps1 -Path D:\Notes\snippet.md # any extension; none gets .txt
```

It takes the same `-Path` and `-Gui` parameters as the image script and never overwrites.

## From PowerShell

```powershell
.\src\Save-ClipboardImage.ps1                          # into the current folder
.\src\Save-ClipboardImage.ps1 -Path D:\Pictures         # into a folder, timestamped name
.\src\Save-ClipboardImage.ps1 -Path D:\Pictures\cat.jpg # exact name; format from the extension
.\src\Save-ClipboardImage.ps1 -Path D:\Pictures -Gui    # errors in a message box
```

| Parameter | Meaning |
|---|---|
| `-Path` | A file or a folder. Default: the current folder. A file with no extension gets `.png`. |
| `-Gui` | Show errors in a message box. The menu uses this, because it has no console. |

Output: `Saved <full path>` on success, exit code 0. Exit code 1 and an error on failure.

## Formats

| Extension | Notes |
|---|---|
| `.png` | Default. Browser PNG data is copied as-is, transparency kept. |
| `.jpg`, `.jpeg` | Transparent areas become white (JPEG has no transparency). |
| `.bmp` | Uncompressed. |
| `.gif` | 256 colours; fine for simple graphics only. |
| `.tif`, `.tiff` | |

Anything else is refused. WebP and AVIF are not available through the built-in .NET image encoder.

## File names

- Folder target: `clipboard_yyyyMMdd_HHmmss.png`, local time.
- If the name exists (two pastes in one second, or a name you chose), `-1`, `-2` and so on is added. Nothing is ever overwritten.

## Tips

- Pin a folder like `Pictures\Pasted` to Quick Access, then paste into it from anywhere in Explorer's navigation pane.
- From a script, use the exit code: `if (.\src\Save-ClipboardImage.ps1 -Path $dir) { ... }`.
