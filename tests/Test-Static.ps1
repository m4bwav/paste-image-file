<#
.SYNOPSIS
  Static checks that need no clipboard: every .ps1 is ASCII-only and parses, and
  PSScriptAnalyzer reports no errors (when it is installed). Exit code = number of failures.
#>
$root = Split-Path $PSScriptRoot -Parent
$fails = 0
foreach ($f in Get-ChildItem $root -Recurse -Filter *.ps1) {
    $rel = $f.FullName.Substring($root.Length + 1)
    if ([IO.File]::ReadAllBytes($f.FullName) | Where-Object { $_ -gt 127 } | Select-Object -First 1) {
        "FAIL  $rel has non-ASCII bytes (Windows PowerShell 5.1 would misread them)"; $fails++
    } else { "PASS  $rel is ASCII" }
    $errs = $null
    [void][Management.Automation.Language.Parser]::ParseFile($f.FullName, [ref]$null, [ref]$errs)
    if ($errs) { "FAIL  $rel parse: $($errs[0].Message)"; $fails++ } else { "PASS  $rel parses" }
}
if (Get-Module -ListAvailable PSScriptAnalyzer) {
    $issues = Invoke-ScriptAnalyzer -Path (Join-Path $root 'src') -Severity Error
    if ($issues) { $issues | ForEach-Object { "FAIL  analyzer: $($_.ScriptName):$($_.Line) $($_.Message)" }; $fails += @($issues).Count }
    else { 'PASS  PSScriptAnalyzer: no errors in src/' }
} else { 'SKIP  PSScriptAnalyzer not installed' }
"$fails failure(s)"
exit $fails
