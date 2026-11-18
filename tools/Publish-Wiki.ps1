<#
.SYNOPSIS
  Copies docs/wiki/*.md into the GitHub wiki repository and pushes it.
  The wiki git repo only exists after a first page has been saved once in the web UI
  (https://github.com/m4bwav/paste-image-file/wiki/_new). This script checks that first.
#>
$ErrorActionPreference = 'Stop'
$repo = Split-Path $PSScriptRoot -Parent
$url  = 'https://github.com/m4bwav/paste-image-file.wiki.git'
$wiki = Join-Path (Split-Path $repo -Parent) 'paste-image-file.wiki'

git ls-remote $url *> $null
if ($LASTEXITCODE -ne 0) { throw "Wiki repo not created yet. Save any first page at https://github.com/m4bwav/paste-image-file/wiki/_new, then rerun." }

if (-not (Test-Path $wiki)) { git clone -q $url $wiki } else { git -C $wiki pull -q }
Copy-Item (Join-Path $repo 'docs\wiki\*.md') $wiki -Force
git -C $wiki add -A
git -C $wiki diff --cached --quiet
if ($LASTEXITCODE -eq 0) { 'Wiki already up to date.'; return }
git -C $wiki commit -q -m 'Update wiki from docs/wiki'
git -C $wiki push -q
'Wiki pushed: https://github.com/m4bwav/paste-image-file/wiki'
