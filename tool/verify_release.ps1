param([int]$BuildNumber = 2, [string]$Version = '1.0.0')
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression.FileSystem
Add-Type -AssemblyName System.Security.Cryptography.Pkcs
$project = Split-Path $PSScriptRoot -Parent
$directory = Join-Path $project "artifacts/$Version"
$msix = Join-Path $directory "Momentum-$Version-$BuildNumber-windows-x64.msix"
$apk = Join-Path $directory "Momentum-$Version-$BuildNumber-android.apk"
$toolchain = $env:MOMENTUM_TOOLCHAIN_HOME
if (-not $toolchain) { $toolchain = (Get-Content (Join-Path $PSScriptRoot 'local-toolchain.json') -Raw | ConvertFrom-Json).ToolchainRoot }
$buildTools = Join-Path $toolchain 'android-sdk/build-tools/36.0.0'
$apkSignature = & (Join-Path $buildTools 'apksigner.bat') verify --verbose --print-certs $apk
if ($LASTEXITCODE -ne 0) { throw 'APK signature verification failed.' }
$apkSignature | Write-Output
$androidCertificate = [Security.Cryptography.X509Certificates.X509Certificate2]::new((Join-Path $directory 'android-public.cer'))
$androidFingerprint = $androidCertificate.GetCertHashString([Security.Cryptography.HashAlgorithmName]::SHA256)
if (($apkSignature -join "`n") -notmatch "(?i)certificate SHA-256 digest: $androidFingerprint") { throw 'Unexpected Android signer.' }
$badging = & (Join-Path $buildTools 'aapt2.exe') dump badging $apk
if ($LASTEXITCODE -ne 0) { throw 'APK manifest inspection failed.' }
$badgingText = $badging -join "`n"
if ($badgingText -notmatch "package: name='dev.momentum.app' versionCode='$BuildNumber' versionName='$Version'" -or
    $badgingText -notmatch "application-label:'Momentum'" -or
    $badgingText -match 'android.permission.INTERNET|application-debuggable') { throw 'Unexpected APK identity/permissions/debug flag.' }
