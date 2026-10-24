# Preview installation, update and recovery

Version 1.0.0, build 2. Prepared 24 October 2026. This is a preview; neither platform is claimed installed-release verified. No Microsoft Store or Google Play release exists yet.

## Downloads

[GitHub preview release](https://github.com/Dreii101/momentum/releases/tag/v1.0.0-preview.2): Android APK, Windows x64 MSIX, public Windows certificate, public manifest and SHA-256 checksums. No private keys/passwords or user data accompany downloads. App information appears in Settings. See the README for step-by-step Android/Windows installation.

Android identity: dev.momentum.app, min API 24, target API 36. Windows private preview identity: dev.momentum.private / CN=MomentumPrivate, x64, min build 19041. The Store build will require its actual Partner Center identity. New installations start empty; reminders default off.

## Windows trust

The direct-download MSIX is signed with the preview certificate, whose subject is CN=MomentumPrivate. Verify its SHA-256 fingerprint against the public release manifest before any trust decision. If you choose to install it, import only windows-public.cer into Local Computer → Trusted People using the administrator-approved wizard. Never use Trusted Root or import PFX/private keys. Trust applies to packages signed with that certificate. The packaging scripts never install certificates or packages.

Microsoft Store signs accepted MSIX packages itself. A Store install will not require users to import this preview certificate. See [Microsoft's guidance](https://learn.microsoft.com/en-us/windows/msix/package/create-certificate-package-signing).

## Updates

Preserve identity and signing key and increase build numbers. APKs signed with a different key cannot directly update one another. Do not uninstall/clear a development preview to bypass that error: export, copy and validate its backup first, then arrange a deliberate transition. Windows development/private/Store package identities can have separate storage; transfer a validated backup explicitly rather than assuming shared data.

Older same-key fixture builds were prepared privately for installer update tests but have not yet established a preserving installed upgrade. They are not public user downloads. The current preview does not claim upgrade acceptance.

## Backup and recovery

Save note/reflection drafts and review unfinished work. Export an unencrypted JSON backup through Settings → Data to Documents/Downloads/removable media outside app-private storage, then keep an off-device copy. Re-open that copy through Import to validate without choosing Replace. A successful export message appears after the native file operation succeeds.

Review counts/date before replacement. Replacement is one transaction after a local recovery snapshot; failures roll back. Imported unfinished sessions become interrupted/reviewable, never automatically running or credited. Receiving installation identity and local reminder opt-in are retained. Reminder rebuild problems are surfaced separately after commit. Three local snapshots protect replacement/migration attempts, not device loss or every uninstall. See BACKUP_FORMAT.md.

For post-reinstall recovery, use a disposable installation after proving the external copy is valid; compare relationships and confirmed totals after restore. This remains an installed-release acceptance check, not a completed claim. Never delete a database to fix corruption/migration errors.

## Maintainer builds

Use the exact pinned SDK/lockfile. House wrappers accept MOMENTUM_TOOLCHAIN_HOME; otherwise they look in .tooling. No local configuration is shipped. Run builds sequentially.

```powershell
tool/package_android.ps1
tool/package_android.ps1 -Bundle
tool/package_windows.ps1
tool/verify_release.ps1
```

These require the maintainer's signing material, which is not included. One-time setup_signing.ps1 creates a new private signer under LocalAppData/MomentumSigning and refuses an existing folder. A different contributor's new signer cannot update the maintainer's signed APK. Never recreate the maintainer's keys to work around a failed build.

Passwords use account-bound Windows DPAPI and keys use restricted local storage. Keep separately recoverable encrypted owner backups; copying protected password files to another machine alone is insufficient. Windows PFX reopening under the original account was checked; independent-profile key recovery is not claimed. No timestamp service was used; certificate expiry is in the manifest.

package_android.ps1 defaults to APK; -Bundle creates the Google Play AAB candidate. It remains local and is not installable directly. package_windows.ps1 creates the private preview MSIX; it does not prepare a guessed Partner Center identity. Existing artifacts are refused rather than overwritten. See STORE_PUBLISHING.md before Store packaging.
