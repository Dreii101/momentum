# Momentum architecture — Phases 1–14

## Phase 14 private release packaging

No data schema or backup-format change. Release 1.0.0 build 2 uses normal main.dart; the same source at build 1 is an older signed fixture for installation/update checks, not evidence that an update has run. Android release compilation has no default signer. package_android.ps1 signs the built APK with the private PKCS12 key via an ephemeral password environment variable, then runs apksigner verification. Windows package_windows.ps1 builds the complete native release, uses pinned msix with signing and certificate-installation disabled, then signs via the existing CurrentUser/My certificate thumbprint. No timestamp server or network signing service is used.

The explicit one-time setup_signing.ps1 creates keys outside the repository in a user-only ACL directory and refuses an existing directory. Password files use Windows user-bound DPAPI. Windows' personal signing store is not a trust store; no Root/TrustedPeople changes are made by these scripts. Exported PFX and protected passwords require a separate secure owner backup: copying DPAPI files alone to another computer is not a usable key recovery plan. See RELEASE.md for recovery precautions.

Windows identity dev.momentum.private / CN=MomentumPrivate deliberately leaves prior development registrations intact. NativeNotificationService and optional development probes share release_info.dart's stable private app ID/activator GUID, matching the MSIX manifest. This prevents the shared notification singleton from being reset to the old Foundation identity. Product storage layout is unchanged inside the operating system's application-support location; packaged virtualization may create a separate private workspace. Settings displays build values passed by the packaging scripts. Icons are generated reproducibly by generate_icons.ps1 using Windows drawing APIs, with an adaptive Android resource and PNG-backed Windows ICO.

## Phase 13 verification and repair

No schema, migration, package version or public backup format change. focus_workflow.reportedWorkMilliseconds validates whole-second text against eligible time before multiplication; FocusPage, TimerDevelopmentPanel and progress correction use the same parser. TimerMachine also bounds extension minutes before multiplication. Elapsed-time calculations, idempotency and saved history remain unchanged. Both native overflow regressions failed before repair. Unused early placeholder UI was removed; development wording points to the current flow.

Android's manifest names explicit data-extraction exclusions for cloud backup and device transfer in addition to disabling backup. Compiled release permissions/XML are inspected; there is no release INTERNET permission. Runtime code has no content logging/network client imports. Pinned timezone uses embedded data, not its separate standalone/browser network loaders; SQLite native downloads are build-hook behavior. Windows' configured optional capability list is empty and the app has no cloud service; user/system backup policies remain external.

test/mvp_journey_test.dart also runs in integration_test/mvp_test.dart on native Windows. It creates course/class/note/task relationships, reviews separate starter/focus records, exports/restores and reopens a real SQLite file. Its clock/file/notification adapters are explicitly simulated. Separate opt-in entries measure release performance, test real-clock termination recovery, expose an isolated phone backup workspace and verify the actual phone-saved file on Windows. Normal main.dart imports none of these entries. Benchmarks use 1,000 tasks and 250 notes (~1 MiB text). Android synthetic measurement reports alone use app-scoped external files for ADB retrieval; domain data stays in background SQLite.

## Phase 12 backup and replacement

Schema 10 adds only notification_cleanup_rows, a local native-ID cancellation queue without source foreign keys. It is excluded from portable data. The frozen additive 9→10 migration preserves all 19 prior tables. Before any 1–9 product upgrade, native setup snapshots the committed SQLite database before DDL; failed snapshot creation blocks migration. SchemaVersion remains a literal for drift_dev export; currentSchemaVersion must match it.

features/backup reuses pinned file_picker, SQLite and house components. Existing locked crypto 3.0.7 and sqlite3 3.5.2 become explicit runtime dependencies; no package version/graph update. The codec uses worker-isolate JSON/checksum/type validation and an independent in-memory generated schema, plus semantic checks. A private immutable ValidatedBackup is the only replacement input. The portable allowlist excludes installation/native registrations/retry caches; field-level omissions preserve target-local IDs and opt-in. See BACKUP_FORMAT.md for exact compatibility and data rules.

