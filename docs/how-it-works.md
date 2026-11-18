# How it works

## The two scripts

- `src/Save-ClipboardImage.ps1` reads the clipboard and writes a file. It works on its own from any PowerShell prompt.
- `src/Install-PasteImageMenu.ps1` copies the first script to `%LOCALAPPDATA%\paste-image-file\` and writes two registry keys that make Explorer run that copy. The downloaded folder is not needed afterwards.

## Registry keys

Both live under `HKEY_CURRENT_USER\Software\Classes\Directory`, which only affects the current user and needs no admin rights:

| Key | Shown when you right-click | Placeholder |
|---|---|---|
| `shell\PasteImageFile` | a folder icon | `%1` = that folder |
| `Background\shell\PasteImageFile` | empty space inside a folder window | `%V` = the open folder |

Each key has a default value (the menu text), an `Icon` value (PowerShell's icon) and a `command` subkey holding the command line.

## The command line

```
"C:\Windows\System32\conhost.exe" --headless "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
    -NoProfile -STA -ExecutionPolicy Bypass -WindowStyle Hidden
    -File "%LOCALAPPDATA%\paste-image-file\Save-ClipboardImage.ps1" -Path "%1." -Gui
```

- **`conhost.exe --headless`** starts PowerShell with a pseudo-console and no window. Without it, Windows creates a console window (or a Windows Terminal tab, if Terminal is the default) before PowerShell can hide it, so `-WindowStyle Hidden` alone flashes. `--headless` is the flag Windows uses internally for ConPTY; it exists on Windows 10 1809 and later. If `conhost.exe` is missing, the installer falls back to `-WindowStyle Hidden`.
- **Windows PowerShell 5.1**, not PowerShell 7: it ships with every Windows, so the menu works without anything else installed.
- **`-STA`**: the Windows Forms clipboard API only works in a single-threaded apartment.
- **`-ExecutionPolicy Bypass`** for this process only, so a downloaded script runs without changing the machine's policy.
- **`"%1."`, with a trailing dot**: for a drive root, `%1` is `D:\`, and `"D:\"` on a command line means the backslash escapes the closing quote, so PowerShell receives a broken argument. `"D:\."` is safe; the script strips the dot again.
- **`-Gui`**: with no console, errors would be invisible, so the script shows them in a message box instead.

## Reading the clipboard

The script asks for formats in this order and uses the first one present:

1. `PNG`, a registered clipboard format holding a PNG file stream. Chromium browsers and Firefox write it on *Copy image*. It is the only common format that keeps alpha. When the target is `.png` the stream is copied straight to disk.
2. `CF_BITMAP` / `CF_DIB`, via `Clipboard.GetImage()`. Screenshots and most desktop programs. No alpha in practice.
3. `HTML Format`. Some pages copy only markup. The first `<img src="...">` is fetched with `Invoke-WebRequest`, or decoded when it is `data:image/...;base64,...`. Relative URLs and `file:` URLs are refused.

JPEG output is flattened onto white first, because JPEG has no alpha and transparent pixels would otherwise turn black.

## File names

A folder (or no `-Path`) means `clipboard_yyyyMMdd_HHmmss.png`. If the name exists, `-1`, `-2` ... is appended, so a quick double paste never overwrites anything. A path with no extension gets `.png`.


