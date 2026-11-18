# Troubleshooting

| Symptom | Cause and fix |
|---|---|
| The menu entry is missing on Windows 11 | Classic entries live under **Show more options**, or Shift+right-click. Getting onto the short Windows 11 menu needs a packaged (MSIX) shell extension, which this project deliberately avoids. |
| "No image found on the clipboard" | Nothing image-shaped was copied. In a browser use *Copy image*, not *Copy image address*. Copying a file in Explorer copies a file reference, not pixels. |
| A window still flashes | The installer could not find `C:\Windows\System32\conhost.exe` and fell back to `-WindowStyle Hidden`, or the entries come from an older install. Run `src\Install-PasteImageMenu.ps1` again and check the command under `HKCU\Software\Classes\Directory\shell\PasteImageFile\command` starts with `conhost.exe --headless`. |
| Nothing happens after moving the folder | The menu points at the old path. Run the installer from the new location. |
| A saved JPEG has a white background where the image was transparent | Expected: JPEG has no transparency. Save as `.png` to keep it. |
| Transparent areas came out black in a PNG | The source program put only a bitmap on the clipboard (no PNG data). Copy from a browser, or from a program that offers PNG. |
| "The copied HTML points at ..." | The page copied markup whose image is a relative or `file:` URL. Open the image on its own and use *Copy image*. |
| Antivirus warns about the command | Some products flag `-ExecutionPolicy Bypass` or `conhost --headless`. Both are explained in [how-it-works.md](how-it-works.md); read the two scripts (about 150 lines) before allowing them. |
| Script blocked: "is not digitally signed" from the command line | Run with `powershell -ExecutionPolicy Bypass -File ...`, or `Unblock-File` the downloaded scripts. The menu entry already passes Bypass. |

To see the error text without the menu, run the script yourself:

```powershell
.\src\Save-ClipboardImage.ps1 -Path $env:TEMP
```
