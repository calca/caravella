# Caravella Developer Wiki

Technical documentation for the Caravella codebase, reverse-engineered from the current source (not from feature-announcement notes) so it reflects what the code actually does. Start at [Architecture Overview](ARCHITECTURE.md) if you're new here.

If you're about to change code and aren't sure which page(s) to update afterward, check the [documentation maintenance guide](MAINTAINING_DOCS.md) — **every PR that changes documented behavior should update the relevant page(s) in the same PR.**

## Start here

- **[Architecture Overview](ARCHITECTURE.md)** — package structure, dependency rules, app startup sequence, state management, feature map

## Packages

- **[caravella_core](PACKAGE_CARAVELLA_CORE.md)** — business logic, data models, storage, cross-cutting services
- **[caravella_core_ui](PACKAGE_CARAVELLA_CORE_UI.md)** — shared widgets, themes, map building blocks
- **[android_app_functions](PACKAGE_ANDROID_APP_FUNCTIONS.md)** — Android AI-agent/shortcut integration
- **[play_store_updates](PACKAGE_PLAY_STORE_UPDATES.md)** — Google Play in-app update integration (conditional)
- **[google_drive_sync](PACKAGE_GOOGLE_DRIVE_SYNC.md)** — Google Drive cloud relay for the sync feature (conditional), see also the [setup guide](GOOGLE_DRIVE_SYNC_SETUP.md)

## App features (`lib/`)

- **[Home](APP_HOME.md)** — home screen, cards, search, startup wiring
- **[Group Management](APP_GROUP_MANAGEMENT.md)** — creation wizard, editing, backgrounds, currencies, group types/templates
- **[Expense Entry](APP_EXPENSE_ENTRY.md)** — expense form, attachments, voice input
- **[Group Details & Stats](APP_GROUP_DETAILS_STATS.md)** — detail page, stats tabs, settlements algorithm, export
- **[History & Search](APP_HISTORY_SEARCH.md)** — active/archived groups list, cross-group search
- **[Settings](APP_SETTINGS.md)** — settings hub, backup/restore, templates, what's new

## Cross-cutting features

- **[Storage Backend](STORAGE_BACKEND.md)** — SQLite vs. JSON, schema, migration
- **[Receipt OCR](RECEIPT_OCR.md)** — on-device receipt scanning
- **[Notifications](NOTIFICATIONS.md)** — persistent date-range-aware notifications
- **[Location & Maps](LOCATION_AND_MAPS.md)** — GPS capture vs. interactive place search, map rendering
- **[Android 15+ System Bar Handling](ANDROID_15_FIX.md)** — edge-to-edge, transparent system bars

## Build & distribution

- **[Build Variants & Flavors](BUILD_VARIANTS.md)** — dev/staging/prod, every dart-define flag
- **[CI Pipelines](CI_PIPELINES.md)** — what GitHub Actions actually runs
- **[F-Droid Submission](FDROID_SUBMISSION.md)** — F-Droid-specific packaging notes

## Meta

- **[Keeping This Documentation Current](MAINTAINING_DOCS.md)** — the policy and code-area → page map that keeps this wiki from going stale again

## Related, non-wiki docs

- Root [`CLAUDE.md`](../CLAUDE.md) / [`.github/copilot-instructions.md`](../.github/copilot-instructions.md) — AI-agent working instructions and command reference
- [`CHANGELOG.md`](../CHANGELOG.md) — user-facing release history
- [`store/PRIVACY_POLICY.md`](../store/PRIVACY_POLICY.md), [`store/permissions_documentation.md`](../store/permissions_documentation.md) — store-facing privacy/permissions docs
