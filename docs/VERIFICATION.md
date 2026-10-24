# Verification status

24 October 2026. **Preview preparation passed; installed-release acceptance remains pending.**

| Check | Result and scope |
|---|---|
| Host source checks | Offline locked dependencies restored and analysis clean on the exact reviewed public snapshot; all 202 regression tests passed again, including migrations/rollback/reopen, known-credit fixtures and complete MVP journeys with simulated platform adapters |
| Android preview APK | Normal main.dart, dev.momentum.app, version 1.0.0/build 2, no debuggable flag or INTERNET permission; v2/v3 signatures verified against the public release certificate |
| Windows preview MSIX | Normal release x64, private package identity, valid cryptographic signature and signed digest bindings; 114 file-map entries verified and all current built runtime/assets files matched the package |
| Runtime inclusion | Flutter engine, app.so, SQLite, notification/native libraries, C++ runtime, ICU data and assets are packaged together |
| Privacy/static packaging | No app analytics/network service added, pinned dependencies retained, no network/broad-filesystem MSIX capability; known isolated test-fixture markers absent from normal Windows AOT |
| Public source | A clean reviewed snapshot excludes private local history/evidence, machine/device identifiers, databases/backups, environment configuration and signing secrets |
| Physical/installed release | Pending on both newly signed platforms: first run/launcher/About, native dialogs, real reminders, lifecycle/reboot, signed updates and post-reinstall restore |
| Store release | Pending developer accounts, Store identities/listings, policy/contact/screenshots, applicable testing and certification |

Earlier native executable and physical-phone tests are not promoted to acceptance of these signed packages. Earlier first-install Android startup exceeded the three-second target (3.894 seconds); later existing-data process-cold reference runs met it. Maximum valid backup size/performance, full disk exhaustion, independent signing-key recovery and all real OS accessibility/power-policy combinations are not certified.

Raw private device logs/screenshots and local receipts are intentionally excluded. Public package checksums/fingerprints are attached to the preview release. Run `flutter analyze --no-pub`, `flutter test --no-pub --concurrency=1`, and relevant native checks without deleting data. Rebuild lib/main.dart after any explicit diagnostic entry.