$zip = [IO.Compression.ZipFile]::OpenRead($msix)
function Read-ZipBytes([IO.Compression.ZipArchiveEntry]$Entry) {
    if ($null -eq $Entry) { throw 'Required MSIX entry missing.' }
    $stream = $Entry.Open()
    $memory = [IO.MemoryStream]::new()
    try { $stream.CopyTo($memory); return ,$memory.ToArray() }
    finally { $stream.Dispose(); $memory.Dispose() }
}
try {
    [xml]$manifest = [Text.Encoding]::UTF8.GetString((Read-ZipBytes $zip.GetEntry('AppxManifest.xml')))
    $identity = $manifest.Package.Identity
    if ($identity.Name -ne 'dev.momentum.private' -or $identity.Publisher -ne 'CN=MomentumPrivate' -or
        $identity.Version -ne "$Version.$BuildNumber" -or $identity.ProcessorArchitecture -ne 'x64') { throw 'Unexpected MSIX identity.' }
    $activation = $manifest.SelectSingleNode("//*[local-name()='ToastNotificationActivation']")
    if ($manifest.Package.Properties.DisplayName -ne 'Momentum' -or
        $activation.ToastActivatorCLSID -ne 'd8a4762d-5267-4eda-9319-821b58901837') { throw 'Unexpected MSIX launch/reminder identity.' }
    $cmsBytes = Read-ZipBytes $zip.GetEntry('AppxSignature.p7x')
    if ([Text.Encoding]::ASCII.GetString($cmsBytes,0,4) -ne 'PKCX') { throw 'Invalid MSIX signature header.' }
    $cms = [Security.Cryptography.Pkcs.SignedCms]::new()
    $cms.Decode([byte[]]$cmsBytes[4..($cmsBytes.Length-1)])
    $cms.CheckSignature($true) # Cryptographic signature, deliberately separate from machine trust.
    $certificate = [Security.Cryptography.X509Certificates.X509Certificate2]::new((Join-Path $directory 'windows-public.cer'))
    if ($cms.SignerInfos.Count -ne 1 -or $cms.SignerInfos[0].Certificate.Thumbprint -ne $certificate.Thumbprint) { throw 'Unexpected Windows signer.' }
    # Bind the independently checked file map to the cryptographically signed APPX digest.
    $sha = [Security.Cryptography.SHA256]::Create()
    $mapBytes = Read-ZipBytes $zip.GetEntry('AppxBlockMap.xml')
    $signedHex = [Convert]::ToHexString($cms.ContentInfo.Content)
    $mapDigest = [Convert]::ToHexString($sha.ComputeHash($mapBytes))
    $typesDigest = [Convert]::ToHexString($sha.ComputeHash((Read-ZipBytes $zip.GetEntry('[Content_Types].xml'))))
    $catalogDigest = [Convert]::ToHexString($sha.ComputeHash((Read-ZipBytes $zip.GetEntry('AppxMetadata/CodeIntegrity.cat'))))
    if ($cms.ContentInfo.ContentType.Value -ne '1.3.6.1.4.1.311.2.1.4' -or
        -not $signedHex.Contains("4158424D$mapDigest") -or -not $signedHex.Contains("41584354$typesDigest") -or
        -not $signedHex.Contains("41584349$catalogDigest")) { throw 'MSIX signed block-map/content-type/catalog digest mismatch.' }
    $tamperedMap = [byte[]]$mapBytes.Clone()
    $tamperedMap[0] = $tamperedMap[0] -bxor 1
    if ($signedHex.Contains('4158424D' + [Convert]::ToHexString($sha.ComputeHash($tamperedMap)))) { throw 'Tampered-map rejection self-check failed.' }
    [xml]$blockMap = [Text.Encoding]::UTF8.GetString($mapBytes)
    $checkedFiles = 0
    foreach ($file in $blockMap.BlockMap.File) {
        $entry = $zip.GetEntry($file.Name.Replace('\','/'))
        $bytes = Read-ZipBytes $entry
        if ($bytes.Length -ne [long]$file.Size) { throw "MSIX size mismatch: $($file.Name)" }
        $offset = 0
        foreach ($block in $file.Block) {
            $length = [Math]::Min(65536, $bytes.Length - $offset)
            if ($length -le 0) { throw 'Unexpected block-map length.' }
            $hash = $sha.ComputeHash($bytes, $offset, $length)
            if ([Convert]::ToBase64String($hash) -ne $block.Hash) { throw "MSIX block mismatch: $($file.Name)" }
            $offset += $length
        }
        if ($offset -ne $bytes.Length) { throw 'Incomplete block-map coverage.' }
        $checkedFiles++
    }
    $mappedNames = @($blockMap.BlockMap.File | ForEach-Object { $_.Name.Replace('\','/') })
    foreach ($entry in $zip.Entries) {
        if ($entry.FullName -notin @('AppxSignature.p7x','AppxBlockMap.xml','[Content_Types].xml','AppxMetadata/CodeIntegrity.cat') -and $entry.FullName -notin $mappedNames) { throw "Unmapped MSIX entry: $($entry.FullName)" }
    }
    $required = @('momentum.exe','flutter_windows.dll','sqlite3.dll','flutter_local_notifications_windows.dll','dartjni.dll','msvcp140.dll','vcruntime140.dll','vcruntime140_1.dll','data/app.so','data/icudtl.dat')
    foreach ($name in $required) { if ($null -eq $zip.GetEntry($name)) { throw "Missing runtime: $name" } }
    if (-not ($zip.Entries.FullName -match '^data/flutter_assets/')) { throw 'Missing Flutter assets.' }
    $signature = Get-AuthenticodeSignature -LiteralPath $msix
    if ($signature.Status -ne 'Valid' -and $signature.StatusMessage -ne 'A certificate chain processed, but terminated in a root certificate which is not trusted by the trust provider.') { throw "Unexpected Authenticode failure: $($signature.StatusMessage)" }
    [ordered]@{
        observedUtc = [DateTime]::UtcNow.ToString('o')
        build = $BuildNumber
        version = $Version
        target = 'lib/main.dart, release, no development define'
        msixIdentity = $identity.Name
        msixPublisher = $identity.Publisher
        signerThumbprint = $certificate.Thumbprint
        cmsSignatureValid = $true
        signedBlockMapDigestValid = $true
        tamperedBlockMapRejected = $true
        blockMapFilesChecked = $checkedFiles
        authenticodeStatus = $signature.Status.ToString()
        authenticodeMessage = $signature.StatusMessage
        installedReleaseVerified = $false
        runtimeEntries = @($zip.Entries.FullName | Where-Object { $_ -match '\.dll$|app.so$|icudtl.dat$|AppxManifest.xml$' })
    } | ConvertTo-Json -Depth 4 | Set-Content (Join-Path $project "docs/evidence/phase14-audit-$BuildNumber.json")
    Write-Output "Build ${BuildNumber}: APK signature/identity and MSIX cryptographic signature, $checkedFiles block-map files and required runtime verified. Machine trust and installed checks are separate."
} finally { if ($sha) { $sha.Dispose() }; $zip.Dispose() }
