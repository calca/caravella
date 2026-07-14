# App: Settings

Covers `lib/settings/**`.

## Settings hub

`settings_page.dart` (`SettingsPage`) wraps its content in a local `MultiProvider` for `FlagSecureNotifier` and `AppFunctionsEnabledNotifier`, organized into sections (`SettingsSection`/`SettingsCard`, `widgets/`):

- **General** — username dialog, language picker (it/en/es/pt/zh), dynamic-color switch, theme picker (light/dark/system).
- **Personalization** — link to `GroupTypeTemplatesPage`.
- **Privacy** (Android-only) — FLAG_SECURE switch (`FlagSecureAndroid.setFlagSecure`, see `flag_secure_android.dart`), and the App Functions enable switch (gates [android_app_functions](PACKAGE_ANDROID_APP_FUNCTIONS.md)'s `onAddExpense`).
- **Data** — link to `DataBackupPage`.
- **Info** — link to `DeveloperPage`; app version → `WhatsNewPage`; a "Debug Logs" row (only in debug builds or when `AppConfig.enableTalkerScreen`) opening `TalkerScreen(talker: LoggerService.instance)`.

## Backup & restore

`data_backup_page.dart` (`DataBackupPage`):

- **Auto Backup** toggle — backed by `AutoBackupNotifier` (`caravella_core`), which itself talks to the platform via `BackupService` (see [caravella_core reference](PACKAGE_CARAVELLA_CORE.md)).
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

`whats_new_page.dart` (`WhatsNewPage`) loads a locale-specific changelog asset (`assets/docs/CHANGELOG_<lang>.md`, falling back to English) and renders it with `gpt_markdown`. On Android, also embeds `UpdateCheckWidget` from `play_store_updates` for a manual "check for updates" card — see [play_store_updates package](PACKAGE_PLAY_STORE_UPDATES.md).

## Update localization adapter

`update/app_update_localizations.dart` (`AppUpdateLocalizations implements UpdateLocalizations`) maps the app's generated `gen.AppLocalizations` strings onto the interface required by `play_store_updates`, used both by `HomePage`'s automatic check and `WhatsNewPage`'s manual widget.

## See also

- [caravella_core reference](PACKAGE_CARAVELLA_CORE.md)
- [play_store_updates package](PACKAGE_PLAY_STORE_UPDATES.md)
- [android_app_functions package](PACKAGE_ANDROID_APP_FUNCTIONS.md)
- [Storage Backend](STORAGE_BACKEND.md) — what backup/restore actually persists
