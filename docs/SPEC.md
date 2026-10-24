# Momentum specification

Source: the completed Momentum framework in this chat, 20 October 2026 (Asia/Manila). The handover supplies historical preferences; the user's current instructions take precedence. The neighboring Prompts directory contains original requests, not this specification, and is excluded from development inputs.

## Phase 11 — progress and weekly reflection

Progress is available through the Android menu and Windows sidebar. Weeks run Monday through Sunday with previous/next/this-week navigation. The summary shows current completed task/step counts, confirmed reported work, and separately counted reviewed starter/focus sessions. Expand the completion count sources or open session history to inspect the original records. Empty weeks show neutral text; query failures show unavailable totals and Retry instead of zeroes.

Completion timestamps are interpreted in the current planning time zone. Archived records remain included; trashed tasks/steps and steps whose parent is trashed are excluded. Reopening removes that item's current completion; completing it again counts at its new completion timestamp. Completed steps remain independent of task state. These counts describe current records, not all historical completion/reopening events.

Reported focus time includes finalized, explicitly confirmed starter and focus work, never breaks, pauses or uncertain recovery time. A reviewed interval with zero work remains a session count. Starter and continuation rows each represent one distinct interval and are counted once; no segment or transition contributes extra credit. All time from an interval is assigned to its stored local start date in its original zone, including cross-midnight intervals. Later zone preferences and correction dates never move that session's week. Displayed times use minutes:seconds, rounded down to whole seconds.

Session details show kind, task-title snapshot, state/outcome, saved start date/zone, UTC start, elapsed/eligible/uncertain time and saved credit. Only finalized work sessions allow correction: explicitly confirm whole seconds from zero through eligible work. Failed saves retain the input; a changed record requires reloading its amount before a different correction. Corrections update all saved projections without altering elapsed evidence, completion state or finalization semantics. Unfinished records open the existing review flow. Linked task access remains available.

Each Monday date has one optional reflection with three answers: what helped, what got in the way, and one adjustment for next week. Each allows 5,000 Unicode characters; blank answers are allowed. Save or Ctrl+S confirms persistence before Saved appears. Unsaved drafts survive week/destination changes, resize and theme changes within the running app; explicit saving is required for process restart. Save failure retains the draft and exposes Retry; text remains selectable/copyable. Android stacks summary/history/reflection; wide Windows places summary/history alongside details/reflection. No scores, streaks, rankings or attention claims.

## Current authorization and product goal

**Current authorization: Phases 1–14 only.** Includes the existing MVP, verification/repair and first private signed Android/Windows packaging. Stop before Phase 15. The user requested package preparation without phone testing for Phase 14.

Subsequent authorization on 24 October 2026 includes a new public GitHub repository and reviewed preview distribution, Android/Windows installation documentation, and Microsoft Store/Google Play publishing preparation. Both developer accounts are not yet available. Public source excludes private local evidence/history, user data and signing secrets. Installed-release gates remain pending; no V2 feature work is authorized.

Momentum helps its personal user capture responsibilities, choose a small next action, and start before deadlines become crises. It is a private installed app on Android and Windows, not a website/PWA. No monetization, account or paid service is needed for the MVP.

## Scope and recommendations

The user confirmed all nine product areas: tasks, two-minute starts, focus timers, deadline planning/breakdown, notes, class/recurring activities, calendar/daily planning, progress/reflection, reminders. Convenience, supportive language and no punitive gamification are requirements.

The approved Phase 1 prompt selects Flutter/Dart, Riverpod and Drift/native SQLite as the foundation. The proposed MVP is offline, account-free, local-first, with manual backup transfer rather than automatic sync. Plain-text notes, colors, breakpoints, limits and release placement are recommendations adopted as implementation baselines when their phase is requested, subject to later user revision.

## MVP inventory

- Tasks: title-only capture; description; optional course, next action, deadline, target, estimate; priority; todo/doing/done; complete/reopen; search/filter; soft delete/restore. Archive courses without removing history.
- One-level subtasks: editable, reorderable, independently complete/reopen. Completing all steps offers explicit whole-task completion.
- Today: zero to three deliberate daily priorities, active session, next commitment and upcoming deadlines. Choosing another planning day never edits the actual deadline.
- Two-minute start: select a task and feasible action; explicit Start; exactly 120 seconds; review; Continue 10/25/custom, mark selected step done, or stop.
- Focus: 10/25/50-minute presets; custom 1–180 minutes; pause/resume; explicit extension; end/review; optional editable break; one unfinished session per installation.
- Deadline planning: official deadline, separate internal target, manually revised remaining estimate and manual work blocks. Computed proposals are Version 2.
- Notes: plain text; optional title/course; pin/search; autosave; task/activity links; trash/restore. No rich text, media, notebooks or block editor in MVP.
- Courses and activities: course metadata and term dates; one-off or weekly recurring series; weekdays/local times/zone/date bounds/location; busy/free state; occurrence cancellation/move; series replacement.
- Calendar: Agenda/Day/Week, filters and source editing. Date-only deadlines are all-day entries. No duplicate stored calendar copies.
- Progress: confirmed reported work, session history, current completion summaries and weekly reflection. No scores, rankings, penalties or attention-measurement claim.
- Opt-in local reminders with explicit permission/scheduling status and in-app missed-commitment recovery.
- Versioned JSON export/validation/replacement restore; three local recovery snapshots; cross-platform transfer.
- Adaptive Android/Windows layouts, system/light/dark themes, text scaling, keyboard navigation and reduced motion.

