# Microsoft Store and Google Play publishing

Status checked 24 October 2026. GitHub publication is authorized. The owner does not yet have Microsoft Partner Center or Google Play Console developer accounts. There is no Store listing, approved submission or public Store download link yet. GitHub packages are previews; installed-release gates remain open. No Version 2 work is included.

## Microsoft Store

1. The owner creates/verifies a Windows developer account in [Partner Center](https://learn.microsoft.com/en-us/windows/apps/publish/get-started), reviews terms and any enrollment requirements, and reserves an available application name.
2. Obtain the exact Package/Identity/Name, Package/Identity/Publisher and PublisherDisplayName from [Product identity](https://learn.microsoft.com/en-us/windows/apps/publish/view-app-identity-details). These must replace the private preview identity in a separate Store build; do not invent account identity values or overwrite the private preview packages.
3. Rebuild a normal x64 MSIX with those values and a [Store-compatible version](https://learn.microsoft.com/en-us/windows/apps/publish/publish-your-app/package-version-numbering) whose fourth part is zero, such as 1.0.2.0. The current private 1.0.0.2 package is not the final Store submission package. Verify notification activation and data transfer under the Store identity. The Store signs MSIX packages after certification, so customers do not manually trust the preview certificate.
4. Complete the installed release journey, native dialogs/reminders, recovery and preserving update checks. Prepare genuine screenshots, listing text, public support/privacy contact, privacy-policy URL, age ratings, availability and the runFullTrust restricted-capability justification (native desktop SQLite/file dialogs/notifications, no elevation requirement).
5. Use [Create an app submission](https://learn.microsoft.com/en-us/windows/apps/publish/publish-your-app/msix/create-app-submission), upload the Store build, finish required fields and submit only after the actual listing/package is reviewed. No credentials or identity documents belong in this repository.

The prior choice to leave local Windows certificate trust pending is preserved. Publishing to Microsoft Store does not remove the need to test its installed package; a Store test channel can be used once the account/app identity exists.

## Google Play

1. The owner registers/verifies [Play Console](https://support.google.com/googleplay/android-developer/answer/6112435?hl=en), reviews its developer agreement and registration fee, and completes any identity/device verification. Do not send credentials, payment details or identity documents through GitHub issues.
2. Create the application and verify ownership/availability of the intended package name. Current Android ID: dev.momentum.app. Preserve the existing release signing material; do not rotate keys or change the public application ID casually.
3. New Google Play apps require an [Android App Bundle](https://developer.android.com/guide/app-bundle), not the installable GitHub APK. Build a signed candidate with `tool/package_android.ps1 -Bundle`. It stays in ignored artifacts storage. Its successful build/signature is preparation, not Play acceptance.

   Prepared candidate: 1.0.0/build 2, SHA-256 75509183750291cf0f09ee8ac04c76f3e5fb824d67bc16e6805894dcdbdc68f9. Signature matches the existing release key; eight bundled 64-bit native libraries meet static 16 KB load alignment and the preview APK passes 16 KB ZIP alignment. Play-generated APK and real 16 KB runtime checks remain pending. The bundle is retained locally, not exposed as an installable GitHub download.
4. Deliberately configure [Play App Signing](https://developer.android.com/studio/publish/app-signing). The upload key and delivered-app signing key serve different roles. If GitHub APKs and Play installs must update one another, plan to retain the current app signing key through the supported enrollment flow. A newly generated Play signing key would not update existing differently signed installations directly. Private keys/passwords/PEPK output must never be committed or attached to GitHub releases.
5. Check the current target SDK/native-library requirements, static 16 KB alignment and a real 16 KB runtime/device test, Play-generated APK behavior, notification permissions/background delivery, preserving updates and external-backup recovery. A local 4 KB device result is not a 16 KB runtime result.
6. Finalize a publicly accessible privacy policy and include the policy text/link inside the app. [Google requires a policy even for apps without data collection](https://support.google.com/googleplay/android-developer/answer/10144311?hl=en). The current About backup statement is not a complete policy. Complete Data safety, ads/app access declarations, target audience/content rating, support contact and genuine screenshots. Do not infer store declarations from a draft without reviewing shipped dependencies/permissions.
7. Start internal testing, then any required closed testing. New personal accounts currently require [at least 12 testers continuously opted in for 14 days](https://support.google.com/googleplay/android-developer/answer/14151465?hl=en), followed by a production-access application. This cannot be completed in one development session or replaced by automated tests.
8. Submit a reviewed production release only once account/testing/policy and installed-quality gates pass. No production submission has occurred.

## Prepared listing text

Name: Momentum (subject to Store name availability).

Short description: Capture tasks, take notes, plan your week and start with two minutes.

Description: Momentum is an offline productivity workspace for Android and Windows. Capture a task with just a title, choose a small next action, and start a two-minute session. Keep plain-text notes connected to assignments and classes, view commitments in one calendar, and reserve work time deliberately. Review reported work and reflect on your week without scores or punitive streaks. Optional local reminders explain their permission and scheduling status. Export and validate a backup when moving devices. No account, cloud synchronization, advertising or attention tracking is built into the app. Backups are unencrypted and transfers replace the receiving workspace rather than merge it.

Pending owner inputs: public developer/support email, finalized privacy contact/policy URL, account app identities, pricing/markets/audience decisions, screenshots and final declarations. GitHub public profile email is not automatically adopted as the Store contact. No project license has been selected yet.
