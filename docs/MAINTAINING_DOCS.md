# Keeping This Documentation Current

This wiki (`docs/`) was rewritten from a full read of the source in 2026-07 after the previous version had drifted badly out of date (stale folder paths, dependency lists, version numbers, and at least one described feature that had since moved to a different package entirely). The goal of this page is to stop that from happening again.

## The rule

**If your change alters something a doc page describes, update that page in the same PR.** Doc updates are not a follow-up task — a PR that changes behavior a doc describes and doesn't touch the doc is incomplete, the same way a PR that changes a public API without updating its tests is incomplete.

This applies to both directions:
- Code changed, doc now wrong → fix the doc.
- You read a doc page and noticed it was already wrong before your change → fix it anyway while you're there; don't leave it for later.

## Where to look: code area → doc page

| If you changed... | Update... |
|---|---|
| `packages/caravella_core/lib/data/**` (repositories, factory, migration, `ExpenseGroupStorageV2`) | [STORAGE_BACKEND.md](STORAGE_BACKEND.md), [PACKAGE_CARAVELLA_CORE.md](PACKAGE_CARAVELLA_CORE.md) |
| `packages/caravella_core/lib/model/**` | [PACKAGE_CARAVELLA_CORE.md](PACKAGE_CARAVELLA_CORE.md) |
| `packages/caravella_core/lib/state/**` | [PACKAGE_CARAVELLA_CORE.md](PACKAGE_CARAVELLA_CORE.md), [ARCHITECTURE.md](ARCHITECTURE.md) |
| `packages/caravella_core/lib/services/**` | [PACKAGE_CARAVELLA_CORE.md](PACKAGE_CARAVELLA_CORE.md) |
| `packages/caravella_core/lib/model/group_settlements.dart` | [APP_GROUP_DETAILS_STATS.md](APP_GROUP_DETAILS_STATS.md#settlements-algorithm) |
| `packages/caravella_core_ui/lib/**` (widgets, themes, map) | [PACKAGE_CARAVELLA_CORE_UI.md](PACKAGE_CARAVELLA_CORE_UI.md), and [LOCATION_AND_MAPS.md](LOCATION_AND_MAPS.md) for `map/` |
| `packages/android_app_functions/lib/**` + native Kotlin under `android/.../appfunctions/` | [PACKAGE_ANDROID_APP_FUNCTIONS.md](PACKAGE_ANDROID_APP_FUNCTIONS.md) |
| `packages/play_store_updates/lib/**` | [PACKAGE_PLAY_STORE_UPDATES.md](PACKAGE_PLAY_STORE_UPDATES.md) |
| `packages/google_drive_sync/lib/**` | [PACKAGE_GOOGLE_DRIVE_SYNC.md](PACKAGE_GOOGLE_DRIVE_SYNC.md), [GOOGLE_DRIVE_SYNC_SETUP.md](GOOGLE_DRIVE_SYNC_SETUP.md) |
| `packages/caravella_core/lib/sync/**`, `lib/sync/**` | [SYNC_ARCHITECTURE.md](SYNC_ARCHITECTURE.md), [PACKAGE_GOOGLE_DRIVE_SYNC.md](PACKAGE_GOOGLE_DRIVE_SYNC.md) |
| `lib/main.dart`, `lib/main/**` | [ARCHITECTURE.md](ARCHITECTURE.md) |
| `lib/home/**` | [APP_HOME.md](APP_HOME.md) |
| `lib/manager/group/**` | [APP_GROUP_MANAGEMENT.md](APP_GROUP_MANAGEMENT.md) |
| `lib/manager/expense/**` (excluding `location/`) | [APP_EXPENSE_ENTRY.md](APP_EXPENSE_ENTRY.md) |
| `lib/manager/expense/location/**` | [LOCATION_AND_MAPS.md](LOCATION_AND_MAPS.md) |
| `lib/manager/details/**` | [APP_GROUP_DETAILS_STATS.md](APP_GROUP_DETAILS_STATS.md) |
| `lib/manager/history/**` | [APP_HISTORY_SEARCH.md](APP_HISTORY_SEARCH.md) |
| `lib/settings/**` | [APP_SETTINGS.md](APP_SETTINGS.md) |
| `lib/services/notification_*.dart` | [NOTIFICATIONS.md](NOTIFICATIONS.md) |
| `lib/services/receipt_scanner_service.dart` | [RECEIPT_OCR.md](RECEIPT_OCR.md) |
| Any new/changed `--dart-define` flag | [BUILD_VARIANTS.md](BUILD_VARIANTS.md) — add/update its table row |
| `android/app/build.gradle.kts`, flavor config | [BUILD_VARIANTS.md](BUILD_VARIANTS.md) |
| `.github/workflows/*.yml` | [CI_PIPELINES.md](CI_PIPELINES.md) |
| `metadata.yml`, `fastlane/metadata/**` | [FDROID_SUBMISSION.md](FDROID_SUBMISSION.md) |
| New local package, or a change to what depends on what | [ARCHITECTURE.md](ARCHITECTURE.md#package-dependency-rules) |

If a change doesn't fit any row above, it's most likely too small to need a doc update (e.g. a one-line bugfix with no behavioral/structural change) — use judgment, don't pad these pages.

## Writing style for this wiki

Follow these rules so pages stay accurate for as long as possible instead of rotting the way the old `docs/` did:

1. **Cite file paths, not vibes.** Every claim should be traceable to a real file/class/method. If you're not looking at the code while writing the sentence, don't write it.
2. **Don't hardcode volatile facts.** No app version numbers, build numbers, dependency version pins, or "current as of" dates in prose — these are wrong within weeks. Point at the authoritative source instead (`pubspec.yaml`, `metadata.yml`, the workflow YAML) the way [FDROID_SUBMISSION.md](FDROID_SUBMISSION.md) and [CI_PIPELINES.md](CI_PIPELINES.md) do.
3. **Link liberally.** Every page ends with a "See also" section. When you mention a concept documented elsewhere, link to it instead of re-explaining it — duplicated explanations are exactly what goes out of sync.
4. **Flag known-stale or dead code explicitly** rather than silently describing intended behavior — e.g. [APP_GROUP_DETAILS_STATS.md](APP_GROUP_DETAILS_STATS.md) calls out `overview_stats_logic.dart` as dead code and a naming typo (`ExpesensHistoryPage`) is called out in [APP_HISTORY_SEARCH.md](APP_HISTORY_SEARCH.md) rather than "corrected" silently, so a reader isn't confused when they see the real file name.
5. **One page, one area.** If a page is growing to cover unrelated concerns, split it and link the two halves rather than letting it sprawl (this is why location/maps and receipt OCR are their own pages instead of being folded into expense entry).
6. **New pages get added to the index.** Any new `docs/*.md` file must be added to [README.md](README.md) and, if it maps to a code area, to the table above.

## Regenerating from scratch

If this wiki drifts badly again (large refactors, long periods without doc updates), the fastest way back to accuracy is the approach used to write it the first time: read the actual source package-by-package and feature-by-feature (not just filenames — open the files), and rewrite rather than patch. Patching a badly-stale doc tends to preserve its wrong assumptions; a fresh read against current code does not.

## See also

- [Documentation Home](README.md)
- [Architecture Overview](ARCHITECTURE.md)
