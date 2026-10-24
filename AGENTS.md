# Momentum contributor instructions

- Work only on the requested scope. Preserve the offline Android/Windows design and existing data semantics; no cloud service or Version 2 features without explicit authorization.
- Read docs/SPEC.md, ARCHITECTURE.md, BACKUP_FORMAT.md and VERIFICATION.md before changing the affected feature.
- Native SQLite is the durable source of truth. Never reset/delete a database to solve an opening/migration failure. Keep frozen schema snapshots and migration fixtures.
- Keep keys, credentials, environment files, local SDK configuration, databases and raw device evidence out of Git. Use synthetic test fixtures only.
- Keep package identities/signing stable. Never automatically install certificates or change system trust. Stable/store releases require installed acceptance and owner authorization; explicitly authorized previews must clearly disclose pending checks.
- Use the smallest complete change. Preserve validation, errors, accessibility and saved drafts. Avoid speculative dependencies/features.
- Run formatting, analysis and relevant tests. Use --concurrency=1 on an 8 GB laptop; keep native builds sequential. Distinguish simulated tests from observed installed behavior.