BackupService owns streamed picker access, verified export, private recovery preview and one transactional replacement. Deferred FK checks support retained/self-linked series; batched writes avoid per-row cross-isolate traffic. A no-op identity update reserves the SQLite writer before snapshot creation; an independent read-only connection snapshots committed original data while competing writes are blocked. Snapshot success is a prerequisite to deletion, never a fallback database reset. TimerCoordinator and ReminderCoordinator expose serialized replacement sections. Timer calculations remain unchanged; after commit the timer view drops old commands/selection and loads the imported interrupted review. Native reminder cancellation intent persists through a crash and is drained before new scheduling, with current source data published first so cleanup failures have Retry UI.

BackupController lives above the shell and owns progress/result/preview through a workspace rebuild. It flushes note drafts, checkpoints active export sessions, distinguishes picker cancellation and confirmed replacement, and separates post-commit reconciliation warnings. The root blocks pointer/keyboard interaction during operations. A workspace route generation remounts editors after replacement; old note controllers are invalidated. SQLite/streams remain the durable truth; no secondary state-persistence system or timer engine was added.

RecoverySnapshots uses native SQLite in a worker, quick_check, flushed temporary output, atomic rename and three-file retention. Sequence naming remains monotonic after a wall-clock rollback. Private snapshots preserve local identity/native rows; inspection copies them into a bounded temporary directory and never mutates the retained original. The isolated backup_restart_app.dart/dialogs acceptance entries are never imported by normal builds.

## Phase 11 progress and reflection

Schema 9 adds only weekly_reflections: UUID ID, unique Monday calendar week-start, three plain-text answers (5,000 Unicode characters each), and UTC created/updated timestamps. Frozen 8→9 SQL is additive; historical schemas 1–8 remain unchanged. No timer or completion records are rewritten during migration. Failed upgrades roll back DDL/data/version and preserve the database.

ProgressRepository reads tasks, joined subtasks/parents, sessions and reflection in a consistent transaction on the existing background SQLite connection. Completion instants are filtered by the selected Monday-to-Monday range in the current planning zone. Trashed parents/steps/tasks are excluded; archives remain included. Reopening removes the current completion timestamp, so these are current completion summaries rather than an immutable event ledger. Step completion remains independent of parent completion.

Session queries use the indexed stored local_start_date; all interval credit belongs to that date even across midnight, zone changes or later corrections. Only finalized non-break rows with explicitly confirmed reported_ms contribute time and starter/focus counts. Each original row is counted once; continuations are separate intervals, and segments never add another credit. Zero-credit reviews count as reviewed sessions. Unfinished/recovery rows remain visible in history and excluded from credit.

correctReportedWork is a separate, explicit confirmed transaction for finalized starter/focus rows, bounded by unchanged eligible_ms. Optimistic revision checks reject stale changes; repeating the saved amount is inert. It increments revision but preserves elapsed/uncertain evidence, start date, finalization timestamp and immutable timer command receipts. Timer finalization remains idempotent and the existing engine is unchanged. Drift streams update Progress and existing session details together. The progress invalidation SQL has its own alias because Drift caches streams by SQL/arguments rather than the readsFrom set.

ProgressPage retains transient reflection and correction controllers by week/session, uses the existing shell routes and components, and stacks content on Android while arranging summary/history beside details/reflection on wide Windows. Reflection is explicitly saved (also Ctrl+S); failures retain drafts. No second persistence system, dependency, chart library, analytics or timer is introduced. The isolated progress_restart_app.dart acceptance entry uses its own SQLite directory and fixed fixture week; ordinary builds never import it.

## Phase 10 local reminders

Schema 8 adds reminder_preferences_rows, reminder_rules and reminder_registrations (18 tables, 23 explicit indexes). Frozen additive 7→8 SQL preserves prior records and upgrade paths. UUID/FK/enum/unique constraints enforce one rule per source, stable registration identities and native IDs. Global reminders default off. Prior snapshots 1–7, dependencies and timer calculations are unchanged. A populated-v7 test compares all 15 prior tables, Unicode text, session segments and command receipts through successful upgrade and injected transactional failure.