## Task, note and calendar relationships

### Phase 2 storage decisions

The product database is `product/momentum.sqlite` inside native application-support storage, separate from all diagnostic databases. Phase 2 delivered schemas 1→2, tightening daily-priority slots. Phase 3 adds preferences in schema 3 as described below. Schema versions are independent of phase numbers and the Phase 1 probe schema.

Phase 2 entities: Course, Task, Subtask, Note, NoteTaskLink, DailyPriority, Settings and InstallationMetadata. Phase 6 adds ActivitySeries, ActivityException and NoteActivityLink in schema 5. Generated Drift rows are the typed persisted models; repository drafts are complete replacements of editable fields. UUIDs use canonical lowercase RFC UUID strings (new records use secure v4). Instants are integer UTC milliseconds; calendar dates are validated `YYYY-MM-DD` values represented by `CalendarDate`, never device-local midnight timestamps.

Deadline fields have mutually exclusive shapes: none, dateOnly (calendar date + IANA zone), or timed (UTC instant + original IANA zone). A derived UTC deadline boundary enables indexed queries: exclusive start of the next local date for dateOnly, equal to the instant for timed. The repository computes that boundary from the date and zone, including DST. Future imports must use the same validation and recompute it. SQLite enforces field shape, valid calendar dates and target/boundary ordering; IANA zone validity and derived date/zone agreement are repository responsibilities. Internal target is a separate nullable UTC instant; remaining estimate is separate nullable nonnegative minutes. Neither is automatically changed by time spent.

Daily priorities have UUID identity and exactly the slots 1, 2 or 3, unique per calendar date/slot and calendar date/task. SQLite's INTEGER affinity alone does not exclude fractional values, so schema 2 uses `slot IN (1, 2, 3)`. Replacing a day's selection is one transaction; reordering retained selections preserves their IDs. Concurrent writes either commit the whole selection or return an error for retry. Deleting a task removes its daily-priority selections, preserves its notes, links and subtask records, and retains the task tombstone. Restoring a task does not silently restore previous priority selections. Course archiving and course soft deletion preserve linked tasks and notes. Note/subtask deletion is also reversible. Removing a note-task link removes only that association.

Settings contain system/light/dark preference, planning IANA zone (initially Asia/Manila), focus minutes (default 25; 1–180), break minutes (default 5; 1–60) and reduced-motion preference (default false). The Phase 3 Settings form commits all changes through the existing repository. InstallationMetadata retains its stable UUID and creation instant. Future export excludes installation identity. Phase 7 adds work blocks; Phase 8 adds sessions, segments and command receipts. Reminders and backup tables remain later work.

### Phase 3 preferences and shell

Product schema 3 adds only preference fields through a preserving 2→3 migration, retaining historical schemas and the 1→2 step. Course/task/note/link/priority rules remain unchanged. The migration keeps existing Settings values, IDs, timestamps and installation metadata; new fields receive documented defaults. Opening checks broken relationships before modifying an older database.

Layouts use available logical width: below 600, four primary bottom destinations and a menu; 600–999, a compact rail; from 1000, a sidebar and list/detail slots. Android always keeps Progress and Settings in its menu. Windows includes them in its rail/sidebar; a compact Windows window uses the menu fallback. Navigation selection, per-destination selected-record route state, scroll positions and Settings drafts survive resizing and switching destinations. Empty future routes explain that their tools are coming; no tasks, sessions or metrics are invented.

Settings uses explicit Save changes (or Ctrl+S while focused inside its form). Saved means the transaction committed. Failed saves retain edits and offer Retry. Unsaved edits survive in-app navigation and resizing, but are not persisted across application termination. Time-zone entries are validated IANA names. Changing the planning preference does not rewrite existing deadlines or course zones. Theme and motion changes apply after saving.

