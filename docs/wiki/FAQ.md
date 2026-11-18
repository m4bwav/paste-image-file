# FAQ

**Why isn't it in the short Windows 11 right-click menu?**
That menu only shows packaged (MSIX) shell extensions that implement `IExplorerCommand`. That means a signed package and compiled code, for one menu entry. The classic entry under **Show more options** needs neither. Shift+right-click opens the full menu directly.

**Does it run in the background?**
No. Nothing runs until you click the entry, and the script exits as soon as the file is written.

**Why Windows PowerShell 5.1 and not PowerShell 7?**
5.1 is on every Windows, so the menu works with nothing installed. The script also runs under PowerShell 7 from the command line.

**Can I change the default file name or format?**
Edit the `'clipboard_{0:yyyyMMdd_HHmmss}.png'` line in `src/Save-ClipboardImage.ps1`. Change `.png` to `.jpg` for JPEG by default.

**Can I add a "Paste as JPEG" entry too?**
Yes: copy one of the keys in `Install-PasteImageMenu.ps1` with a new key name and label, and pass `-Path "%V.\pasted.jpg"`-style targets, or add a `-Format` parameter. Pull requests welcome.

**Is `-ExecutionPolicy Bypass` safe?**
It applies to that one PowerShell process and only lets it run the script it was given. The real trust boundary is the installed copy in `%LOCALAPPDATA%\paste-image-file`: whoever can edit it controls what the menu runs. That folder is writable only by you (and admins).

**Is `conhost.exe --headless` documented?**
It is the switch Windows uses to host pseudo-consoles (ConPTY), present since Windows 10 1809, and widely used for windowless launches. It is not a documented public API, so a future Windows could change it; the installer falls back to `-WindowStyle Hidden` if `conhost.exe` is missing. See [[How it works]].

**Why does a JPEG come out with a white background?**
JPEG cannot store transparency, so transparent pixels are painted white instead of black.

