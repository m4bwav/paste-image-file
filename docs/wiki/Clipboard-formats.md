# Clipboard formats

The Windows clipboard holds one item in several formats at once; each program decides which to offer. The script reads them in this order and uses the first one it finds.

| Order | Format | Who writes it | What is saved |
|---|---|---|---|
| 1 | `PNG` (registered format, a PNG file stream) | Chrome, Edge and other Chromium browsers, Firefox, many modern apps | The PNG bytes exactly, when saving as `.png`. Transparency kept. Other formats are re-encoded from it. |
| 2 | `CF_DIB` / `CF_BITMAP` (bitmap) | Snipping Tool and Win+Shift+S, PrintScreen, Paint, Office, most desktop programs | Decoded and encoded to the chosen format. Transparency usually lost. |
| 3 | `HTML Format` | Some web pages, rich-text copies, "copy" buttons that copy markup | The first `<img src>`: an `http(s)` URL is downloaded; a `data:image/...;base64` URI is decoded. |

## What does not work

- **Copying a file in Explorer** (Ctrl+C on `photo.png`) puts a *file list* on the clipboard, not pixels. Use Explorer's ordinary Paste.
- **Copy image address / Copy link** copies text, not an image.
- **Relative or `file:` image URLs** in copied HTML are refused: there is no page address to resolve them against, and reading local files from clipboard content would be surprising.
- **Animated GIFs** copied from a browser arrive as a single still frame; browsers only put the first frame on the clipboard.

## Inspecting the clipboard yourself

```powershell
Add-Type -AssemblyName System.Windows.Forms
[Windows.Forms.Clipboard]::GetDataObject().GetFormats()
```

Run it in Windows PowerShell (STA). A browser image copy typically lists `PNG`, `Bitmap`, `DeviceIndependentBitmap` and `HTML Format`.
