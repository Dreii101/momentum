$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$project = Split-Path $PSScriptRoot -Parent
function New-IconPng([int]$Size, [string]$Path) {
    $bitmap = [Drawing.Bitmap]::new($Size, $Size)
    $graphics = [Drawing.Graphics]::FromImage($bitmap)
    $teal = [Drawing.ColorTranslator]::FromHtml('#167D8D')
    $pen = [Drawing.Pen]::new([Drawing.Color]::White, $Size * 0.08)
    try {
        $graphics.SmoothingMode = [Drawing.Drawing2D.SmoothingMode]::AntiAlias
        $graphics.Clear($teal)
        $pen.StartCap = $pen.EndCap = [Drawing.Drawing2D.LineCap]::Round
        $pen.LineJoin = [Drawing.Drawing2D.LineJoin]::Round
        # A rising M stays legible inside Android's adaptive-icon safe area.
        $points = [Drawing.PointF[]]@(
            [Drawing.PointF]::new($Size * 0.28, $Size * 0.65),
            [Drawing.PointF]::new($Size * 0.28, $Size * 0.40),
            [Drawing.PointF]::new($Size * 0.49, $Size * 0.57),
            [Drawing.PointF]::new($Size * 0.72, $Size * 0.33),
            [Drawing.PointF]::new($Size * 0.72, $Size * 0.65)
        )
        $graphics.DrawLines($pen, $points)
        [IO.Directory]::CreateDirectory((Split-Path $Path)) | Out-Null
        $bitmap.Save($Path, [Drawing.Imaging.ImageFormat]::Png)
    } finally { $pen.Dispose(); $graphics.Dispose(); $bitmap.Dispose() }
    $check = [Drawing.Image]::FromFile($Path)
    try { if ($check.Width -ne $Size -or $check.Height -ne $Size) { throw 'Invalid icon size.' } }
    finally { $check.Dispose() }
}
New-IconPng 512 (Join-Path $project 'assets/identity/momentum.png')
$densities = @{ mdpi = 48; hdpi = 72; xhdpi = 96; xxhdpi = 144; xxxhdpi = 192 }
foreach ($density in $densities.Keys) {
    New-IconPng $densities[$density] (Join-Path $project "android/app/src/main/res/mipmap-$density/ic_launcher.png")
}
New-IconPng 432 (Join-Path $project 'android/app/src/main/res/drawable/momentum_launcher.png')
# PNG-backed ICO, one 256px entry for the Windows runner.
$temporaryIcon = Join-Path $project 'build/identity/app-icon-256.png'
New-IconPng 256 $temporaryIcon
$imageBytes = [IO.File]::ReadAllBytes($temporaryIcon)
$writer = [IO.BinaryWriter]::new([IO.File]::Create((Join-Path $project 'windows/runner/resources/app_icon.ico')))
try {
    $writer.Write([uint16]0); $writer.Write([uint16]1); $writer.Write([uint16]1)
    $writer.Write([byte]0); $writer.Write([byte]0); $writer.Write([byte]0); $writer.Write([byte]0)
    $writer.Write([uint16]1); $writer.Write([uint16]32)
    $writer.Write([uint32]$imageBytes.Length); $writer.Write([uint32]22); $writer.Write($imageBytes)
} finally { $writer.Dispose() }
Write-Output 'Momentum PNG and Windows/Android launcher icons generated and size-checked.'