Reduced motion is enabled when either the user preference or device accessibility setting requests it. Navigation changes immediately; theme and diagnostic-route transitions last at most 180 ms and become immediate with reduced motion. Loading remains understandable without animation. The persistent shell session slot connects to the durable timer and opens its current session/review without restarting it.

A task and a note may each belong to one course. Notes can link to multiple tasks and to a recurring activity or a specific occurrence. Links expose the same note, never duplicate its body. Planned work belongs to a task. Focus can be general or linked to a task and one of its subtasks. Deleting a task must not delete notes. Historical sessions keep a title snapshot when a task disappears.

Tasks require only a 1–200-character title. Keep none/dateOnly/timed deadline kinds distinct. A date-only deadline stores a calendar date and applicable zone and becomes overdue after that date ends. A timed deadline stores UTC plus the original zone. Internal targets cannot follow official deadlines. Estimates are nullable remaining minutes; focus time never automatically subtracts from remaining effort.

Notes autosave after approximately 500 ms idle, support explicit Save/Ctrl+S, and show Saving/Saved/Failed. Saved means committed, not merely typed. Preserve the buffer and permit Retry/Copy after failed storage. Flush on navigation where possible. Enforce the proposed 100,000-character body limit. A short unsaved debounce interval must remain visibly unsaved.

### Phase 4 task workflow

Quick capture requires only a trimmed title, 1–200 Unicode characters. Task details save explicitly; optional course, next action, description, low/normal/high priority, deadline, internal target and remaining minutes remain independent fields. To do, Doing and Done are explicit states. Completion retains its UTC timestamp until reopening; editing details reads the current status transactionally so a stale form cannot undo a separate completion action.

Archive is separate from Trash and completion. Schema 4 adds Tasks.archivedAt and an indexed visibility query. Archive and Trash remove daily selections, preserve linked notes and all child records, and are reversible. A task restored from Trash remains archived if it was archived before deletion. Neither restore operation automatically reselects daily priorities. No permanent task deletion is exposed.

One-level subtasks have editable titles, independent completion and ordered positions. Append and full-permutation reorder are transactional; invalid/stale permutations change nothing. Up/down buttons support keyboard and touch without requiring drag gestures. Removed steps have a restoration disclosure. All visible steps done offers an explicit whole-task completion button; it never completes the task automatically.

Today uses the current date in Settings.planningZone. Daily choices are manual, zero to three, and toggles read/replace the selection in one transaction. Completed choices remain visibly completed until removed or the planning day changes; completed tasks leave upcoming commitments. Changing planning zones changes the selected calendar day without rewriting stored deadlines or historical priority dates.

Today commitments project the original active, unfinished tasks with deadlines or targets, sorted by the internal target when present, otherwise by the official deadline boundary. Deadline and target labels stay distinct. Classes and work blocks are not fabricated before their phases. Start opens the task’s saved next action/preparation area. It does not start a timer, change task status or award work credit.

Date-only deadlines become overdue at the exclusive next-local-midnight boundary in their stored IANA zone. Timed deadlines become overdue after their UTC instant. The injectable workflow clock refreshes displayed classifications once per second while observed and immediately on application resume; clock jumps and planning-zone changes recalculate from saved values. No midnight database rewrite or duplicate deadline record is needed.

Editors accept ISO calendar dates and 24-hour local times with explicit zone fields. Invalid dates and DST-skipped/repeated local times are rejected with text retained; enter an unambiguous UTC instant for a repeated-hour choice. UTC is explicitly supported. Unchanged timed values retain exact seconds/milliseconds even when only minute precision is displayed. A target must precede the end of a date-only deadline and may equal a timed deadline. Clearing both target fields removes it.

Task drafts survive in-app navigation, record switches and responsive resizing in transient per-record buffers. They are not guaranteed across application termination; committed records are durable. Validation/storage failures retain input and expose retry. Capture/edit inputs pause while their save is pending, preventing a later keystroke from being cleared or incorrectly reported as saved. Common fields appear first, optional planning fields expand on demand. Search includes title, description and next action; To do/Doing, Completed, Archived and Trash are separate list views.

### Phase 5 notes and relationships

Notes may have an empty title and body. Titles allow up to 200 Unicode code points; bodies allow up to 100,000, measured consistently with the database character limit. The title is preserved as written; an empty/whitespace-only title displays as Untitled note. No rich text or attachments are stored.

Each opened note has one transient text/selection buffer and one serialized autosave writer. After approximately 500 ms without an edit, the latest title/body/course/pin snapshot is saved through the existing repository. Explicit Save and Ctrl+S flush immediately. Edits remain possible during an in-flight write; newer revisions are saved afterward, and an older completion cannot mark newer text Saved. Database echoes do not replace the open buffer or its selection.