ReminderStore reads consistent source snapshots and stores intent before OS effects on the existing background SQLite connection. NativeNotificationService adapts pinned flutter_local_notifications 22.3.2; small native methods read Windows access/package capability or open device settings. Android's pending API reads plugin cache, so the coordinator reinstalls future IDs once per process to repair lost native alarms; unchanged subsequent reconciliations are inert. Product IDs start at 1000000, independent of probe/test IDs 190017/190018. Diagnostics and product code share one response dispatcher, so reinitializing the pinned singleton plugin cannot steal callbacks.

planReminders is pure over explicit source records/zones and an injected timer sample. ReminderCoordinator serializes/coalesces reconciliation, compares durable fingerprints and current OS pending IDs, cancels obsolete/orphan product IDs individually, schedules changed/missing future triggers and persists retryable errors. Pending-list acknowledgement never implies delivery. Exact-access revocation can fall back to approximate Android timing. Cancellation failures retain IDs and block occupied slots. Late current approximate triggers consume the same capacity. OS effects never enter source-save or timer-command transactions.

Riverpod owns the coordinator outside screen lifetimes after timer startup recovery. Committed Drift changes and foreground lifecycle/status checks invalidate schedules. A 15-minute refresh runs only while enabled; disposal stops subscriptions/timers. The pinned Android boot receiver restores cached triggers; full Dart reconciliation waits for launch/resume. Source zones are explicit; planning-zone edits update quiet-hour projections. Callbacks validate a UUID reference, re-read current records, reject stale/cancelled/completed sources and navigate without work commands. Only explicit valid source opening records openedAtUtc.

Settings → Reminders reuses house components and retained controllers for contextual access, scheduling coverage, quiet hours, per-source rules, test and retry. A compact shell icon appears only for an error/stale callback. Ordinary release builds never import integration_test/reminders_restart_app.dart; that isolated native entry writes PID-labelled pending/active observations in its own fixture directory.

## Phase 9 starter/focus/review presentation

FocusPage lives in the existing Today destination and uses stable selected-record routes: starter/taskId, focus[/taskId], break, session/sessionId and history. Focus setup, review controllers and selection survive width/theme changes and destination switches. Android Back/Back to Today leaves the session intact. The shell's existing single ActiveSessionControl derives its presentation from TimerCoordinator and returns to the same original session. No destination, native window control or persistence store was added.

SessionCountdown uses TimerMachine.advance and the injected engine clock only to project remaining time. Its one-second display callback never writes or awards work; TickerMode and session state stop unnecessary display callbacks while hidden/paused. The existing coordinator still owns checkpoints outside page lifetimes. Countdown text is excluded from second-by-second screen-reader announcements; the saved checkpoint remains readable. Session/history providers query existing Drift rows, with explicit failure/retry and a 20-record recent-history limit.

focus_workflow.dart centralizes navigation and both explicit whole-task completion entry points. It asks the existing coordinator to end linked running/paused work, then saves the task status and opens uncredited review. Repository updateTask/setTaskStatus also check the running/paused relationship inside their transactions so a competing start cannot bypass review. TimerStore rejects new sessions for unavailable/completed tasks and completed/removed/wrong-task subtasks. Timing calculations, durable command receipts, state machine, schema 7, migrations and dependencies remain unchanged.

Continuation is an explicit command after review finalization, creating a new focus record through the same coordinator. No automatic intervals or completion occur. Mark step done is a separate existing repository operation. Task/note buttons select existing records, preserving the note editor's normal draft/flush behavior. Recent review history is not the later progress-summary feature.

integration_test/focus_restart_app.dart opens an isolated schema-7 fixture with a task, step, original linked note and daily priority. It retains before/after recovery rows in a PID-labelled report; normal builds do not import it. focus_test.dart exercises the real native starter/focus/review/history controls with Stopwatch/UTC and explicit zero work, independently of fake-clock expiry tests.

## Phase 8 persistent timer engine

