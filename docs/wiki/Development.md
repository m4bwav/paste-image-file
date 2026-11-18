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
.\tests\Run-AllTests.ps1                 # every suite, in Windows PowerShell 5.1 and PowerShell 7
.\tests\Run-AllTests.ps1 -SkipClipboard  # static + installer only
```

| File | What it checks |
|---|---|
| `tests/Test-Static.ps1` | every `.ps1` is ASCII and parses; PSScriptAnalyzer errors when installed |
| `tests/Test-Installer.ps1` | labels, `%1.`/`%V.` arguments, `conhost --headless`, STA, icon, idempotent reinstall, uninstall, and that the registered command really saves a file. Uses a scratch key `HKCU:\Software\paste-image-file-test` via `-RegistryBase`, so your real menu is untouched |
| `tests/Test-SaveClipboardImage.ps1` | PNG stream, bitmap, HTML `data:` and `http` images, refused `file:` URLs, text-only clipboard, every output format, upper-case and missing extensions, unsupported extension, no overwrite, spaces and brackets in folders, JPEG transparency to white, MTA PowerShell 7 relaunch |

The clipboard tests **replace your clipboard**. Each exit code is its failure count.

CI (`.github/workflows/tests.yml`) runs `Run-AllTests.ps1` on `windows-latest` for every push and pull request. The hosted runner has a working clipboard (verified 2026-11-18).

## Conventions

- Windows PowerShell 5.1 compatible; no modules, no external tools.
- ASCII-only scripts (5.1 reads BOM-less files as ANSI). `.gitattributes` keeps `.ps1` as CRLF.
- Behaviour changes get an entry in `docs/decisions.md` and `CHANGELOG.md`.

## Wiki

These pages live in `docs/wiki/` in the main repository. To publish: `.\tools\Publish-Wiki.ps1` (it checks the wiki repo exists, clones or pulls it beside this repo, copies the pages and pushes).

## Releasing

Bump the version in `CHANGELOG.md` and the wiki Home page, tag `vX.Y.Z`, and create a GitHub release with the changelog section as notes.