Unsaved changes, Saving, Saved on this device and Couldn’t save have distinct states. Saved means the exact latest revision committed to SQLite. Failed saves retain all text and expose Retry and Copy draft. Over-limit input is retained for copying/shortening, never silently truncated. An existing buffer stays visible and copyable if its note query fails. Notes query failures are shown immediately with explicit Retry.

Navigation flushes the note being left; inactive/paused lifecycle events request a best-effort flush of open drafts. This listener lives outside paused page subtrees. Failed navigation flushes keep the buffer and expose a shell recovery notice linking back to that same note. The notice remains outside the storage gate with Copy draft available even when database opening fails. Committed text survives restart. Text still waiting in the debounce interval, an unfinished write, or a failed draft is held in memory and is not guaranteed across abrupt termination; no second persistent note store is introduced.

The library searches title and body in native SQLite using parameterized literal substring matching, suitable for the expected personal dataset. Percent signs, underscores and quotes have no wildcard/query meaning. Standard SQLite LOWER provides ASCII case-insensitivity; other Unicode text matches literally. Pinned notes sort first, then latest update and stable ID. Trash is a separate filter, with restore of the original record.

Trash flushes a pending draft before changing the tombstone; a failed flush leaves the note active and recoverable. Task-note links remain unique UUID-backed associations between original records, never note copies. A note may link to several tasks; both entry points open the same note ID and buffer. Deleted tasks and trashed notes remain identifiable through retained relationships. Unlink removes only the association. Course assignment is optional; current archived/deleted course associations remain visible and preserved.

Android uses a focused editor. Windows splits library/editor from 1000 logical pixels; narrower windows use the focused flow. Text, selection and controller identity survive resizing and theme changes. Organization and relationship selectors remain below the writing area.

### Phase 6 courses and activities

Courses have a required name (1–200 Unicode code points), optional color label and inclusive term bounds. Editing term bounds cannot exclude existing linked series, including retained history. Archiving is reversible and preserves tasks, notes and scheduled meetings. Tasks and notes remain usable without a course.

Activities are one-off or weekly, with a nonempty weekday selection for weekly series, inclusive start/end dates, local 24-hour times, explicit IANA zone, location, busy/free state and optional next-day ending. Duration must be positive. A course-bound series must fit its course term. Timetable generation expands only requested ranges, at most 366 days, including overnight and moved-in occurrences. Windows presents seven day columns with horizontal scrolling; Android presents one day. The planning preference controls timetable display dates/times; details retain the activity's zone.

Occurrence identity is the series UUID plus original scheduled local date. Cancellation, restoring cancellation, rescheduling and resetting an exception preserve that identity and every note link. Rescheduling can cross term bounds without rewriting the original series. A cancelled meeting remains visibly labelled. Busy overlaps are warnings, not prohibitions: editors require explicit acknowledgement to save a detected conflict. Creation/replacement previews check the first 14 days; the timetable checks every viewed range and rescheduling checks its actual destination interval.

Recurrence resolves local times using the zone's offset transitions. A gap shifts forward by its actual size; when the start is in a gap, the entire meeting shifts by that amount to preserve intended wall duration. An ambiguous time selects the first chronological occurrence (earlier instant). Adjustments are labelled in previews/details/timetable. These schedule rules are separate from the stricter task deadline input policy.

“This and future” creates a new series in one transaction and marks the old series superseded from the chosen original date. Original schedule fields remain intact. The preview names future exceptions and linked notes, and explicitly retains them on the old series: no reassignment or copied notes. A stale preview is refused. Past original meetings and affected rescheduled meetings that have already started cannot be replaced. Superseded occurrences remain available through original links and the retained-series disclosure, with schedule changes disabled. Notes can link to the whole series or a specific original occurrence; each pair/scope is unique, including whole-series links.

Course/activity forms use explicit Save/Ctrl+S; activity creation/replacement requires Preview first. Validation/write failures preserve input for retry. Drafts and selections survive resizing; committed records survive restart. These transient form buffers are not promised after closing a form or process. No external calendar, arbitrary recurrence syntax, timers or work blocks are included.

### Phase 7 unified calendar and manual planning

Plan defaults to Agenda on Android and Week on Windows, with accessible Agenda/Day/Week choices. Agenda covers seven days starting on the viewed date; Week starts Monday; Day shows one date. Date navigation and filters are transient and survive layout changes. Windows uses a selected-item panel at wide widths; narrow layouts use focused detail forms. Timetable & courses retains the Phase 6 tools and original schedule routes.

