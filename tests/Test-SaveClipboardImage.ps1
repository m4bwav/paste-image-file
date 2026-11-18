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

Set-TestClipboard png
& $script -Path "$out\e.gif" | Out-Null
Assert 'saved as .gif' { [Text.Encoding]::ASCII.GetString([IO.File]::ReadAllBytes("$out\e.gif"), 0, 3) -eq 'GIF' }
& $script -Path "$out\e.tiff" | Out-Null
Assert 'saved as .tiff' { [IO.File]::ReadAllBytes("$out\e.tiff")[0] -eq 0x49 }
& $script -Path "$out\E.JPG" | Out-Null
Assert 'upper-case extension works' { [IO.File]::ReadAllBytes("$out\E.JPG")[0] -eq 0xFF }
& $script -Path "$out\noext" | Out-Null
Assert 'no extension gets .png' { Test-Path "$out\noext.png" }
try { & $script -Path "$out\f.webp" 2>$null | Out-Null } catch { }
Assert 'unsupported extension is refused' { -not (Test-Path "$out\f.webp") }
$spaced = New-Item -ItemType Directory "$out\with space [and brackets]"
& $script -Path $spaced.FullName | Out-Null
Assert 'folder with spaces and brackets' { @(Get-ChildItem -LiteralPath $spaced.FullName).Count -eq 1 }
& $script -Path "$out\g.jpg" | Out-Null
Assert 'JPEG flattens transparency onto white, not black' {
    Add-Type -AssemblyName System.Drawing
    $b = [Drawing.Bitmap]::FromFile("$out\g.jpg"); $p = $b.GetPixel(5, 5); $b.Dispose()
    # source is 50% alpha blue over white -> light blue; over black it would be dark
    ($p.R + $p.G + $p.B) -gt 400
}
Push-Location $out
& $script | Out-Null
Pop-Location
Assert 'no -Path saves into the current folder' { @(Get-ChildItem $out -Filter 'clipboard_*.png').Count -ge 1 }

# HTML with an http image URL: serve the PNG from a local listener.
$port = Get-Random -Minimum 20000 -Maximum 40000
$job = Start-Job -ArgumentList $port {
    param($port)
    Add-Type -AssemblyName System.Drawing
    $l = [Net.HttpListener]::new(); $l.Prefixes.Add("http://127.0.0.1:$port/"); $l.Start()
    $ms = New-Object IO.MemoryStream; (New-Object Drawing.Bitmap 12, 9).Save($ms, [Drawing.Imaging.ImageFormat]::Png)
    $c = $l.GetContext(); $c.Response.ContentType = 'image/png'; $c.Response.ContentLength64 = $ms.Length
    $c.Response.OutputStream.Write($ms.ToArray(), 0, $ms.Length); $c.Response.Close(); $l.Stop()
}
Start-Sleep -Milliseconds 800
$code = @"
Add-Type -AssemblyName System.Windows.Forms
`$d = New-Object Windows.Forms.DataObject
`$d.SetData('HTML Format', '<img alt="x" src="http://127.0.0.1:$port/pic.png?a=1&amp;b=2">')
[Windows.Forms.Clipboard]::SetDataObject(`$d, `$true)
"@
& $ps -NoProfile -STA -EncodedCommand ([Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($code))) *> $null
try { & $script -Path "$out\h.png" | Out-Null } catch { "      ($($_.Exception.Message))" }
Wait-Job $job -Timeout 10 | Out-Null; Remove-Job $job -Force
Assert 'HTML with an http image URL is downloaded' {
    Add-Type -AssemblyName System.Drawing
    $b = [Drawing.Image]::FromFile("$out\h.png"); $w = $b.Width; $b.Dispose(); $w -eq 12
}

$code = "Add-Type -AssemblyName System.Windows.Forms; `$d = New-Object Windows.Forms.DataObject; `$d.SetData('HTML Format', '<img src=""file:///C:/Windows/win.ini"">'); [Windows.Forms.Clipboard]::SetDataObject(`$d, `$true)"
& $ps -NoProfile -STA -EncodedCommand ([Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($code))) *> $null
try { & $script -Path "$out\i.png" 2>$null | Out-Null } catch { }
Assert 'file: URLs in HTML are refused' { -not (Test-Path "$out\i.png") }

# MTA host: the script must relaunch itself in STA.
if (Get-Command pwsh -ErrorAction SilentlyContinue) {
    Set-TestClipboard bitmap
    pwsh -NoProfile -MTA -File $script -Path "$out\j.png" *> $null
    Assert 'relaunches itself from an MTA PowerShell 7' { Test-Path "$out\j.png" }
}

Remove-Item $out -Recurse -Force
"$fails failure(s)"
exit $fails
