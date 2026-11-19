# Log

- 2026-11-18: Built from a one-off script in D:/m4bwa/Claude/Projects/Ai. Window flash fixed with conhost --headless (-WindowStyle Hidden alone flashed). Drive-root quoting bug fixed with a trailing dot on %1/%V. Tests pass on PowerShell 5.1 and 7. Menu installed on Mark's PC pointing at this clone's src/.
- 2026-11-18: Wiki created via Chrome first-page save then tools/Publish-Wiki.ps1; social preview uploaded via Chrome file input. Added installer/static tests and CI; GitHub windows-latest runner has a working clipboard. Released 0.1.1.
- 2026-11-18: 0.2.0: installer copies the script to %LOCALAPPDATA%\paste-image-file and the menu runs the copy (Mark asked that moving the clone not break the menu). Reinstalled on Mark's PC.
- 2026-11-19: 0.3.0: text pastes (Save-ClipboardText.ps1, UTF-8 no BOM) with their own menu entries. Test gotcha: a child powershell -EncodedCommand containing [Convert]::FromBase64String was refused with "Access is denied" (likely Defender/AMSI); pass test text through an environment variable instead. Reinstalled on Mark's PC.