Schema 7 adds focus_sessions, focus_segments and timer_command_receipts with four explicit indexes (15 tables, 21 explicit indexes). The frozen additive 6→7 step preserves all prior tables and upgrade paths. SQL enforces duration/state/report bounds, foreign keys, segment ordering and one unfinished session per installation through a partial unique index. Historical snapshots 1–6 remain unchanged.

features/focus/timer_engine.dart is a pure state machine over injected UTC/elapsed samples and clock epochs. timer_clock.dart combines the existing wall-clock injection with Stopwatch. UI tick counts never measure time. Raw wall endpoints and bounded elapsed/eligible/uncertain durations form a durable segment ledger. Break and pause time cannot become work; uncertainty is conservatively excluded. Policy thresholds and extension/recovery rules are in SPEC.md.

TimerStore reuses MomentumRepository's background SQLite connection, installation metadata, clock/IDs and transactions. Session revisions guard competing updates; each command atomically commits its state, segments and idempotency receipt. A repeated command ID returns the committed session, while reuse with different arguments fails. Finalization never writes task, subtask, estimate or planning data. No additional persistence system or dependency is introduced.

TimerCoordinator serializes writes and publishes confirmed state only after persistence. It owns a five-second checkpoint loop only while running/paused; no idle timer runs. Its Riverpod owner is watched by MomentumApp outside destination trees. Lifecycle events checkpoint/flag background intervals, but correctness does not depend on receiving a shutdown callback. Startup recovers unfinished sessions for review. Failed commands retain the last confirmed view and an explicit retry closure with the original command ID, including lost-acknowledgement retries.

The existing development page hosts TimerDevelopmentPanel with reusable form/error components. These controls operate on real workspace sessions and explain their scope; platform probes remain independent. The final active-session/footer source is deliberately left for Phase 9. Native acceptance uses integration_test/timer_restart_app.dart with isolated populated schema-6 data and real elapsed clocks. It compares old records, persisted segments and finalized history before/after separate processes; the native UI test uses a separate unique fixture.

## Phase 7 calendar and manual planning

Schema 6 adds planned_work_blocks and two indexes (12 tables, 17 explicit indexes). Frozen planningV6Sql implements an additive 5→6 step. Historical exports/migrations remain intact. planning_repository.dart uses the existing background SQLite connection, transactions and injectable clock/IDs. Save commands write only work-block columns, with no task update. Soft removal/restore preserves identity; task Trash/archive hides projections while retaining work rows.

PlanningSnapshot reads tasks, blocks and schedule sources in one transaction. A Drift invalidation stream watches their tables. calendar_projection.dart is a pure projection/filter/range layer shared by all views; no calendar entry table or parallel persistent store exists. Date-only entries use their written date; instant entries use the selected display zone and half-open bounds. Existing recurrence expansion supplies one effective moved occurrence and explicit cancellations. Work conflict checks use current source state and exclusive interval edges.

PlanPage retains CalendarPage and SchedulePage under a keyed IndexedStack and excludes the hidden page from keyboard focus. Legacy course/activity/occurrence routes still select the timetable. Calendar routes select work/id, new-work[/taskId], calendar-task/id and calendar-occurrence/seriesId/originalDate. Record-keyed detail subtrees retain text/selection through width changes. Mobile uses focused forms; wide Windows uses a selected-item panel. Source buttons navigate to existing task/activity editors.

watchReminderReconciliationInputs and reminderReconciliationInputsProvider provide the initial full snapshot and subsequent committed-source invalidations independently of calendar widgets. Future reminder code must derive and reconcile desired registrations idempotently, including removals, rather than rely on transient UI callbacks or one emission per operation. This phase adds no reminder tables or OS scheduling.

Native verification uses integration_test/planning_restart_app.dart with an isolated populated schema-5 fixture and compares every field in all 12 tables after restart. Its UI test uses a unique independent folder. Normal lib/main.dart never imports these diagnostics. On this 8 GB development machine, run tests with --concurrency=1 and build/test Windows and Android sequentially; keep the emulator closed during Windows/host checks. Resource observations belong in VERIFICATION.md, separately from application correctness.