Calendar entries are derived from original tasks, activity occurrences and PlannedWorkBlock rows, never stored calendar copies. Deadlines, internal targets, classes and work have distinct text/icons. Timed entries use the display planning zone and half-open range boundaries. Date-only deadlines stay on their written calendar date and show their applicable zone, even when the display zone differs. An overnight interval may appear in both day columns while retaining one identity. A moved class appears at its effective time once; its original slot is absent. Cancelled classes/work are hidden unless explicitly included.

Filters select entry types, course, cancelled records and completed tasks/work. Trashed/archived task deadlines and associated work are hidden; their underlying work records remain available through retained IDs and reappear after task restoration. Course archiving does not remove classes or linked tasks/notes. Completed work describes a plan status only and never completes a task, awards focus credit or reduces an estimate.

Schema 6 adds PlannedWorkBlock with UUID, task foreign key, UTC start/end, validated IANA planning zone, planned/completed/cancelled status, manually locked flag and audit/soft-deletion timestamps. SQL enforces positive integer-millisecond duration, valid statuses and relationships. The additive 5→6 migration preserves all 11 earlier tables and supports the existing earlier upgrade chain. No reset fallback exists.

Work forms support task selection, local start date/time/zone, 25/50/90-minute presets and custom elapsed lengths of 1–1440 minutes. Start parsing rejects skipped/repeated wall times; choose an unambiguous time or UTC. Unchanged saved instants retain sub-minute precision. Locks reserve plans for future automatic tools; explicit manual editing remains possible. Remove is reversible through Restore on the retained detail. Forms expose validation/write errors, retain fields and provide Retry. Save/Ctrl+S commit before navigation.

Saving a planned block checks current visible busy classes and other planned blocks, excluding itself. Exclusive end/start edges do not overlap. A conflict requires explicit acknowledgement but never prohibits a deliberate reservation. Calendar overlap labels describe visible entries and respect filters. Manual moves update only the block: official deadline, internal target and remaining estimate stay unchanged. Task source opening offers the existing optional estimate/target fields without requiring them.

watchReminderReconciliationInputs and its provider expose a consistent full source snapshot initially and after committed changes to tasks, work blocks, activities, exceptions or courses. Consumers must reconcile desired reminders idempotently from current state, including tombstones and cancellations. Emissions may coalesce; they are not a per-operation event log. No notification scheduling is performed in this phase. There is no automatic allocation or replanning.

## Phase 9 starting, focus and review

Today Start and the task's Prepare a two-minute start button open setup. Setup uses the saved next action or a selected incomplete subtask; without either, opening the task and finding one small first step is sufficient. No timer starts on navigation. Only Start for 2 minutes starts the 120-second starter. Optional suggestions are short and supportive. General or task-linked focus supports 10/25/50-minute choices, a custom 1–180-minute length, and explicit Start. Break setup uses the saved break default and allows 1–60 minutes.

The active screen shows the engine's countdown projection, Pause/Resume, Add 5 minutes for focus/break within engine limits, and End and review. A one-second display timer neither measures nor persists time and is muted off-screen/paused; the engine remains installation-owned with its tested checkpoints. Countdown seconds are excluded from automatic screen-reader announcements. The footer shows actual running/paused/review state across destinations, or an honest opening/save problem with access to recovery. Opening a linked task or its original notes leaves the session intact.

Review shows intended/elapsed/eligible/uncertain time and requires a whole-second reported amount (zero allowed) plus explicit confirmation before finalization/history. Failure retains inputs and the last confirmed state. After a saved starter review, offer Continue 10, Continue 25, Custom focus, explicit Mark step done when available, or Stop here. Continue starts a separate distinguishable focus record only when pressed. A completed/removed step is not carried into new work; deleted, archived or completed tasks cannot start another linked session. Focus/starter reviews offer optional break setup; opening it does not start a break.

Task completion through either task control first ends a linked running/paused session through the existing engine, completes the task explicitly, and opens the still-uncredited session review. Repository status changes also refuse completion while a linked session is running/paused, closing race/bypass paths. Review/finalization never completes a task or subtask. An unfinished session must be reviewed before another can start; setup explains this and provides Return to session.

Recovered sessions open an honest interrupted review, never auto-resume or automatically credit work. Recent sessions lists the latest 20 finalized original records, with kind, title snapshot, local start date/zone and confirmed work; reopening one shows the same record. This is basic review history, not Phase 11 summaries, corrections or reflections. Navigation, resizing and theme changes preserve a mounted setup/review's controllers. All timer state remains in schema 7; no new persistence, dependency or calculation engine is introduced.

## Timer contract (Phases 8–9)

Phase 8 implements the engine and explicitly labelled development controls only. Schema 7 adds FocusSession, ordered FocusSegment and durable TimerCommandReceipt rows without changing previous records. A partial unique installation index permits one running, paused or awaiting-review session. Start stores the task-title snapshot, optional task/subtask IDs, explicit zone and local start date. A selected subtask must belong to that task. UUID command receipts make retries safe even when a commit succeeded but its response was lost.

