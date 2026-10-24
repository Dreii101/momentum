# Explicit one-time key creation. This never adds a certificate to a trust store.
$ErrorActionPreference = 'Stop'
$privateDirectory = Join-Path $env:LOCALAPPDATA 'MomentumSigning'
if (Test-Path -LiteralPath $privateDirectory) {
    throw "Signing directory already exists: $privateDirectory. Reuse it; never overwrite or rotate keys automatically."
}
[IO.Directory]::CreateDirectory($privateDirectory) | Out-Null
$sid = [Security.Principal.WindowsIdentity]::GetCurrent().User
$acl = [Security.AccessControl.DirectorySecurity]::new()
$acl.SetOwner($sid)
$acl.SetAccessRuleProtection($true, $false)
$acl.AddAccessRule([Security.AccessControl.FileSystemAccessRule]::new(
    $sid, 'FullControl', 'ContainerInherit,ObjectInherit', 'None', 'Allow'))
Set-Acl -LiteralPath $privateDirectory -AclObject $acl
function New-PrivatePassword([string]$Name) {
    $bytes = [byte[]]::new(48)
    [Security.Cryptography.RandomNumberGenerator]::Fill($bytes)
    $secret = [Convert]::ToBase64String($bytes) | ConvertTo-SecureString -AsPlainText -Force
    $secret | ConvertFrom-SecureString | Set-Content -LiteralPath (Join-Path $privateDirectory $Name)
    return $secret
}
$androidPassword = New-PrivatePassword 'android-password.dpapi'
$windowsPassword = New-PrivatePassword 'windows-password.dpapi'
$oldPassword = $env:MOMENTUM_KEY_PASSWORD
try {
    $env:MOMENTUM_KEY_PASSWORD = [Net.NetworkCredential]::new('', $androidPassword).Password
    & keytool -genkeypair -keystore (Join-Path $privateDirectory 'android-release.p12') -storetype PKCS12 -alias momentum -keyalg RSA -keysize 3072 -sigalg SHA256withRSA -validity 10000 -dname 'CN=Momentum Private' -storepass:env MOMENTUM_KEY_PASSWORD -keypass:env MOMENTUM_KEY_PASSWORD -noprompt
    if ($LASTEXITCODE -ne 0) { throw 'Android key creation failed. Preserve the partial directory for inspection; do not rerun with new keys.' }
    & keytool -exportcert -keystore (Join-Path $privateDirectory 'android-release.p12') -alias momentum -storepass:env MOMENTUM_KEY_PASSWORD -file (Join-Path $privateDirectory 'android-public.cer')
    if ($LASTEXITCODE -ne 0) { throw 'Android public certificate export failed.' }
} finally { $env:MOMENTUM_KEY_PASSWORD = $oldPassword }
$certificate = New-SelfSignedCertificate -Type Custom -Subject 'CN=MomentumPrivate' -FriendlyName 'Momentum Private MSIX signing (not trusted)' -KeyAlgorithm RSA -KeyLength 3072 -HashAlgorithm SHA256 -KeyExportPolicy Exportable -KeyUsage DigitalSignature -CertStoreLocation Cert:\CurrentUser\My -NotAfter (Get-Date).AddYears(10) -TextExtension @('2.5.29.37={text}1.3.6.1.5.5.7.3.3', '2.5.29.19={text}CA=false')
Export-PfxCertificate -Cert $certificate -FilePath (Join-Path $privateDirectory 'windows-release.pfx') -Password $windowsPassword | Out-Null
Export-Certificate -Cert $certificate -FilePath (Join-Path $privateDirectory 'windows-public.cer') | Out-Null
[ordered]@{
    androidAlias = 'momentum'
    windowsSubject = $certificate.Subject
    windowsThumbprint = $certificate.Thumbprint
    windowsExpires = $certificate.NotAfter.ToUniversalTime().ToString('o')
    windowsIdentity = 'dev.momentum.private'
    androidIdentity = 'dev.momentum.app'
} | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $privateDirectory 'identity.json')
Write-Output "Private signing material created in $privateDirectory. Passwords are user-bound DPAPI files; no certificate trust was added."