## Phase 6 courses and recurring activities

Schema 5 adds activity_series, activity_exceptions and note_activity_links, bringing the product database to 11 tables and 15 explicit indexes. The additive 4→5 step uses frozen exported SQL; 1–4 snapshots and earlier migration steps remain intact. Existing rows are not rewritten. Foreign keys, UUID/date/type checks, positive wall duration, recurrence/weekday shape, unique series/original-date exceptions and an expression unique index for note/series/optional original-date links protect persistence. Whole-series links use COALESCE in that index so null does not bypass uniqueness.

schedule_repository.dart extends the existing repository and injectable clock/ID source. Commands and consistent schedule snapshots use the same background native SQLite connection. A Drift invalidation stream watches courses, series and exceptions. There is no materialized occurrence table or second storage system. recurrence.dart generates only candidate dates near a bounded instant range plus relevant moved-in exceptions, resolves IANA offsets deterministically, and sorts by start/identity. Start gaps shift the whole interval; folds choose the first instant. Cancellation and supersession remain explicit projections.

Series replacement previews fingerprint original rows, exceptions and links; the transaction rechecks the preview, validates future scope and creates the replacement before marking the old cutoff. It never truncates original bounds or moves old relationships. Already-held moved meetings refuse an affected split. Original-date lookup remains available after supersession. Course term edits cannot strand existing series outside the term.

features/schedule owns the daily/weekly timetable, course/activity editors, occurrence detail and secondary note selectors. Shell routes use course/id, activity/id, occurrence/id/original-date and replace/id/original-date. Keyed detail trees retain controllers through resizing. Explicit saves retain input on failure; previews are invalidated on edits. The retained-series ExpansionTile has its own PageStorageKey, separate from scroll offsets. Note editor links navigate to the original activity identity, and schedule links open the existing note buffer.

integration_test/schedule_restart_app.dart creates an isolated populated schema-4 fixture, verifies a production upgrade, writes course/exception/split/note-link records, then compares all 11 tables in subsequent processes. It never opens product/momentum.sqlite. Native UI tests use independently named fixture directories. Normal builds target lib/main.dart.

## Phase 5 notes

features/notes contains the library, focused/list-editor presentation, secondary relationship selectors, query providers, a record-scoped NoteController and the session-owned NoteDrafts registry. Each UUID owns its TextEditingControllers and selection independently of responsive widget reconstruction. The registry is transient memory, not another persistence system. Drift remains the durable source of truth; schema 4, historical migrations, native runners and dependencies are unchanged.

NoteController debounces text/metadata edits for 500 ms and serializes complete snapshots. It records a revision before awaiting a write, marks only that committed revision saved and drains newer edits afterward. Selection changes alone do not write. In-flight saves leave typing enabled. Database echoes never replace editor text/selection. Failed validation or writes keep the exact buffer; explicit Save/Ctrl+S/Retry share the serialized writer. Repository validation counts Unicode code points consistently with SQLite limits (title 200/body 100,000).

MomentumApp observes route/lifecycle changes outside paused destination trees and requests best-effort draft flushes. NotesRecoveryBar also lives outside StorageGate, retaining Review/Copy access when a note is hidden or opening fails. Note-level read failures retain the editor when a buffer exists. Notes query providers disable automatic retry so failures are visible with explicit recovery. Abrupt process death before a successful commit cannot guarantee unsaved text; there is no draft journal or alternate disk store.

Repository note queries run on the existing background native SQLite connection. Search uses parameterized INSTR/LOWER over title/body: literal substring matching with ASCII case-insensitivity and literal Unicode elsewhere, appropriate for a personal dataset without a new FTS schema. Library order is pinned/latest update/stable ID. Linked projections join original records, including tombstones. Transactional idempotent relationship commands supplement the existing SQL unique pair constraint; unlinking changes only the relationship. Trash first flushes the draft, then changes its tombstone, and refuses to proceed after a failed save.

