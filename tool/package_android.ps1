param([int]$BuildNumber = 2, [string]$Version = '1.0.0', [switch]$Bundle)
$ErrorActionPreference = 'Stop'
if ($BuildNumber -lt 1 -or $Version -notmatch '^\d+\.\d+\.\d+$') { throw 'Invalid release version.' }
$project = Split-Path $PSScriptRoot -Parent
$privateDirectory = Join-Path $env:LOCALAPPDATA 'MomentumSigning'
$key = Join-Path $privateDirectory 'android-release.p12'
if (-not (Test-Path -LiteralPath $key)) { throw 'Private signing key missing. Read docs/RELEASE.md before the one-time setup_signing.ps1 command.' }
$toolchain = $env:MOMENTUM_TOOLCHAIN_HOME
if (-not $toolchain) { $toolchain = (Get-Content (Join-Path $PSScriptRoot 'local-toolchain.json') -Raw | ConvertFrom-Json).ToolchainRoot }
$buildTools = Join-Path $toolchain 'android-sdk/build-tools/36.0.0'
$outputDirectory = Join-Path $project "artifacts/$Version"
[IO.Directory]::CreateDirectory($outputDirectory) | Out-Null
$extension = if ($Bundle) { 'aab' } else { 'apk' }
$output = Join-Path $outputDirectory "Momentum-$Version-$BuildNumber-android.$extension"
if (Test-Path -LiteralPath $output) { throw 'Artifact exists. Use a new build number; do not silently overwrite a release.' }
Push-Location $project
try {
    $target = if ($Bundle) { 'appbundle' } else { 'apk' }
    & (Join-Path $PSScriptRoot 'flutter.ps1') build $target --release --no-pub --build-name=$Version --build-number=$BuildNumber --dart-define=MOMENTUM_VERSION=$Version --dart-define=MOMENTUM_BUILD=$BuildNumber
    if ($LASTEXITCODE -ne 0) { throw 'Android compilation failed.' }
    $unsigned = Join-Path $project $(if ($Bundle) { 'build/app/outputs/bundle/release/app-release.aab' } else { 'build/app/outputs/flutter-apk/app-release.apk' })
    $oldPassword = $env:MOMENTUM_KEY_PASSWORD
    try {
        $secure = (Get-Content (Join-Path $privateDirectory 'android-password.dpapi') -Raw).Trim() | ConvertTo-SecureString
        $env:MOMENTUM_KEY_PASSWORD = [Net.NetworkCredential]::new('', $secure).Password
        if ($Bundle) {
            & jarsigner -keystore $key -storetype PKCS12 -storepass:env MOMENTUM_KEY_PASSWORD -keypass:env MOMENTUM_KEY_PASSWORD -sigalg SHA256withRSA -digestalg SHA-256 -signedjar $output $unsigned momentum
        } else {
            & (Join-Path $buildTools 'apksigner.bat') sign --ks $key --ks-key-alias momentum --ks-pass env:MOMENTUM_KEY_PASSWORD --key-pass env:MOMENTUM_KEY_PASSWORD --out $output $unsigned
        }
        if ($LASTEXITCODE -ne 0) { throw 'Android signing failed.' }
    } finally { $env:MOMENTUM_KEY_PASSWORD = $oldPassword }
    if ($Bundle) { & jarsigner -verify $output }
    else { & (Join-Path $buildTools 'apksigner.bat') verify --verbose --print-certs $output }
    if ($LASTEXITCODE -ne 0) { throw 'Android signature verification failed.' }
    Copy-Item -LiteralPath (Join-Path $privateDirectory 'android-public.cer') -Destination $outputDirectory
    Get-FileHash -LiteralPath $output -Algorithm SHA256
} finally { Pop-Location }
