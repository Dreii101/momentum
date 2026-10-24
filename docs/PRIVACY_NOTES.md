# Privacy disclosure preparation

These are engineering notes for a future reviewed privacy policy, **not a completed Store policy**. The owner must choose public developer/privacy contact details and publish the final policy before Store submission. Google Play also requires policy text/link inside the app; the current short About statement is insufficient.

- Tasks, notes, classes, timers, reflection, settings and local installation metadata are stored on the device in SQLite. No app account, advertising SDK, analytics SDK, remote AI or app cloud-sync service is built in.
- Optional reminders use the operating system's local notification services. Notification content can appear on the device/lock screen according to OS settings. Delivery is not attention tracking.
- Export creates unencrypted JSON at the location the user selects. Import reads a selected file and replaces local domain records only after explicit confirmation. Files saved to a third-party cloud-backed picker location may be handled by that provider under its own policies; app-local operation is not a guarantee about the chosen provider.
- Three local recovery snapshots contain local database data and do not protect against device loss. Exported backups and copied files remain wherever the user puts them, including after uninstall.
- Android automatic cloud/device-transfer backup exclusions are configured; actual OEM and operating-system behavior is not universally certified. Windows/system backup choices remain external to the app.
- GitHub hosts this repository, downloads and public issues under GitHub's own policies. Do not post private app content or credentials to public issues.

Review final shipped dependencies, permissions, data retention/deletion behavior, public contacts and Store Data safety answers before adopting a policy. No claim of application-level encryption or automatic cross-device synchronization is made.