Course association remains optional. Selectors preserve a currently archived/deleted course and retained links to trashed records. Phase 6 supplies course management and activity relationships. No rich text, attachments, cloud calls or additional persistence is included.

## Phase 4 task workflow

features/tasks contains task_workflow.dart (query providers, injectable observed clock, date/overdue rules, strict local-time parsing and transient TaskEditBuffer), tasks_page.dart (capture/search/visibility/list-detail), task_editor.dart (explicit detail save), task_controls.dart (committed completion/archive/trash/priority commands), subtasks_editor.dart and today_page.dart. It uses existing Drift repositories and no new dependencies or second persistence system.

The shell retains its keyed destination tree. Per-task raw drafts belong to TasksPage, so reconstructing a detail editor or changing layout does not lose text. Android uses a single list/detail flow; Windows splits from 1000 available logical pixels. ShellNavigation retains record IDs and clears selection for Task list/Android Back. Sidebar controls form a focus traversal group.

Repository additions are partial status/archive commands, updateTaskDetails (preserves current committed status), transactional append/reorder and daily-priority toggle, task streams including tombstones, a joined daily-task projection and an unfinished commitment query. Details validation and transactional commands commit before UI success. Background SQLite execution and all original native checks remain in place.

New task query providers and the existing subtask family subscribe directly to repository streams through repositoryStream; off-screen queries can pause/resume without an extra asynchronous generator. Database errors remain errors. The workflow clock cancels its timer when unobserved/disposed and refreshes on app resume. Time classification is a pure function over saved UTC boundaries and an injected instant, independent of the device’s implicit zone.

Schema 4 adds only tasks.archived_at and tasks_visibility. The frozen 3→4 step uses ALTER TABLE with a nullable INTEGER column; table IDs, links, checks, preferences and other records remain unchanged. Versions 1/2 first apply their existing frozen migrations. Fresh schema and populated 1/2/3→4 schemas are compared against the frozen version-4 export, with all original fields checked and rollback/refusal tests retained. Historical snapshots 1–3 are unchanged.

Flutter 3.47.7 / Dart 3.13.5 reused after live inspection. Android + Windows native runners only. Application code has no HTTP/client/cloud/analytics behavior. Some build dependencies have network-related transitive dependencies; that does not imply application networking.

## Boundaries

`lib/main.dart` → Riverpod ProviderScope → `lib/app/momentum_app.dart` adaptive shell.

Development route → injected `ProbeServices` → isolated Drift `ProbeDatabase`, native file_picker dialogs, flutter_local_notifications, application-support path_provider and a small Windows package-identity method channel.

The Phase 1 database remains a single write-count probe, schema version 1, in `foundation_checks/probe.sqlite`. The product database is separate: `product/momentum.sqlite`, currently schema 10. Version 2 tightened priority slots; version 3 adds preferences; version 4 adds task archiving; version 5 adds schedules and note-activity links; version 6 adds manual work blocks; version 7 adds the timer engine; version 8 adds reminders; version 9 adds reflections; version 10 retains notification cancellation intent across replacement. Phase numbers are not schema versions.

## Phase 3 shared presentation

`MomentumApp` observes the existing Settings stream for theme and reduced motion, including live device accessibility changes. It uses Material 3 with neutral surfaces, teal accents, 16-pixel body text and shared 4/8/12/16/24/32 spacing tokens. Native Windows runners and window controls are unchanged.

`AdaptiveShell` chooses bottom navigation, rail or sidebar from available width. One keyed content subtree and IndexedStack retain destination pages; inactive pages exclude keyboard focus. Riverpod's ShellNavigation stores current destination and per-destination record selection as transient route state. It is not a duplicate database store. PageStorage retains per-page scroll offsets. The future session presentation and open callback are injectable, null by default, with a single host outside destination pages.

`components.dart` provides scroll containers, section cards, form fields and distinct loading/error/empty components. Error disclosure uses local widget state, isolated from scroll-position storage. Focused inputs/buttons have visible borders; Material controls use at least 48-pixel targets. Long pages and sidebar/rail navigation scroll at large text sizes or short window heights.

