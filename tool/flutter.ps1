# Raw argument forwarding keeps Flutter's -d/-v from becoming PowerShell flags.
$flutterArguments = $args
$ErrorActionPreference = 'Stop'
$projectPath = Split-Path $PSScriptRoot -Parent
$configurationPath = Join-Path $PSScriptRoot 'local-toolchain.json'
$toolchainPath = $env:MOMENTUM_TOOLCHAIN_HOME
if (-not $toolchainPath -and (Test-Path -LiteralPath $configurationPath)) {
    $toolchainPath = (Get-Content -LiteralPath $configurationPath -Raw | ConvertFrom-Json).ToolchainRoot
}
if (-not $toolchainPath) { $toolchainPath = Join-Path $projectPath '.tooling' }
$flutterPath = Join-Path $toolchainPath 'flutter\bin\flutter.bat'
if (-not (Test-Path -LiteralPath $flutterPath)) {
    throw 'Flutter SDK missing. Set MOMENTUM_TOOLCHAIN_HOME or tool/local-toolchain.json. See README.md.'
}
$variableNames = @('PATH', 'PUB_CACHE', 'FLUTTER_SUPPRESS_ANALYTICS', 'DART_SUPPRESS_ANALYTICS', 'ANDROID_HOME', 'ANDROID_SDK_ROOT', 'GRADLE_USER_HOME')
$savedEnvironment = @{}
foreach ($variableName in $variableNames) { $savedEnvironment[$variableName] = [Environment]::GetEnvironmentVariable($variableName, 'Process') }
Push-Location $projectPath
try {
    $env:PATH = (Join-Path $toolchainPath 'flutter\bin') + ';' + $env:PATH
    $env:PUB_CACHE = Join-Path $toolchainPath 'pub-cache'
    $env:GRADLE_USER_HOME = Join-Path $toolchainPath 'gradle-cache'
    $env:FLUTTER_SUPPRESS_ANALYTICS = 'true'
    $env:DART_SUPPRESS_ANALYTICS = 'true'
    $androidSdkPath = Join-Path $toolchainPath 'android-sdk'
    if (-not $env:ANDROID_HOME -and -not $env:ANDROID_SDK_ROOT -and (Test-Path -LiteralPath $androidSdkPath)) {
        $env:ANDROID_HOME = $androidSdkPath
        $env:ANDROID_SDK_ROOT = $androidSdkPath
    }
    & $flutterPath @flutterArguments
    $flutterExitCode = $LASTEXITCODE
} finally {
    Pop-Location
    foreach ($variableName in $variableNames) { [Environment]::SetEnvironmentVariable($variableName, $savedEnvironment[$variableName], 'Process') }
}
exit $flutterExitCode
