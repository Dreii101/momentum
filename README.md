# Momentum

An offline productivity workspace for Android and Windows. Capture what matters, choose a manageable next action, and start with two minutes.

**Preview: 1.0.0, build 2.** Momentum is not yet published on Microsoft Store or Google Play. Installed release, notification delivery, same-key update and reinstall-recovery checks are still pending. See [verification status](docs/VERIFICATION.md).

## Features

- Quick task capture, ordered subtasks, deadlines, next actions and up to three daily priorities.
- Plain-text notes with autosave, search and shared task/class links.
- Courses, recurring classes, occurrence changes, unified calendar and manual work blocks.
- Persistent two-minute starter, focus, breaks and explicit reported-work review.
- Weekly progress and reflection without scores, punitive streaks or attention tracking.
- Optional local reminders and validated JSON backup/replacement restore.
- Adaptive phone/desktop layouts, light/dark themes and local preferences.

No app account, cloud synchronization, advertising or analytics service is built in. User records live in native SQLite on the device. Backups are unencrypted; keep them private.

## Installation

Download from [GitHub Releases](https://github.com/Dreii101/momentum/releases/tag/v1.0.0-preview.2). Compare the downloaded files with the attached **SHA256SUMS.txt** and public **RELEASE_MANIFEST.json**. Only build 2 is a user download; older update fixtures remain outside this repository.

### Android

Requires Android 7.0/API 24 or later.

1. Download **Momentum-1.0.0-2-android.apk** to the phone.
2. Open the APK and, if you choose, approve installation from that particular file source.
3. Launch **Momentum** from its icon. Open Settings → About Momentum to check the version.
4. Enable reminders only when you want them; notification permission and exact-alarm access are separate.

Keep an existing development preview and its data. A preview signed with a debug key cannot receive this differently signed release directly. Export and validate a backup outside app storage before arranging a transition; do not clear storage or uninstall to work around a signing error. Future Play signing also needs an explicit same-key plan. The AAB is a Store-upload format, not a file to tap-install.

### Windows

Requires Windows 10 build 19041 or later, **x64**.

1. Download **Momentum-1.0.0-2-windows-x64.msix** and **windows-public.cer**.
2. Verify their hashes and the certificate fingerprint in the release manifest. This direct-download preview is self-signed; Windows does not automatically trust it.
3. Only if you decide to trust this signer, import the **public CER** into **Local Computer → Trusted People**, with the administrator-approved certificate wizard. Do not use Trusted Root or import private keys. Packaging does not perform this trust step.
4. Open the MSIX in App Installer, install it, and launch the **Momentum** Start entry.

Certificate subject: **CN=MomentumPrivate**. Thumbprint: **3A2716583F79280E9256850E3CF334D5FEB33771**. Verify the SHA-256 fingerprint against the attached public manifest before trusting it. Microsoft Store distribution will use Store signing instead; no Store listing exists yet.

The MSIX includes the Flutter/C++ runtime, plugins and assets. Do not copy just momentum.exe. Existing development package identities are separate; use deliberate backup transfer to move records. See [installation, updates and recovery](docs/RELEASE.md).

### Updates and recovery

Save notes/reflections and resolve unfinished sessions, then export through **Settings → Data** to a location outside app storage. Keep another copy off the device. Validate the copied backup before replacing any workspace. Restore is deliberate replacement, not merging/synchronization. Local recovery snapshots are not protection from uninstall or device loss.

## Build from source

Built with Flutter **3.47.7**, Dart **3.13.5**, pinned pubspec.lock, Riverpod and Drift/native SQLite. Android builds need the configured Android SDK/NDK and Java 17-compatible toolchain; Windows builds need Visual Studio C++ desktop tooling and Windows SDK. Dependencies/build tools may need network access even though the app operates locally.

With Flutter installed:

```powershell
flutter pub get --enforce-lockfile
dart format --output=none --set-exit-if-changed lib test integration_test
flutter analyze --no-pub
flutter test --no-pub --concurrency=1
flutter run -d windows
```

Use the actual Android device ID for `flutter run -d DEVICE_ID`. On an 8 GB development machine, run builds/tests sequentially and prefer a physical phone over an emulator.

House wrappers in tool/ accept MOMENTUM_TOOLCHAIN_HOME pointing to a directory containing flutter/, optionally android-sdk/, pub-cache/ and gradle-cache/. No developer-specific paths/configuration are included. Flutter recreates ignored generated platform/build files as needed. Schema export uses tool/export_schema.ps1 and preserves frozen snapshots.

Debug builds expose development checks; normal release builds hide them. Product data and diagnostic fixtures use separate databases. Integration test entry points are opt-in; normal builds start lib/main.dart.

For privately signed packages, see [release build instructions](docs/RELEASE.md). Original signing keys are intentionally absent; compiling this source does not give you the maintainer's signing identity.

## Store publishing

See [Microsoft Store and Google Play preparation](docs/STORE_PUBLISHING.md). Developer accounts, final Store identities/listings, privacy/contact details, genuine screenshots and installed quality checks are still required. New personal Google Play accounts have additional closed-testing requirements. No production submission has occurred.

## Source and support

This public repository starts from a reviewed source snapshot. Private development history, raw device logs/screenshots, local paths/configuration, app databases/backups, environment files and signing secrets are excluded. The JSON under test/fixtures is synthetic regression data, not a user backup.

Report reproducible bugs through [GitHub Issues](https://github.com/Dreii101/momentum/issues). Do not attach personal notes, backups, credentials or signing files. No project license has been selected yet; public visibility does not imply an MIT or other open-source license.
