# Build/sign only. Never import certificates into trust stores or install packages.
param([int]$BuildNumber = 2, [string]$Version = '1.0.0')
$ErrorActionPreference = 'Stop'
if ($BuildNumber -lt 1 -or $Version -notmatch '^\d+\.\d+\.\d+$') { throw 'Invalid release version.' }
$project = Split-Path $PSScriptRoot -Parent
$privateDirectory = Join-Path $env:LOCALAPPDATA 'MomentumSigning'
$identity = Get-Content (Join-Path $privateDirectory 'identity.json') -Raw | ConvertFrom-Json
$certificate = Get-Item "Cert:\CurrentUser\My\$($identity.windowsThumbprint)"
if (-not $certificate.HasPrivateKey -or $certificate.Subject -ne 'CN=MomentumPrivate' -or $certificate.NotAfter -le (Get-Date)) {
    throw 'Original private Windows signing certificate missing, incompatible or expired. Do not generate a replacement casually.'
}
$signTool = Join-Path ${env:ProgramFiles(x86)} 'Windows Kits/10/bin/10.0.26100.0/x64/signtool.exe'
$outputDirectory = Join-Path $project "artifacts/$Version"
[IO.Directory]::CreateDirectory($outputDirectory) | Out-Null
$name = "Momentum-$Version-$BuildNumber-windows-x64"
$output = Join-Path $outputDirectory "$name.msix"
if (Test-Path -LiteralPath $output) { throw 'Artifact exists. Use a new build number; do not silently overwrite a release.' }
Push-Location $project
try {
    & (Join-Path $PSScriptRoot 'flutter.ps1') build windows --release --no-pub --build-name=$Version --build-number=$BuildNumber --dart-define=MOMENTUM_VERSION=$Version --dart-define=MOMENTUM_BUILD=$BuildNumber
    if ($LASTEXITCODE -ne 0) { throw 'Windows compilation failed.' }
    & (Join-Path $PSScriptRoot 'dart.ps1') run msix:create --build-windows false --install-certificate false --sign-msix false --version "$Version.$BuildNumber" --output-path $outputDirectory --output-name $name
    if ($LASTEXITCODE -ne 0) { throw 'MSIX creation failed.' }
    & $signTool sign /fd SHA256 /sha1 $certificate.Thumbprint /s My $output
    if ($LASTEXITCODE -ne 0) { throw 'MSIX signing failed.' }
    Copy-Item -LiteralPath (Join-Path $privateDirectory 'windows-public.cer') -Destination $outputDirectory
    # Signature authenticity/integrity is checked separately from machine trust.
    Get-AuthenticodeSignature -LiteralPath $output | Select-Object Status,StatusMessage,@{n='SignerThumbprint';e={$_.SignerCertificate.Thumbprint}}
    Get-FileHash -LiteralPath $output -Algorithm SHA256
} finally { Pop-Location }