`features/settings/settings_page.dart` retains controllers across navigation/resizing. It validates the entire draft before one repository command, disables conflicting saves, and keeps the draft on failure. Preference fields are not autosaved. The saved Settings stream drives the application theme only after commit. Ctrl+S is scoped to the Settings form.

Schema 3 rebuilds only AppSettings using a frozen definition, copying all prior values and supplying defaults for focus_minutes, break_minutes and reduced_motion. Historical snapshot files remain intact. Fixture tests cover both 1→3 and 2→3, full domain-data preservation and unchanged singleton IDs. SQL duration checks reject fractional values as well as invalid ranges.

## Phase 2 durable data

Phase 2 introduced eight tables in `lib/core/database/app_database.dart`, with SQL constraints and indexes; Phase 6 adds three more. Generated rows (`Course`, `Task`, `Subtask`, `Note`, `NoteTaskLink`, `DailyPriority`, `Settings`, `InstallationMetadata`) are typed immutable persisted records. `value_types.dart` supplies enums, CalendarDate, UTC converters, injectable clock/UUID generation and IANA date-boundary conversion. `repository.dart` owns commands and streams. A draft update replaces all editable fields, so null explicitly clears a nullable field; it preserves IDs, creation timestamps and deletion/archive state.

`providers.dart` owns the application-support file location and one native background connection per Riverpod container. Clock, UUID source and file resolver are injectable. Riverpod query providers project Drift streams; no second persistent state store exists. Subscribe while consuming streams, and dispose query subscriptions before awaiting database closure. Opening failures close the failed connection, retain the database and expose an explicit retry; automatic retry is disabled for database opening.

`StorageGate` wraps existing shell content. It distinguishes opening, opened and failed states; details include the affected file and original error. It offers Retry and explains disk/folder access, compatible versions and preservation/recovery. Development checks remain accessible independently. Ready means SQLite opened and metadata initialization committed, not that feature editors exist.

`NativeDatabase.createInBackground` runs SQL in an isolate on both native platforms. Connections enable foreign keys, a 5-second busy timeout, WAL journaling and FULL synchronization. Priority replacement and multi-record operations use transactions. SQLite's slot/unique constraints enforce three daily priorities even for competing connections. A competing deferred write can return SQLITE_BUSY; callers must expose/retry a failed save, not treat it as success.

Foreign keys restrict hard deletion of referenced records. Soft deletion uses UTC tombstones; course archiving uses a separate timestamp. Neither operation cascades into notes/history. Link removal is an explicit association deletion. SQLite enforces UUID shape, enum values, title/body bounds, date validity, deadline field shape, target bounds, completion/status consistency, references and uniqueness.

## Schema preservation and migrations

The authoritative exports are drift_schemas/momentum/drift_schema_v1.json through drift_schema_v7.json, including concrete SQLite CREATE statements. build.yaml declares the database/export locations. tool/export_schema.ps1 regenerates Drift code, exports into temporary build storage, checks an existing snapshot without overwriting it, or adds a snapshot for a new version.

Creation is transactional; unsupported upgrades or downgrades fail with a preservation message. `migrateSchema` executes supported steps inside a transaction. The real 1→2 migration rebuilds only daily_priorities using frozen version-2 SQL from `migrations.dart`, copies every field/ID, replaces the old table, and recreates its index. Version 1 allowed a fractional slot through `BETWEEN 1 AND 3`; version 2 requires `IN (1, 2, 3)`. Historical invalid slots make the migration fail and roll back without discarding records. No delete/reset fallback exists.

The pinned Drift 2.35.1 helper generator failed to parse the concrete exported schema (`DriftTableResolver.buildPending: Bad state: No element`). Schema export itself succeeds. Therefore migration tests use the self-contained exported SQL directly, rather than relying on an incomplete generated helper. `test/support/schema_fixture.dart` creates old databases from frozen SQL and seeds all eight tables using raw version-specific SQL independent of current models. Tests compare every table/index/CHECK definition against fresh and migrated app databases, every seeded field across the real 1→2 upgrade and reopen, unsupported-version preservation, foreign-key validation, invalid-slot upgrade refusal, and rollback of both DDL and DML during an injected failed migration.

