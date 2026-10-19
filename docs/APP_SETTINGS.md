# App: Settings

Covers `lib/settings/**`.

## Settings hub

`settings_page.dart` (`SettingsPage`) wraps its content in a local `MultiProvider` for `FlagSecureNotifier` and `AppFunctionsEnabledNotifier`. It uses the shared settings layout from `caravella_core_ui` (`SettingsScaffold` + `SettingsProfileCard` + `SettingsGroup`/`SettingsTile`, the same as the group settings page — see [Group Details § Group settings](APP_GROUP_DETAILS_STATS.md#group-settings)): eyebrow "Caravella", large "Settings" title, then

- `UserProfileCard` (`widgets/general_settings_section.dart`) — the user's name (or a prompt), tap opens the name dialog (`GeneralSettingsSection.showNameDialog`).
- **General** — Appearance (`AppearanceSettingsPage`: language, theme, dynamic color).
- **Data** — Sync (`SyncSettingsScreen`, when the orchestrator exists), Backup & restore (`DataBackupPage`), group type templates (`GroupTypeTemplatesPage`).
- **Privacy** (Android-only) — FLAG_SECURE switch (`FlagSecureAndroid.setFlagSecure`, see `flag_secure_android.dart`), and the App Functions enable switch (gates [android_app_functions](PACKAGE_ANDROID_APP_FUNCTIONS.md)'s `onAddExpense`).
- **Info** — invite friends (share), `DeveloperPage`, app version → `WhatsNewPage`, and a "Debug Logs" row (only in debug builds or when `AppConfig.enableTalkerScreen`) opening `TalkerScreen(talker: LoggerService.instance)`.

Icons are monochrome, in a neutral circle; toggles are `Switch`es (the whole row toggles), rows that open a page end with a chevron, external links end with an "open in new" icon. Every sub-page uses the same layout (eyebrow = where you came from, large title, optional description): Appearance (theme choice in a card, dynamic color switch, language), Backup & restore, Information (`DeveloperPage`), What's new (update check and changelog in cards), group type templates (list + add button; the template form with name, icon and categories in cards and a Save bar), and the sync pages (`SyncSettingsScreen`, `MultiUserSyncPage`, `MultiDeviceSyncPage`, `SyncHistoryPage` — channel icons instead of emoji).

## Backup & restore

`data_backup_page.dart` (`DataBackupPage`):

- **Auto Backup** toggle — backed by `AutoBackupNotifier` (`caravella_core`, see [caravella_core reference](PACKAGE_CARAVELLA_CORE.md)). Its subtitle shows "Last backup: <date, time>", "No backup yet…" or "Off…" (iOS: the plain description). On Android the switch really works through `CaravellaBackupAgent` (`android/app/src/main/kotlin/.../CaravellaBackupAgent.kt`, `android:backupAgent` + `fullBackupOnly` in the manifest): `onFullBackup` reads the Flutter pref `flutter.auto_backup_enabled` (on unless turned off). When on, it records the time (`caravella_backup_state` prefs, `last_cloud_backup_ms`) and runs the default Auto Backup (manifest `backup_rules` / `data_extraction_rules`). When off, a cloud backup carries only a `backup_off.txt` marker — an empty backup would be rejected and leave the previous one in the cloud. Device-to-device transfers always copy everything. Test with `adb shell bmgr transport com.android.localtransport/.LocalTransport` + `adb shell bmgr backupnow io.caravella.egm`.
- **Manual backup** (`_backupTrips`) — serializes `ExpenseGroupStorageV2.getAllGroups()` to JSON, zips it (`archive` package) into `caravella_backup_<timestamp>.zip`, shares it via `share_plus`.
- **Restore** (`_importTrips`) — picks a `.zip`/`.json` via `file_picker`, deserializes `ExpenseGroup.fromJson`, saves each group directly via `ExpenseGroupStorageV2.repository.saveGroup`, marks first-start as done, and notifies `ExpenseGroupNotifier.notifyGroupUpdated` per restored group.

## Developer / info page

`developer_page.dart` (`DeveloperPage`) is a static links page (buy-me-a-coffee, GitHub profile, repo, issue tracker, LICENSE) opened via `url_launcher`.

## Group type templates

- `group_type_templates_page.dart` (`GroupTypeTemplatesPage`) — lists templates via `Consumer<GroupTypeTemplatesNotifier>`, each with edit/delete (delete confirmed via `Material3Dialogs.showConfirmation`), plus an `AddFab`.
- `group_type_template_form_page.dart` (`GroupTypeTemplateFormPage`) — add/edit form (name, icon picker grid from `GroupTypeLocalization.availableIcons`, an `EditableNameList` of default categories). Saves via `notifier.upsert(...)`.
- `state/group_type_templates_notifier.dart` (`GroupTypeTemplatesNotifier extends ChangeNotifier`) wraps `GroupTypeTemplateService` (`caravella_core`): `load()` (catches `StateError` if prefs unavailable), `upsert(template)`/`delete(id)` (both call the service then reload).

These templates plug into the group-type selector during group creation — see [Group Management § group types and templates](APP_GROUP_MANAGEMENT.md#group-types-and-templates).

## What's New

`whats_new_page.dart` (`WhatsNewPage`) loads a locale-specific changelog asset (`assets/docs/CHANGELOG_<lang>.md`, falling back to English) and renders it with `gpt_markdown`. On Android, in Play builds, also embeds the manual "check for updates" card (`GmsIntegrations.instance.appUpdates?.buildUpdateCheckWidget`, i.e. `UpdateCheckWidget` from `play_store_updates`); the F-Droid build has no `appUpdates` and shows no card — see [play_store_updates package](PACKAGE_PLAY_STORE_UPDATES.md) and [caravella_gms](PACKAGE_CARAVELLA_GMS.md).

## Update localization adapter

`update/app_update_localizations.dart` (`AppUpdateLocalizations implements UpdateLocalizations`) maps the app's generated `gen.AppLocalizations` strings onto the `UpdateLocalizations` interface (`caravella_core/lib/integrations/update_localizations.dart`, consumed by `play_store_updates`), used both by `HomePage`'s automatic check and `WhatsNewPage`'s manual widget.

## See also

- [caravella_core reference](PACKAGE_CARAVELLA_CORE.md)
- [play_store_updates package](PACKAGE_PLAY_STORE_UPDATES.md)
- [android_app_functions package](PACKAGE_ANDROID_APP_FUNCTIONS.md)
- [Storage Backend](STORAGE_BACKEND.md) — what backup/restore actually persists
