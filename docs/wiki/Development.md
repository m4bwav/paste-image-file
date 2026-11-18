# Development

## Layout

```
src/Save-ClipboardImage.ps1      clipboard -> file
src/Install-PasteImageMenu.ps1   Explorer menu entries (HKCU)
tests/Test-SaveClipboardImage.ps1
docs/                            how-it-works, troubleshooting, decisions, wiki/ (source of these pages)
.github/images/                  banner, social preview, banner-src/ (prompt, seed, workflow)
ai-docs/                         log and handoff for AI-assisted sessions
```

## Tests

```powershell
powershell -ExecutionPolicy Bypass -File .\tests\Test-SaveClipboardImage.ps1
pwsh -File .\tests\Test-SaveClipboardImage.ps1
```

They **replace your clipboard**. Each case fills the clipboard in a child Windows PowerShell (PNG stream, bitmap, HTML with a data URI, plain text) and checks the saved file's magic bytes. The exit code is the number of failures. There is no CI: GitHub's hosted Windows runners have no interactive desktop clipboard, so tests run locally.

The menu itself is checked by hand: run the installer, right-click a folder, right-click a folder background, right-click a drive root.

## Conventions

- Windows PowerShell 5.1 compatible; no modules, no external tools.
- ASCII-only scripts (5.1 reads BOM-less files as ANSI). `.gitattributes` keeps `.ps1` as CRLF.
- Behaviour changes get an entry in `docs/decisions.md` and `CHANGELOG.md`.

## Wiki

These pages live in `docs/wiki/` in the main repository. To publish: `.\tools\Publish-Wiki.ps1` (it checks the wiki repo exists, clones or pulls it beside this repo, copies the pages and pushes).

## Releasing

Bump the version in `CHANGELOG.md` and the wiki Home page, tag `vX.Y.Z`, and create a GitHub release with the changelog section as notes.