For a future schema change:

1. Preserve all historical snapshots and raw fixture seeders; increment `schemaVersion`.
2. Implement only the explicit supported version steps in `migrateSchema`; use historical SQL/schema definitions, not assumptions about latest tables. Do not drop data to repair a failure.
3. Run `tool/export_schema.ps1` to create the new frozen export.
4. Test old populated fixtures through the actual production migration, comparing resulting schema with the new export and all retained values/relationships. Extend the fixture helpers for each historical version. Keep failure/rollback tests.
5. Verify upgrade/reopen on native platforms before claiming an upgrade works.

The extra failing migration subclass is fault injection and never runs in the application. The production 1→2 step is tested independently with real populated fixtures. Every later schema change still requires its own preserving migration and tests.

`FileFixture` is a fixed diagnostic JSON format bounded to 64 KiB, validated while streaming. File selection cancellation is a neutral result. Fixture success is not a user backup guarantee. Do not assume Android URI selections are local Windows file paths.

Notification ID 190017 is reserved for explicit diagnostics. UTC time-zone-aware one-off scheduling uses inexact Android mode and asks permission on Schedule only. No exact-alarm/fullscreen/Do-Not-Disturb override access is requested. Native permission denial is a result, not a successful schedule. Windows checks require actual package identity so an unpackaged no-op cannot pass. Delivery still needs an observed control, not just a pending API return.

The diagnostic Windows identity is `dev.momentum.foundation`, distinct from the preserved old project's `dev.momentum.app` development registration. Production identity/signing is a later release decision; never overwrite the old registration to test this one. Android application ID is `dev.momentum.app`. Probe storage is isolated from earlier development schemas.

## Future feature modules

Use `features/{tasks,notes,courses,schedule,calendar,focus,planning,progress,reminders,backup,settings}` and `core/{database,time,ids,errors,platform}` as needed. UI → Riverpod query/command providers → pure domain services and repositories → Drift/platform adapters. Add meaningful boundaries instead of empty boilerplate layers. SQLite is the durable truth; no duplicate Riverpod persistence store.

Future entity map: Course; Task; Subtask; DailyPriority; Note; NoteTaskLink; ActivitySeries; ActivityException; NoteActivityLink; PlannedWorkBlock; FocusSession; FocusSegment; ReminderRule; NotificationRegistration; WeeklyReflection; Settings; InstallationMetadata. Implement only when the relevant authorized phase needs them, with explicit migration/foreign-key/unique/index tests. See SPEC.md for invariants.

## Development tools and reproducibility

`tool/flutter.ps1` and `tool/dart.ps1` read ignored `tool/local-toolchain.json` or `MOMENTUM_TOOLCHAIN_HOME`, and otherwise use local `.tooling`. They temporarily set cache/SDK environment and restore it. The existing tools reside in the preserved backup's ignored `.tooling`; backup source/Git files are not reused as the new application. Keep that toolchain available until deliberately relocated. No global PATH or signing-trust change is needed.

Exact stable dependency pins and pubspec.lock are retained. Drift code generation is explicit. Native SQLite build hooks obtain the official platform library when not cached. Builds may need network even though the app works locally. Never manually edit generated `*.g.dart`.

Debug mode exposes Development. Ordinary release builds hide that route. Explicit diagnostic release builds add `--dart-define=MOMENTUM_DEV_CHECKS=true`. All development UI labels its limited purpose.

## Primary documentation checked

- https://docs.flutter.dev/platform-integration/windows/setup
- https://docs.flutter.dev/reference/supported-platforms
- https://drift.simonbinder.eu/setup/
- https://drift.simonbinder.eu/platforms/
- https://pub.dev/packages/file_picker
- https://pub.dev/packages/flutter_local_notifications
- https://pub.dev/packages/msix

Package support is not native verification. Actual results belong in VERIFICATION.md.
