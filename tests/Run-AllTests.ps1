<#
.SYNOPSIS
  Runs every test file under Windows PowerShell 5.1 and, if installed, PowerShell 7.
  Replaces your clipboard. -SkipClipboard runs only the static and installer tests.
#>
param([switch]$SkipClipboard)
$tests = @('Test-Static.ps1', 'Test-Installer.ps1')
if (-not $SkipClipboard) { $tests += 'Test-SaveClipboardImage.ps1' }
$hosts = @(Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe')
if (Get-Command pwsh -ErrorAction SilentlyContinue) { $hosts += (Get-Command pwsh).Source }
$total = 0
foreach ($h in $hosts) {
    foreach ($t in $tests) {
        "=== $(Split-Path $h -Leaf) $t"
        & $h -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot $t)
        $total += $LASTEXITCODE
    }
}
"TOTAL: $total failure(s)"
exit $total
