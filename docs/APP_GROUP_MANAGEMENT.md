# App: Group Management

Covers `lib/manager/group/**` — group creation wizard, editing pages, background/photo picking, currencies, and group types/templates.

## `GroupFormController` — the form-state owner

`GroupFormController` (`lib/manager/group/group_form_controller.dart`) owns all group form state per the repo's contribution checklist ("controllers own form state, diff original models, and notify the global notifier after calling storage"). It wraps a `GroupFormState` (plain `ChangeNotifier`) and a `GroupEditMode` (`enum { create, edit }`, `group_edit_mode.dart`).

- `load(ExpenseGroup?)` — populates state from an existing group (edit mode) and snapshots `state.originalGroup` for diffing.
- `hasChanges` — create mode: any field non-empty; edit mode: diff every field against `originalGroup`.
- `save()` — builds a new `ExpenseGroup` via `copyWith`, then `ExpenseGroupStorageV2.updateGroupMetadata` (edit) or `.addExpenseGroup` (create). On edit, separately detects **renamed** participants/categories (same id, different name) and propagates them into historical expenses via `updateParticipantReferencesFromDiff`/`updateCategoryReferencesFromDiff` (see [caravella_core reference](PACKAGE_CARAVELLA_CORE.md)). Afterwards calls `ExpenseGroupStorageV2.forceReload()` and `notifier.notifyGroupUpdated(group.id)`.
- `deleteGroup()`, `removeParticipantIfUnused()`/`removeCategoryIfUnused()` — delegate to storage's "if unused" APIs so a participant/category still referenced by an expense can't be deleted.
- `persistPickedImage(File)`/`removeImage()` — copies a picked/cropped file into `ApplicationDocumentsDirectory` as `group_<timestamp>.jpg`.
- `setGroupType(...)`/`applyCustomTemplate(...)` — **create mode only**: swaps the previous type's default categories for the new type's. In edit mode, categories are never auto-modified (explicit design choice).

## Creation wizard

`GroupCreationWizardPage` (`lib/manager/group/pages/group_creation_wizard_page.dart` + `wizard/`) provisions `GroupFormState`, a `WizardState` (`_currentStep`, `PageController`, `totalSteps` = 2 or 3), and a `GroupFormController` (always `create` mode). Steps run in a `PageView` with `NeverScrollableScrollPhysics` (button navigation only):

1. **`WizardUserNameStep`** (optional — only shown when launched `fromWelcome` and no user name is set yet) — captures/persists the display name into `UserNameNotifier`.
2. **`WizardTypeAndNameStep`** — group title + tappable icon opening `showGroupTypeSelectorSheet`.
3. **`WizardCompletionStep`** — shown after `controller.save()` succeeds; either pops back to the welcome flow with the new group ID or navigates straight into `ExpenseGroupDetailPage`.

`WizardNavigationBar` gates progression (`_canProceedFromStep`, e.g. non-empty title) and handles promoting the "Me" placeholder participant to the real user name when leaving the name step. `WizardStepIndicator` is a purely visual stepper.

Discarding: the wizard shows a discard-confirmation dialog if the user backs out with unsaved changes — this **differs** from the standalone edit pages below, which auto-save on back instead.

## Standalone edit pages

`ExpensesGroupEditPage` is the "everything in one screen" editor: a 4-tab `TabController` (General / Participants / Categories / Other) with per-tab validation indicators. There are also **single-purpose pages**, each spinning up their own `GroupFormState`/`GroupFormController`, reachable from `GroupSettingsPage` (in `lib/manager/details/pages/group_settings_page.dart` — see [Group Details & Stats](APP_GROUP_DETAILS_STATS.md)):

- `expense_group_general_page.dart` — title, `GroupNameWithIconField` (opens type selector), `PeriodSectionEditor` (start/end dates), currency `SelectionTile` (opens `CurrencySelectorSheet`).
- `expense_group_participants_page.dart` — wraps `ParticipantsEditor`.
- `expense_group_categories_page.dart` — wraps `CategoriesEditor`.
- `expense_group_other_page.dart` — `BackgroundPicker`, a notification-enabled switch (requests OS permission, saves immediately, syncs the persistent notification via `NotificationManager` — see [Notifications](NOTIFICATIONS.md)), an "auto location" switch (saves immediately).

All of these standalone pages share a `PopScope` pattern: **if `controller.hasChanges`, they auto-save on back navigation** rather than prompting — the opposite of the wizard's discard-confirmation behavior. Keep this asymmetry in mind when touching either flow.

## Photo/background flow

`BackgroundPicker` opens a bottom sheet offering gallery / camera / Unsplash / solid color / remove:

- Gallery/camera picks (`image_picker`) push `ImageCropPage` (`lib/manager/group/pages/image_crop_page.dart`) — a **hand-rolled cropper** (no third-party crop plugin): decodes via the `image` package, tracks a draggable/resizable `Rect` in display coordinates at a fixed aspect ratio (default `0.56`), and on confirm computes `img.copyCrop` in pixel coordinates via a scale factor, writing `<original>_cropped.jpg`.
- `UnsplashSearchPage` (`unsplash_search_page.dart`) searches `UnsplashService.searchPhotos` (debounced), shows a preview sheet with required attribution, downloads the chosen photo, then routes through the same crop page. Gated by the `UNSPLASH_ACCESS_KEY` dart-define — see [Build Variants & Flavors](BUILD_VARIANTS.md).
- Color selection resolves a palette index through `ExpenseGroupColorPalette` (theme-aware — see [caravella_core reference](PACKAGE_CARAVELLA_CORE.md)), plus a playful "random color" button.

## Currencies

`data/currencies.dart` defines `kCurrencies` (`{symbol, code}` pairs; localized names come from ARB via `localizedCurrencyName`). `widgets/currency_selector_sheet.dart` sorts by localized name, filters via debounced search (name or code), and highlights matches.

## Group types and templates

`ExpenseGroupType` (from `caravella_core`) is a built-in enum: `travel`, `personal`, `family`, `other`. `GroupTypeLocalization` (`group_type/group_type_localization.dart`) maps each to a localized name + 3 localized default category names, plus an `availableIcons` list used for **custom templates**. `showGroupTypeSelectorSheet` renders both built-in types and any user-defined `GroupTypeTemplate`s (from `GroupTypeTemplatesNotifier`, a Settings-area notifier — see [App: Settings](APP_SETTINGS.md)). Selecting either calls `controller.setGroupType(...)`/`applyCustomTemplate(...)`, both create-mode-only category swaps as noted above.

## See also

- [App: Group Details & Stats](APP_GROUP_DETAILS_STATS.md) — `GroupSettingsPage`, the entry point into the standalone edit pages
- [App: Home](APP_HOME.md) — where the wizard is launched from
- [caravella_core reference](PACKAGE_CARAVELLA_CORE.md)
