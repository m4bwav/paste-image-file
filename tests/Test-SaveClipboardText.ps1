<#
.SYNOPSIS
  Tests Save-ClipboardText.ps1. Replaces your clipboard! Exit code = number of failures.
#>
$ErrorActionPreference = 'Stop'
$script = Join-Path $PSScriptRoot '..\src\Save-ClipboardText.ps1'
$out = Join-Path ([IO.Path]::GetTempPath()) ("pif-text-" + [guid]::NewGuid().ToString('N').Substring(0, 8))
New-Item -ItemType Directory $out | Out-Null
$ps = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
$fails = 0
# Non-ASCII sample built from code points so this file stays ASCII.
$sample = "line one`r`nGr" + [char]0x00FC + "n " + [char]0x65E5 + [char]0x672C + "`r`nlast"

function Set-TestClipboard([string]$Kind, [string]$Text) {
    # The text travels in an environment variable (the child inherits it).
    $env:PIF_TEST_TEXT = $Text
    $code = @'
Add-Type -AssemblyName System.Windows.Forms, System.Drawing
$d = New-Object Windows.Forms.DataObject
switch ('KIND') {
  'text'   { $d.SetText($env:PIF_TEST_TEXT) }
  'bitmap' { [Windows.Forms.Clipboard]::SetImage((New-Object Drawing.Bitmap 8, 8)); return }
}
[Windows.Forms.Clipboard]::SetDataObject($d, $true)
'@ -replace 'KIND', $Kind
    & $ps -NoProfile -STA -EncodedCommand ([Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($code))) *> $null
}

function Assert([string]$Name, [scriptblock]$Check) {
    try { if (& $Check) { "PASS  $Name" } else { "FAIL  $Name"; $script:fails++ } }
    catch { "FAIL  $Name : $($_.Exception.Message)"; $script:fails++ }
}

Set-TestClipboard text $sample
& $script -Path "$out\a.txt" | Out-Null
Assert 'text saved exactly, UTF-8' { [IO.File]::ReadAllText("$out\a.txt", [Text.Encoding]::UTF8) -ceq $sample }
Assert 'no byte order mark' { [IO.File]::ReadAllBytes("$out\a.txt")[0] -eq [byte][char]'l' }
& $script -Path "$out\a.txt" | Out-Null
Assert 'existing file is not overwritten (a-1.txt)' { Test-Path "$out\a-1.txt" }
& $script -Path "$out\notes.md" | Out-Null
Assert 'other extensions kept (.md)' { Test-Path "$out\notes.md" }
& $script -Path "$out\noext" | Out-Null
Assert 'no extension gets .txt' { Test-Path "$out\noext.txt" }

$sub = New-Item -ItemType Directory "$out\folder"
& $script -Path "$($sub.FullName)." | Out-Null
Assert 'folder path with Explorer trailing dot gets a timestamped txt' { @(Get-ChildItem $sub -Filter 'clipboard_*.txt').Count -eq 1 }

Set-TestClipboard bitmap ''
$threw = $false
try { & $script -Path "$out\none.txt" 2>$null | Out-Null } catch { $threw = $true }
Assert 'image only: error and no file' { $threw -and -not (Test-Path "$out\none.txt") }

Remove-Item $out -Recurse -Force
"$fails failure(s)"
exit $fails
