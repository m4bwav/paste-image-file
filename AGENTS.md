# Agent notes for paste-image-file

- Two scripts in `src/`: `Save-ClipboardImage.ps1` (clipboard to file) and `Install-PasteImageMenu.ps1` (HKCU Explorer menu). Keep them dependency-free and compatible with Windows PowerShell 5.1.
- Run `tests/Test-SaveClipboardImage.ps1` in both `powershell` and `pwsh` after any change; it replaces the clipboard.
- Keep scripts ASCII-only: Windows PowerShell 5.1 reads BOM-less files as ANSI.
- Design reasons are in `docs/decisions.md`; add an entry when you change behaviour. Session state and log: `ai-docs/`.
- The wiki is a separate repo (`paste-image-file.wiki.git`); its pages are kept in `docs/wiki/` here and pushed from there.
