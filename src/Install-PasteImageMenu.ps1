<#
.SYNOPSIS
  Adds (or with -Uninstall removes) Explorer right-click entries that run Save-ClipboardImage.ps1:
    right-click a folder              -> "Paste image file into"
    right-click empty space in a folder -> "Paste image file here"

.DESCRIPTION
  Writes to HKCU\Software\Classes only, so it needs no administrator rights and affects only
  the current user. On Windows 11 the entries appear under "Show more options" (or Shift+right-click).

  The command runs PowerShell through "conhost.exe --headless", which starts it with no console
  window at all. (-WindowStyle Hidden alone still flashes a window, because the console exists
  before PowerShell can hide it.) If conhost.exe is missing, it falls back to -WindowStyle Hidden.

  The menu points at Save-ClipboardImage.ps1 next to this installer. Move the folder? Run this again.

.EXAMPLE
  .\Install-PasteImageMenu.ps1
.EXAMPLE
  .\Install-PasteImageMenu.ps1 -Uninstall
#>
param(
    [switch]$Uninstall,
    # Where the Directory keys go. Only the tests change this (to a scratch key).
    [string]$RegistryBase = 'HKCU:\Software\Classes\Directory'
)

$base = $RegistryBase
# %1 = the folder that was right-clicked; %V = the folder whose background was right-clicked.
# The trailing "." stops a drive root (D:\) from ending in \" which would escape the quote.
$entries = @(
    @{ Key = "$base\shell\PasteImageFile";            Label = 'Paste image file into'; Arg = '%1.' },
    @{ Key = "$base\Background\shell\PasteImageFile"; Label = 'Paste image file here'; Arg = '%V.' }
)

if ($Uninstall) {
    foreach ($e in $entries) { Remove-Item -LiteralPath $e.Key -Recurse -Force -ErrorAction SilentlyContinue }
    Write-Output 'Menu entries removed.'
    return
}

$script = Join-Path $PSScriptRoot 'Save-ClipboardImage.ps1'
if (-not (Test-Path -LiteralPath $script)) { throw "Save-ClipboardImage.ps1 not found next to the installer ($script)." }

$ps      = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
$conhost = Join-Path $env:SystemRoot 'System32\conhost.exe'
$psArgs  = "-NoProfile -STA -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$script`""
$prefix  = if (Test-Path $conhost) { "`"$conhost`" --headless `"$ps`"" } else { "`"$ps`"" }

foreach ($e in $entries) {
    New-Item -Path "$($e.Key)\command" -Force | Out-Null
    Set-ItemProperty -LiteralPath $e.Key -Name '(default)' -Value $e.Label
    Set-ItemProperty -LiteralPath $e.Key -Name 'Icon' -Value "$ps,0"
    Set-ItemProperty -LiteralPath "$($e.Key)\command" -Name '(default)' -Value "$prefix $psArgs -Path `"$($e.Arg)`" -Gui"
}
Write-Output "Menu entries added. They run: $script"
