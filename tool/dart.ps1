$dartArguments = $args
$ErrorActionPreference = 'Stop'
$projectPath = Split-Path $PSScriptRoot -Parent
$config = Join-Path $PSScriptRoot 'local-toolchain.json'
$toolchainPath = $env:MOMENTUM_TOOLCHAIN_HOME
if (-not $toolchainPath -and (Test-Path -LiteralPath $config)) {
    $toolchainPath = (Get-Content -LiteralPath $config -Raw | ConvertFrom-Json).ToolchainRoot
}
if (-not $toolchainPath) { $toolchainPath = Join-Path $projectPath '.tooling' }
$dartPath = Join-Path $toolchainPath 'flutter\bin\cache\dart-sdk\bin\dart.exe'
if (-not (Test-Path -LiteralPath $dartPath)) { throw 'Dart SDK missing; see README.md.' }
$savedCache = $env:PUB_CACHE
$savedAnalytics = $env:DART_SUPPRESS_ANALYTICS
Push-Location $projectPath
try {
    $env:PUB_CACHE = Join-Path $toolchainPath 'pub-cache'
    $env:DART_SUPPRESS_ANALYTICS = 'true'
    & $dartPath @dartArguments
    $dartExitCode = $LASTEXITCODE
} finally {
    Pop-Location
    $env:PUB_CACHE = $savedCache
    $env:DART_SUPPRESS_ANALYTICS = $savedAnalytics
}
exit $dartExitCode