Starter lasts exactly 120 seconds and cannot be extended; review it before starting a separate focus session. Focus supports 1–180 minutes in total, including extensions; breaks use the existing 1–60-minute setting range. Explicit extension may continue an expired completed interval from now, without counting time spent on its review screen. Interrupted or deliberately stopped intervals must be finalized before starting another session.

Timing policy is conservative: an elapsed counter moving backward, wall/elapsed disagreement greater than two seconds, a background interval, or a checkpoint gap greater than 15 seconds flags uncertainty. Known foreground intervals are eligible; uncertain intervals are retained and displayed but excluded from reportable work. The five-second checkpoint loop runs only for running/paused sessions. During pauses, neither elapsed work nor eligible work grows; breaks never provide eligible work. Each segment retains raw wall endpoints plus separately validated nonnegative durations, so clock reversals are diagnosable.

Any persisted running/paused session opens as interrupted/awaitingReview in a new process. Recovery bounds a positive restart wall gap by the remaining intended duration and adds it only to uncertainty. No automatic resume or credit occurs, including after reboot. Finalization requires explicit confirmation and an amount from zero through eligible elapsed time; repeating it with the same amount is idempotent and a conflicting amount is refused. No timer command updates task/subtask completion, remaining estimate, deadlines or work blocks. The final Today/footer session controls, polished review journey and notifications remain later phases.

States: running, paused, awaitingReview, finalized. Outcome is separate: interval completed, stopped early, interrupted. Kinds: starter, focus, break. Countdown expiry does not complete a step/task or prove attention.

Use an injectable elapsed clock during execution, persisted UTC timestamps/checkpoints and intended duration. UI ticks repaint; they do not measure time. Persist start/pause/resume/extend/finish and checkpoint approximately every five seconds. Exclude pause/break time. Stop accumulation at intended expiry unless explicitly extended. Identify background/restart gaps and significant clock disagreement. Do not rely on lifecycle close callbacks being delivered.

Changing screens retains the session. Minimize/lock/background may let countdown continue but does not establish work. Sleep/process termination recovers with uncertainty. Reboot never automatically resumes work. Late notification delivery does not extend elapsed time. Double finish is idempotent. A second start must resolve the existing unfinished session.

Review intended/elapsed/uncertain intervals and explicitly confirm eligible reported work. Credit must be nonnegative and bounded by eligible elapsed work. Break credit is zero. Subtask and task completion remain separate explicit actions. MVP summaries group sessions by stored local start date, including sessions crossing midnight; explain this in details.

## Recurrence and temporal contract (Phase 6)

Use local wall times plus IANA zone for schedules, UTC for actual instants, calendar-date types for date-only values. Detect the device zone separately from loading timezone data; Asia/Manila is the user's initial suggested zone. Travel changes display context, not the intended course zone.

Occurrence identity is series ID + original local date, including a moved occurrence. Exceptions cancel or override the original date/time/location. Generate only requested date ranges. Different meeting times use separate series. Overnight is explicit with end-day offset.

For DST gaps, move forward by the gap and flag the adjustment; ambiguous times choose the earlier offset consistently and expose it. One-occurrence edits produce exceptions. This-and-future edits split the series; preserve history. Preview existing future note/exception relationships, retaining superseded records rather than silently reassigning notes to other dates.

## Reminder contract (Phase 10)

Rules and native registrations are distinct. A reconciler derives desired triggers, cancels obsolete ones, schedules changes and records retryable failures. Native scheduling is not part of the SQLite transaction. Failed scheduling must not discard a saved task.

Opt-in; initially one rule per item; proposed quiet hours 22:00–07:00. Respect OS notification settings and Do Not Disturb. Timer endpoints have separate controls. No reminder flood on return. Recurrence expands into individual triggers across a rolling 30-day window, initially 128 pending registrations with a timer slot reserved. Show actual scheduled-through date if capacity truncates the horizon.

Android notification permission and exact-alarm access differ. Inexact fallback is allowed and described. Windows repeating operations/package identity differ; installed package behavior must be tested. Extended Windows off-time can drop an alert, so show relevant missed commitments in-app. Registered is not delivered/seen. Source callbacks re-read records.

Phase 10 implementation: Settings → Reminders owns global opt-in, individual deadline/activity/work rules and one installation-wide timer rule. Reading the app or opening this screen never requests permission. Enable asks for Android notification permission; a separate optional action requests exact-alarm access. Denied/revoked access, approximate timing, unavailable Windows package identity, scheduling/cancellation errors and retry remain visible. No new dependency, cloud push or secondary source storage is introduced.

