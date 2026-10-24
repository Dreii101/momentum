# Momentum backup format 1

Settings → Data, export and replacement restore exports one unencrypted UTF-8 JSON file. Local storage and the three on-device recovery snapshots do not protect against losing this device. Keep a separate copy. This feature replaces a saved dataset; it does not merge, synchronize, upload or encrypt it.

## Compatibility and integrity

The first supported envelope has exactly these fields:

| Field | Meaning |
|---|---|
| format | `momentum-backup` |
| version | Integer `1` |
| schema | Integer `10`, the first product backup schema |
| exportedAt | Valid UTC ISO instant ending in Z |
| counts | Exact count for every payload section |
| payloadSha256 | Lowercase SHA-256 of canonical payload bytes |
| payload | The 16 sections listed below |

Canonical payload bytes are compact UTF-8 JSON with object keys recursively sorted; array order remains significant. Records export in ID order. Values use JSON strings, integer SQLite values (including 0/1 booleans), or null, with no floating-point coercion. The checksum detects accidental corruption or changed content, not the identity of the creator. Metadata outside the payload is separately validated; it is not authenticated.

Format 1/schema 10 is the only published portable format so far. Unknown, newer, missing or inconsistent format/schema values are rejected before replacement. The old foundation diagnostic fixture is not a product backup. Future schema work must implement/test explicit portable compatibility rather than guessing or silently ignoring fields. `test/fixtures/momentum_backup_v1.json` freezes a real Windows-picker export for regression checks.

## Portable records

Sections: courses, tasks, subtasks, notes, note_task_links, daily_priorities, app_settings, activity_series, activity_exceptions, note_activity_links, planned_work_blocks, focus_sessions, focus_segments, reminder_preferences_rows, reminder_rules, weekly_reflections. Include tombstones, archives, retained superseded series and relevant session history so relationships and reported work survive transfer.

Installation rows, native notification registrations, timer command receipts and notification-cleanup intent are excluded. Command receipts are installation-local retry bookkeeping; they are not credited work. There are no account credentials or caches in the portable format.

| Portable section | Device-local fields omitted |
|---|---|
| app_settings | id, singleton; the receiving settings identity remains local |
| reminder_preferences_rows | id, singleton, enabled; preserve the receiving device's global opt-in and OS permissions |
| focus_sessions | installation_id, clock_epoch, elapsed_mark_ms, background |
| reminder_rules | installation_id; timer rules bind to the receiving installation |

Session start date/zone, task-title snapshot, elapsed/eligible/uncertain amounts, confirmed credit and finalization time remain saved facts. All imported unfinished sessions become interrupted/awaitingReview with no credit or automatic resume. Verified eligible time stays reviewable; monotonic execution markers are rebuilt locally. Finalized credit is unchanged. Session grouping remains its stored local start date, not import time or the receiving zone.

## Validation and replacement

The complete input is limited to 50 MiB and 200,000 total records, including preferences. Native picker streams are bounded even when the provider cannot report a length. No general file URI is converted to a filesystem path: `PlatformFile.readAsByteStream()` and `FilePicker.saveFile(bytes: ...)` handle provider access.

Validation runs in a worker isolate, before the preview and without modifying user storage. It verifies UTF-8/JSON, envelope compatibility, UTC export date, counts, checksum, exact sections/fields, nullable/primitive types, canonical UUIDs, enums, Unicode lengths, calendar dates, integer instants, durations, uniqueness and relationships. A separate in-memory database applies the generated schema's checks/FKs. Additional checks cover IANA zones, date-only boundary agreement, completion-state consistency, session/subtask ownership, original activity dates and acyclic series replacement. Historical activity bounds are not invalidated by a later course-term edit.

Before Replace, the UI shows export time, counts, unfinished-session handling, unencrypted storage and replacement scope. The checkbox and Replace are explicit. Validation results can be viewed without restoring. Cancelled pick/save operations are neutral. Export success is shown only after the native file operation returns success; a failed provider write may leave an incomplete external file and must not be used as a backup.

Replacement flushes note buffers and refuses to proceed if any failed to save. Current unfinished sessions must be explicitly reviewed/finalized first; no work is silently discarded or credited. Other unsaved editors are explicitly covered by the replacement confirmation. Timer and notification writers serialize around the operation, and the app blocks input while it runs.

One SQLite writer transaction reserves the existing installation row without changing its values, then requires a verified snapshot of committed pre-replacement data. This prevents another connection writing between the snapshot and replacement. It then queues cancellation of old native IDs, removes old portable records/registrations/receipts, inserts validated data in batches, checks deferred foreign keys and commits. The installation row, settings identity and local global reminder opt-in remain. Any database failure rolls back the entire replacement, including cancellation intent. UI controllers/drafts in this app instance are rebuilt after commit; close other Momentum windows first so their unsaved buffers do not remain stale.

After commit, the existing reminder reconciler drains durable cancellation intent and rebuilds desired schedules. Failure remains visible and retryable, including after restart; it never rolls back the restored dataset. Old registration callbacks cannot act on removed registration UUIDs. Notification scheduling does not confirm that an alert was seen.

## Local recovery snapshots

Private SQLite snapshots live beside the product database in `product/recovery/`. Unlike portable JSON, they preserve the exact local database, including installation identity and native bookkeeping, for same-device recovery. They are unencrypted and never exported as portable backups. The data screen can validate one through an isolated temporary copy, upgrading that copy if necessary, then offer the same portable preview/replacement flow. The original snapshot is never migrated in place.

Before a product schema upgrade, the native SQLite setup takes a consistent `VACUUM INTO` snapshot before any migration DDL. Before replacement, the same snapshot mechanism reads the live committed database, including WAL data. Snapshot files pass SQLite quick_check, are flushed and atomically renamed before rotation. Keep the latest three completed operations; monotonic naming also handles wall-clock rollback. Incomplete `.pending` files are not recovery choices. Snapshot/storage/verification failure blocks migration or replacement and preserves original data.

If storage cannot open after a failed/incompatible migration, preserve the database and recovery folder. Do not delete/reset a database to resolve the error. Recovery through the app requires an openable workspace; otherwise keep the raw snapshot for a compatible app version or careful repair. Never overwrite the only copy while diagnosing it.

## Verification boundaries

Host tests exercise a chained transfer between two independent SQLite installations and back, identity remapping, confirmed totals/relationships/reopen, the frozen native export, validation limits, cancellation/full-storage simulations, failed transactions, snapshots, migration failures and notification retry after commit. Android/Windows widget layouts cover enlarged text, resize, failed drafts and confirmation. Native Windows additionally exercises actual Open/Save dialogs, both cancellations, real replacement and separate-process restart. Native Android transfer remains pending when device/RAM prerequisites are unavailable; these host checks are not installed-device evidence. Current observations are in VERIFICATION.md.
