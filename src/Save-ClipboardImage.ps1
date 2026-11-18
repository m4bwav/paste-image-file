<#
.SYNOPSIS
  Saves the image on the clipboard (for example from "Copy image" in a web browser) to a file.

.DESCRIPTION
  Looks for an image on the clipboard in this order:
    1. A "PNG" stream. Chrome, Edge and Firefox put one there; it keeps transparency.
    2. A plain bitmap (screenshots, Paint, Office, most other programs).
    3. HTML only (some sites, some "copy" buttons): the first <img src="..."> is
       downloaded, or decoded when it is a data: URI.

  The output format follows the file extension: .png (default), .jpg/.jpeg, .bmp, .gif, .tif/.tiff.
  When the PNG stream is present and the target is .png, its bytes are written as-is (no re-encode).

.PARAMETER Path
  A file path, or a folder. For a folder (or no -Path at all) the file is named
  clipboard_yyyyMMdd_HHmmss.png. An existing file is never overwritten; a -1, -2 ... suffix is added.

.PARAMETER Gui
  Report errors in a message box instead of the console. The Explorer menu passes this,
  because it runs the script with no console window.

.EXAMPLE
  .\Save-ClipboardImage.ps1
.EXAMPLE
  .\Save-ClipboardImage.ps1 -Path D:\Pictures\cat.jpg
.EXAMPLE
  .\Save-ClipboardImage.ps1 -Path D:\Pictures
#>
param(
    [string]$Path = (Get-Location).Path,
    [switch]$Gui
)

# The clipboard API needs a single-threaded apartment. Windows PowerShell 5.1 is STA by default;
# PowerShell 7 usually is too, but not when started with -MTA or from some hosts. Relaunch if needed.
if ([Threading.Thread]::CurrentThread.GetApartmentState() -ne 'STA') {
    $exe = (Get-Process -Id $PID).Path
    & $exe -NoProfile -STA -File $PSCommandPath -Path $Path -Gui:$Gui
    exit $LASTEXITCODE
}

Add-Type -AssemblyName System.Windows.Forms, System.Drawing

function Stop-WithError([string]$Message) {
    if ($Gui) { [void][Windows.Forms.MessageBox]::Show($Message, 'Paste image file', 'OK', 'Warning') }
    Write-Error $Message
    exit 1
}

# Explorer passes folder paths with a trailing "." (see Install-PasteImageMenu.ps1) so that a drive
# root like D:\ does not end in a backslash that escapes the closing quote. Strip it here.
if ($Path.EndsWith('\.')) { $Path = $Path.Substring(0, $Path.Length - 1) }
if ($Path.EndsWith('.') -and (Test-Path -LiteralPath $Path.TrimEnd('.') -PathType Container)) { $Path = $Path.TrimEnd('.') }

if (Test-Path -LiteralPath $Path -PathType Container) {
    $Path = Join-Path $Path ('clipboard_{0:yyyyMMdd_HHmmss}.png' -f (Get-Date))
}
$Path = [IO.Path]::GetFullPath($Path)

# Never overwrite: two pastes in the same second, or a name that already exists, get a suffix.
$dir  = [IO.Path]::GetDirectoryName($Path)
$stem = [IO.Path]::GetFileNameWithoutExtension($Path)
$ext  = [IO.Path]::GetExtension($Path).ToLower()
if (-not $ext) { $ext = '.png'; $Path += $ext }
$n = 1
while (Test-Path -LiteralPath $Path) { $Path = Join-Path $dir "$stem-$n$ext"; $n++ }

$fmt = switch ($ext) {
    { $_ -in '.jpg', '.jpeg' } { [Drawing.Imaging.ImageFormat]::Jpeg }
    '.bmp'                     { [Drawing.Imaging.ImageFormat]::Bmp }
    '.gif'                     { [Drawing.Imaging.ImageFormat]::Gif }
    { $_ -in '.tif', '.tiff' } { [Drawing.Imaging.ImageFormat]::Tiff }
    '.png'                     { [Drawing.Imaging.ImageFormat]::Png }
    default                    { Stop-WithError "Unsupported extension '$ext'. Use .png, .jpg, .bmp, .gif or .tif." }
}

$data = [Windows.Forms.Clipboard]::GetDataObject()
$img  = $null

try {
    if ($data -and $data.GetDataPresent('PNG')) {
        $stream = $data.GetData('PNG')
        if ($ext -eq '.png' -and $stream -is [IO.Stream]) {
            $fs = [IO.File]::Create($Path)
            try { $stream.CopyTo($fs) } finally { $fs.Close() }
            Write-Output "Saved $Path"
            exit 0
        }
        $img = [Drawing.Image]::FromStream($stream)
    }
    elseif ([Windows.Forms.Clipboard]::ContainsImage()) {
        $img = [Windows.Forms.Clipboard]::GetImage()
    }
    elseif ($data -and $data.GetDataPresent('HTML Format')) {
        $html = [string]$data.GetData('HTML Format')
        if ($html -match '<img[^>]+src="([^"]+)"') {
            $src = [Net.WebUtility]::HtmlDecode($Matches[1])
            if ($src -match '^data:image/[^;]+;base64,(.+)$') {
                $bytes = [Convert]::FromBase64String($Matches[1])
            } elseif ($src -match '^https?://') {
                $bytes = (Invoke-WebRequest -Uri $src -UseBasicParsing).Content
            } else {
                Stop-WithError "The copied HTML points at '$src', which is not a web or data: URL."
            }
            $img = [Drawing.Image]::FromStream([IO.MemoryStream]::new([byte[]]$bytes))
        }
    }
} catch {
    Stop-WithError "Could not read the image: $($_.Exception.Message)"
}

if (-not $img) { Stop-WithError 'No image found on the clipboard. Copy an image first (right-click it > Copy image).' }

try {
    # JPEG has no alpha: flatten onto white so transparent areas do not turn black.
    if ($fmt -eq [Drawing.Imaging.ImageFormat]::Jpeg) {
        $flat = New-Object Drawing.Bitmap $img.Width, $img.Height
        $g = [Drawing.Graphics]::FromImage($flat)
        $g.Clear([Drawing.Color]::White); $g.DrawImage($img, 0, 0, $img.Width, $img.Height); $g.Dispose()
        $img.Dispose(); $img = $flat
    }
    $img.Save($Path, $fmt)
} catch {
    Stop-WithError "Could not save '$Path': $($_.Exception.Message)"
} finally {
    $img.Dispose()
}
Write-Output "Saved $Path"