Date-only deadline alerts default to 09:00 in the deadline's saved zone, not its end-exclusive overdue boundary. Timed deadlines and work use their source instant. Activity rules retain series/original-date identity through moves and expand only the requested horizon including lead time (0–10080 minutes). Completed/archived/trashed tasks, cancelled work and cancelled/superseded occurrences produce no new triggers. Archiving a course retains active linked records. Timer endpoints follow the existing engine's remaining duration, rounded up to a second to avoid checkpoint jitter; paused, finalized and stopped sessions do not schedule. No notification completes, extends, resumes or credits work.

Quiet hours default to 22:00–07:00 in the explicit planning zone. General alerts inside quiet hours move to quiet-hours end only if no later than their source time; otherwise they are suppressed. Quiet timer endpoints and tests are suppressed. DST uses the existing gap/fold policy. Normal OS channel/access settings and Do Not Disturb apply without bypass. Written source zones stay fixed when planning/display zone changes.

Reconcile after committed source/rule/preferences/session changes, launch, resume/status refresh and every 15 minutes while enabled and the process runs. Expand 30 days; keep at most 127 general pending triggers plus one timer trigger, including retained late approximate triggers. A current registered alert can stay pending up to one hour after due for approximate delivery; never re-register past triggers. Capacity and cancellation failures reduce coverage rather than permit overflow. Display latest confirmed future trigger as actual scheduled-through and checked source horizon separately. Neither promises delivery. Elapsed/opening-unconfirmed entries remain available in-app; never replay overdue alerts or infer seen/delivered from registration.

The pinned Android package restores cached individual triggers on supported boot/package-replaced broadcasts. Full SQLite reconciliation/horizon expansion runs on next launch/resume; no always-running background Dart worker exists. After more than 30 days closed, reopen to refresh. Explicit planning-zone edits reconcile immediately; device-zone changes are checked on return but do not rewrite explicit source zones. Windows uses individual triggers/cancellations under installed package identity. Extended powered-off/suspended-device recovery remains OS-limited and needs device observation. Payloads contain only registration UUIDs; opening re-reads current rules/sources/session state, routes to the original record, then records opened time. Scheduling alone never marks an alert opened.

## Backup contract (Phase 12)

Implemented through Settings → Data, export and replacement restore. Format 1/schema 10 uses a strict 16-section payload and exact counts, with canonical payload SHA-256; see BACKUP_FORMAT.md. Validation returns an inspectable preview before any replacement. Native save success and cancellation are distinct results. Unencrypted personal content is explained before Export and Replace.

Three private SQLite recovery snapshots are required before replacement/migration; the latest three completed operations survive clock rollback. They preserve exact same-device state and are distinct from portable JSON, which excludes installation identity, native registrations and execution/retry caches. Recovery previews use a temporary copy. A snapshot failure aborts before mutation. Source schema 1–9 upgrades retain a pre-DDL snapshot; future incompatible databases are preserved and refused.

Current unfinished sessions block replacement until explicit review/finalization, and unsaved note failures block it without discarding the buffer. After commit, imported unfinished sessions are interrupted reviews, editors are remounted, and reminder cleanup/scheduling failures are shown separately. Native cancellation intent survives restart even after old source IDs are removed. The receiving installation, settings identity, global reminder opt-in and OS permission remain local. No merge, sync, upload or encryption is implied.

Export domain records/links/history and portable settings as one versioned JSON file with format/schema compatibility, UTC export timestamp, record counts and SHA-256. Exclude installation identity, notification registrations, credentials, caches and transient state. Checksum detects corruption, not encryption/authentication. MVP database/export are not application-encrypted.

Validate before mutation: initially <=50 MiB, <=200,000 records, valid IDs/enums/lengths/dates/durations/references. Preview counts/date and explain replacement, not merging/sync. Resolve a running session, create a recovery snapshot, then replace domain data in one transaction and roll back on failure. Exported unfinished sessions restore interrupted/awaiting review, never running. Regenerate native reminders after commit and report failures separately. Keep three recovery snapshots; they are not protection from device loss. Test both transfer directions.

## Version 2 deadline planner (Phases 15–16)

Inputs: remaining estimate, default 25% margin, official due instant, optional earlier target, work windows, busy classes/activities, accepted/locked blocks, preferred 25-minute work block, daily cap. Planning minutes = remaining estimate * (1 + margin).

Bound the horizon, subtract busy intervals/breaks/buffers, allocate backwards from target/deadline. Suggested start is the earliest allocation; also offer a tiny starter today. Multiple tasks sort by earliest deadline, priority, stable creation order and consume shared capacity. Preserve locked/past/completed blocks. Return proposals without writes; preview and explicitly accept transactionally with idempotent proposal ID. Reject stale previews when source inputs changed.

