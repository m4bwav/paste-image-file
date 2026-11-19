<#
.SYNOPSIS
  Saves the text on the clipboard to a file (UTF-8, no byte order mark).

.DESCRIPTION
  Reads Unicode text from the clipboard. When there is none but Explorer has files on the
  clipboard (Ctrl+C on files), nothing is saved: that is a file copy, not text.
  Line endings are written as they were copied.

.PARAMETER Path
  A file path, or a folder. For a folder (or no -Path at all) the file is named
  clipboard_yyyyMMdd_HHmmss.txt. Any extension works (.md, .json, .csv ...); with none, .txt is added.
  An existing file is never overwritten; a -1, -2 ... suffix is added.

.PARAMETER Gui
  Report errors in a message box instead of the console. The Explorer menu passes this.

.EXAMPLE
  .\Save-ClipboardText.ps1
.EXAMPLE
  .\Save-ClipboardText.ps1 -Path D:\Notes\snippet.md
#>
param(
    [string]$Path = (Get-Location).Path,
    [switch]$Gui
)

if ([Threading.Thread]::CurrentThread.GetApartmentState() -ne 'STA') {
    $exe = (Get-Process -Id $PID).Path
    & $exe -NoProfile -STA -File $PSCommandPath -Path $Path -Gui:$Gui
    exit $LASTEXITCODE
}

Add-Type -AssemblyName System.Windows.Forms

function Stop-WithError([string]$Message) {
    if ($Gui) { [void][Windows.Forms.MessageBox]::Show($Message, 'Paste text file', 'OK', 'Warning') }
    Write-Error $Message
    exit 1
}

# Explorer passes folder paths with a trailing "." (see Install-PasteImageMenu.ps1).
if ($Path.EndsWith('\.')) { $Path = $Path.Substring(0, $Path.Length - 1) }
if ($Path.EndsWith('.') -and (Test-Path -LiteralPath $Path.TrimEnd('.') -PathType Container)) { $Path = $Path.TrimEnd('.') }

if (Test-Path -LiteralPath $Path -PathType Container) {
    $Path = Join-Path $Path ('clipboard_{0:yyyyMMdd_HHmmss}.txt' -f (Get-Date))
}
$Path = [IO.Path]::GetFullPath($Path)

$dir  = [IO.Path]::GetDirectoryName($Path)
$stem = [IO.Path]::GetFileNameWithoutExtension($Path)
$ext  = [IO.Path]::GetExtension($Path)
if (-not $ext) { $ext = '.txt'; $Path += $ext }
$n = 1
while (Test-Path -LiteralPath $Path) { $Path = Join-Path $dir "$stem-$n$ext"; $n++ }

$text = $null
try {
    if ([Windows.Forms.Clipboard]::ContainsText([Windows.Forms.TextDataFormat]::UnicodeText)) {
        $text = [Windows.Forms.Clipboard]::GetText([Windows.Forms.TextDataFormat]::UnicodeText)
    }
} catch {
    Stop-WithError "Could not read the clipboard: $($_.Exception.Message)"
}

if ([string]::IsNullOrEmpty($text)) { Stop-WithError 'No text found on the clipboard. Copy some text first.' }

try {
    [IO.File]::WriteAllText($Path, $text, (New-Object Text.UTF8Encoding $false))
} catch {
    Stop-WithError "Could not save '$Path': $($_.Exception.Message)"
}
Write-Output "Saved $Path"
