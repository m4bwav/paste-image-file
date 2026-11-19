# Agent notes for paste-image-file

- Three scripts in `src/`: `Save-ClipboardImage.ps1` (clipboard image to file), `Save-ClipboardText.ps1` (clipboard text to file) and `Install-PasteImageMenu.ps1` (HKCU Explorer menu). Keep them dependency-free and compatible with Windows PowerShell 5.1.
- Run `tests/Run-AllTests.ps1` after any change (it runs both `powershell` and `pwsh`); it replaces the clipboard.
- Keep scripts ASCII-only: Windows PowerShell 5.1 reads BOM-less files as ANSI.
- Design reasons are in `docs/decisions.md`; add an entry when you change behaviour. Session state and log: `ai-docs/`.
- The wiki is a separate repo (`paste-image-file.wiki.git`); its pages are kept in `docs/wiki/` here and pushed from there.