Missing time is a quantified shortfall, not an application error. Missed work blocks are missed opportunities, not proof of no work. Replan future blocks only after acceptance. Never silently change official due dates or subtract timer minutes from remaining effort. Add local editable subtask templates and month calendar overview in Phase 16.

## Adaptive UI baseline

Android primary destinations: Today, Tasks, Plan, Notes. Progress/Settings in menu; focus via Start/active-session control. Desktop sidebar includes Progress/Settings. Plan contains Calendar/Timetable. Proposed final breakpoints are <600 single pane, 600–999 rail, >=1000 sidebar/detail; Phase 1 uses a simpler 760-pixel shell transition to verify native navigation, refined in Phase 3.

Major screens: Welcome; Today; task list/detail; starter setup; Focus; session review/recovery; notes library/editor; calendar; timetable; course/activity editor; deadline planner; Progress; Settings; backup/restore. Mobile uses readable single-screen flows; desktop uses purposeful lists/details and agenda panels. No stretched phone-only desktop design.

Neutral surfaces/charcoal dark theme, restrained teal, system typography, 4/8/12/16/24/32 spacing baseline, readable ~16 body text, primary touch targets >=48. Short interruptible motion around 150–220ms with reduced-motion alternatives. Keyboard focus, semantic labels, 200% text and non-color-only statuses. Do not announce every timer second. Shortcuts in later phases: context Ctrl+N, search Ctrl+K, Save Ctrl+S, safe Esc.

Every data screen distinguishes loading, empty, no results, failure and retry; preserve existing content/drafts during refresh/failure. Static screens need no fake loading. Confirm only genuinely destructive operations; otherwise provide undo/restore.

## Quality/release acceptance

Phase 14 establishes version 1.0.0, release build 2, with build 1 reserved as an older signed update fixture. Android retains dev.momentum.app and now requires the private release key; direct release compilation is unsigned rather than silently using the scaffold debug key. The pre-release debug-signed phone preview cannot receive this differently signed APK in place. Preserve it and its data until a user-reviewed backup-first migration is arranged. Never uninstall automatically.

Windows private release identity is dev.momentum.private / CN=MomentumPrivate, separate from both retained development registrations. It does not automatically inherit their application-support data; use a validated portable backup to transfer data deliberately. Product notifications and package toast activation share a new stable private GUID. Settings shows version/build and a local-backup reminder. Normal release packaging uses lib/main.dart without development defines or fixture data.

Packaging signs without installing packages/certificates or changing trust. Only the public CER files are distributed; private keys and user-bound protected passwords stay in the restricted LocalAppData/MomentumSigning directory. Self-signed Windows packages require an explicit machine trust decision after inspecting the concrete artifact and public fingerprint. Installed-release verification remains pending until that prerequisite and actual device checks pass. See RELEASE.md.

Phase 13 verifies the existing MVP without changing schema 10 or portable backup format 1. Review, development timer controls and progress correction share bounded whole-second parsing: reject negative, fractional, unparsable or greater-than-eligible input **before** converting to milliseconds. The engine similarly bounds extension minutes before multiplication and retains its total-duration limit. These checks prevent native integer overflow from turning invalid large entries into small accepted values. Failed validation retains the draft and leaves the session unchanged. Persisted credit and elapsed calculations are unchanged; existing records are not reinterpreted.

Android retains allowBackup=false/fullBackupContent=false and explicitly excludes credential/device-protected app storage from cloud-backup and device-transfer. Manual JSON transfer remains deliberate. Windows/system backup settings and OEM enforcement are distinct from application networking/privacy promises. Measurements and physical-device limits in VERIFICATION.md are observations, not minimum hardware requirements.

Targets to measure (not claims): <3s cold start and <300ms ordinary local searches on recorded reference hardware/datasets. Keep database/backup work off the input path. No automatic uploads or remote resources. Review platform OS backup config; no application encryption promise. Never clear a database to repair migrations.

Verify domain rules, repositories, constraints/transactions, fixture-based schema migrations, widgets/accessibility and integrated journeys. Separately verify physical Android, emulator, Windows executable and installed MSIX. Release acceptance requires fresh install, native dialogs/notifications, restart recovery, backup transfer and a data-preserving signed update. A successful build alone is insufficient.

MVP exclusions: account/backend/sync/AI, public publishing, payments, external calendar sync, app blocking, rich media notes and advanced recurrence. Optional future sync is record-level with stable IDs, versions, tombstones, outbox/acknowledgements, device-owned unfinished sessions and lossless note-conflict copies; never sync the live SQLite file. No backend is selected.
