<#
.SYNOPSIS
  Tests Install-PasteImageMenu.ps1 against a scratch registry key (HKCU:\Software\paste-image-file-test),
  so the real Explorer menu is never touched. Exit code = number of failures.
#>
$ErrorActionPreference = 'Stop'
$installer = Join-Path $PSScriptRoot '..\src\Install-PasteImageMenu.ps1'
$base = 'HKCU:\Software\paste-image-file-test\Directory'
$fails = 0
$inst = Join-Path ([IO.Path]::GetTempPath()) ('pif-inst-' + [guid]::NewGuid().ToString('N').Substring(0,8))
function Assert([string]$Name, [scriptblock]$Check) {
    try { if (& $Check) { "PASS  $Name" } else { "FAIL  $Name"; $script:fails++ } }
    catch { "FAIL  $Name : $($_.Exception.Message)"; $script:fails++ }
}
function Get-Cmd($k) { (Get-ItemProperty -LiteralPath "$base\$k\PasteImageFile\command").'(default)' }

& $installer -RegistryBase $base -InstallDir $inst | Out-Null
Assert 'folder entry label' { (Get-ItemProperty "$base\shell\PasteImageFile").'(default)' -eq 'Paste image file into' }
Assert 'background entry label' { (Get-ItemProperty "$base\Background\shell\PasteImageFile").'(default)' -eq 'Paste image file here' }
Assert 'folder command uses %1 with trailing dot' { (Get-Cmd 'shell') -like '*-Path "%1." -Gui' }
Assert 'background command uses %V with trailing dot' { (Get-Cmd 'Background\shell') -like '*-Path "%V." -Gui' }
Assert 'command is windowless (conhost --headless)' { (Get-Cmd 'shell') -like '*conhost.exe" --headless *' }
Assert 'command runs Windows PowerShell 5.1 in STA' { (Get-Cmd 'shell') -match 'WindowsPowerShell\\v1\.0\\powershell\.exe" -NoProfile -STA' }
Assert 'command points at an existing script' {
    (Get-Cmd 'shell') -match '-File "([^"]+)"' -and (Test-Path $Matches[1]) -and $Matches[1].StartsWith($inst)
}
Assert 'icon is set' { (Get-ItemProperty "$base\shell\PasteImageFile").Icon -like '*powershell.exe,0' }

& $installer -RegistryBase $base -InstallDir $inst | Out-Null
Assert 'reinstall is idempotent' { (Get-Cmd 'shell') -like '*-Path "%1." -Gui' }

& $installer -RegistryBase $base -InstallDir $inst -Uninstall | Out-Null
Assert 'uninstall removes folder entry' { -not (Test-Path "$base\shell\PasteImageFile") }
Assert 'uninstall removes background entry' { -not (Test-Path "$base\Background\shell\PasteImageFile") }
Assert 'uninstall removes the installed script and its folder' { -not (Test-Path $inst) }
& $installer -RegistryBase $base -InstallDir $inst -Uninstall | Out-Null
Assert 'uninstall twice is harmless' { $true }

# The registered command really runs: execute it against a temp folder, windowless.
& $installer -RegistryBase $base -InstallDir $inst | Out-Null
$ps = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
$code = 'Add-Type -AssemblyName System.Windows.Forms,System.Drawing; [Windows.Forms.Clipboard]::SetImage((New-Object Drawing.Bitmap 8,8))'
& $ps -NoProfile -STA -EncodedCommand ([Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($code))) *> $null
$dir = New-Item -ItemType Directory (Join-Path ([IO.Path]::GetTempPath()) ('pif-menu-' + [guid]::NewGuid().ToString('N').Substring(0,8)))
$line = (Get-Cmd 'shell') -replace '%1', $dir.FullName
if ($line -match '^"([^"]+)" (.*)$') { Start-Process -FilePath $Matches[1] -ArgumentList $Matches[2] -Wait }
Assert 'registered command saves a file into the folder' { @(Get-ChildItem $dir -Filter 'clipboard_*.png').Count -eq 1 }
Remove-Item $dir -Recurse -Force
& $installer -RegistryBase $base -InstallDir $inst -Uninstall | Out-Null

Remove-Item 'HKCU:\Software\paste-image-file-test' -Recurse -Force
"$fails failure(s)"
exit $fails

