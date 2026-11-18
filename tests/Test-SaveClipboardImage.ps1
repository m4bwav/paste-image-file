<#
.SYNOPSIS
  Tests Save-ClipboardImage.ps1 against each kind of clipboard content. Replaces your clipboard!
  Run from Windows PowerShell 5.1 or PowerShell 7:  .\tests\Test-SaveClipboardImage.ps1
  Exit code = number of failures.
#>
$ErrorActionPreference = 'Stop'
$script = Join-Path $PSScriptRoot '..\src\Save-ClipboardImage.ps1'
$out = Join-Path ([IO.Path]::GetTempPath()) ("pif-test-" + [guid]::NewGuid().ToString('N').Substring(0, 8))
New-Item -ItemType Directory $out | Out-Null
$ps = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
$fails = 0

# Clipboard writes happen in a child STA Windows PowerShell so this works from any host.
function Set-TestClipboard([string]$Kind) {
    $code = @'
Add-Type -AssemblyName System.Windows.Forms, System.Drawing
$bmp = New-Object Drawing.Bitmap 40, 30
$g = [Drawing.Graphics]::FromImage($bmp); $g.Clear([Drawing.Color]::FromArgb(128, 0, 128, 255)); $g.Dispose()
$ms = New-Object IO.MemoryStream; $bmp.Save($ms, [Drawing.Imaging.ImageFormat]::Png)
$d = New-Object Windows.Forms.DataObject
switch ('KIND') {
  'bitmap' { [Windows.Forms.Clipboard]::SetImage($bmp); return }
  'png'    { $ms.Position = 0; $d.SetData('PNG', $false, $ms) }
  'html'   { $b64 = [Convert]::ToBase64String($ms.ToArray())
             $d.SetData('HTML Format', "Version:0.9`r`n<html><body><img src=`"data:image/png;base64,$b64`"></body></html>") }
  'text'   { $d.SetText('no image here') }
}
[Windows.Forms.Clipboard]::SetDataObject($d, $true)
'@ -replace 'KIND', $Kind
    # -EncodedCommand: a plain -Command string loses its double quotes on the way to powershell.exe.
    & $ps -NoProfile -STA -EncodedCommand ([Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($code))) *> $null
}

function Assert([string]$Name, [scriptblock]$Check) {
    try { if (& $Check) { "PASS  $Name" } else { "FAIL  $Name"; $script:fails++ } }
    catch { "FAIL  $Name : $($_.Exception.Message)"; $script:fails++ }
}

Set-TestClipboard png
& $script -Path "$out\a.png" | Out-Null
Assert 'PNG stream saved byte-for-byte as .png' { (Test-Path "$out\a.png") -and ([IO.File]::ReadAllBytes("$out\a.png")[0] -eq 0x89) }
& $script -Path "$out\a.png" | Out-Null
Assert 'existing file is not overwritten (a-1.png)' { Test-Path "$out\a-1.png" }
& $script -Path "$out\a.jpg" | Out-Null
Assert 'PNG stream re-encoded as .jpg' { [IO.File]::ReadAllBytes("$out\a.jpg")[0] -eq 0xFF }

Set-TestClipboard bitmap
& $script -Path "$out\b.bmp" | Out-Null
Assert 'bitmap saved as .bmp' { [Text.Encoding]::ASCII.GetString([IO.File]::ReadAllBytes("$out\b.bmp"), 0, 2) -eq 'BM' }

$sub = New-Item -ItemType Directory "$out\folder" ;
& $script -Path "$($sub.FullName)." | Out-Null
Assert 'folder path with Explorer trailing dot gets a timestamped png' { @(Get-ChildItem $sub -Filter 'clipboard_*.png').Count -eq 1 }

Set-TestClipboard html
& $script -Path "$out\c.png" | Out-Null
Assert 'HTML with a data: URI image saved' { (Get-Item "$out\c.png").Length -gt 0 }

Set-TestClipboard text
try { & $script -Path "$out\d.png" 2>$null | Out-Null } catch { }  # the error is expected
Assert 'text-only clipboard fails and writes nothing' { -not (Test-Path "$out\d.png") }

Remove-Item $out -Recurse -Force
"$fails failure(s)"
exit $fails
