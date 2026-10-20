# App: Home

Covers `lib/home/**`, plus the `lib/main/` wiring that presents the home screen.

## `AppShell`: Home and Groups tabs

`MaterialApp.home` is `AppShell` (`lib/main/app_shell.dart`): **Home** (`CaravellaHomePage`) and **Groups** (`ExpesensHistoryPage`, see [History & Search](APP_HISTORY_SEARCH.md)) as two tabs kept alive in a `FadeThroughStack` (like an `IndexedStack`, but switching plays the Material "fade through" — old tab fades out, new one fades in scaling up from 92 %, 300 ms, over the page color; instant when the system disables animations), under a floating `FloatingNavBar` (from `caravella_core_ui`: neutral pill, the selected tab's label slides out next to its icon; on a tab change one animation slides the selected pill over to the new tab while the labels swap and bounces the new icon). Pages pushed on top (group detail, settings, forms…) cover the shell, so the bar only shows on the two tabs.

- **Primary action**: the round button beside the bar is the current tab's main action, registered by the tab through `AppShellScope.of(context)?.setPrimaryAction(tab, FloatingNavAction(...))` (applied after the frame, so it's safe from `build`). Home registers "new expense in <featured group>" (opens the same quick-add sheet as the card used to — `AddExpenseController`), or "create new group" when no group is active; Groups registers "create new group" (its own FAB is hidden inside the shell, kept when the page is pushed elsewhere). The icon cross-fades/rotates when switching tabs.
- `setNavVisible(false)` hides the bar: `HomePage` does it while loading and on the welcome screen (first start, or no group left at all).
- **Back** on Groups returns to Home (`PopScope`); on Home it leaves the app as before.
- A gradient behind the bar, only as tall as the bar so it never reaches the Home card at rest, fades content scrolling under it into the page color; scrollable tab content reserves `FloatingNavBar.reservedHeight` + the bottom inset at its end.

## `CaravellaHomePage` → `HomePage`

`CaravellaHomePage` (`lib/main/caravella_home_page.dart`) is a thin wrapper around `HomePage`. On first build it subscribes to the global `routeObserver` (see [Architecture Overview](ARCHITECTURE.md)) and calls `NotificationManager.restoreNotifications(context)` exactly once — this is what re-shows persistent notifications for all groups after an app restart (see [Notifications](NOTIFICATIONS.md)).

`HomePage` (`lib/home/home_page.dart`) is a `StatefulWidget` with `RouteAware`. State: `_pinnedTrip`, `_activeGroups`, `_archivedGroups`, `_isFirstStart` (`null` = unknown/loading), `_dataLoaded`.

- `_loadLocaleAndTrip()` loads pinned/active/archived groups in parallel (`Future.wait`), then decides whether to show the welcome screen via `_shouldShowWelcomeScreen`, which combines the `is_first_start` preference with the **actual data** (`!hasGroups && prefValue`) — a deliberate correction so a stale "first start" flag never hides real groups.
- Listens to `ExpenseGroupNotifier` (`context.read<ExpenseGroupNotifier>().addListener(_onGroupUpdated)`): reads `updatedGroupIds`, triggers `setState`, then calls `clearUpdatedGroups()` and `consumeLastEvent()`.
- `didPopNext()` (RouteAware) triggers a lighter `_softRefresh()` — no loading flicker — when returning from a pushed page.
- `_performUpdateCheckIfNeeded()` runs once per session (1s after first frame) and calls `GmsIntegrations.instance.appUpdates?.checkAndShowUpdateIfNeeded(...)` (`play_store_updates` in Play builds; nothing in the F-Droid build) — see [play_store_updates package](PACKAGE_PLAY_STORE_UPDATES.md) and [caravella_gms](PACKAGE_CARAVELLA_GMS.md).
- `build()` crossfades (`AnimatedSwitcher`) between a loading placeholder, `HomeWelcomeSection` (first-run/no-groups state), and `HomeCardsSection` wrapped in a pull-to-refresh `RefreshIndicator`.

## `HomeCardsSection` and cards

`HomeCardsSection` (`lib/home/cards/home_cards_section.dart`) manages the active-groups list locally (seeded from `HomePage` or self-loaded), also listens to `ExpenseGroupNotifier`, and does **incremental patch updates** (`_updateAffectedGroupsLocally`) instead of full reloads when possible — falling back to a full `_loadActiveGroups()` only if a changed/deleted group isn't found locally.

Layout: a scroll view with `HomeCardsHeader` (greeting + settings button) → the featured `GroupCard` (pinned group, or first active group), sized to fill the screen above the floating navigation (at least `HomeLayoutConstants.minFeaturedCardHeight`, so short screens scroll instead of squeezing it) and without its own add-expense button (`showAddButton: false` — the shell's round button does it) → `GroupQuickActions` — **Scan** (`AddExpenseController.scanReceiptAndAdd`: the camera opens right away, `ReceiptScannerService` reads amount and description, the photo is copied into the group's attachments, then the quick-add sheet opens pre-filled with the last payer selected — `showAddExpenseSheet(initialExpense:)`). Where OCR isn't available (F-Droid) the same spot is **Photo** (`scanReceiptAndAdd(readReceipt: false)`: camera, photo attached, amount and description left to the user), **Voice** (`GroupCardVoiceButton` with a `builder` drawing it as a quick action; while listening a bottom panel shows a microphone pulsing with the voice level and the words recognised so far — `VoiceInputService.startListening(onPartial:, onSoundLevel:)` — with Cancel), **Map** and **Search** (disabled without places / expenses) — which sits under the bar and is reached by scrolling. The page is edge to edge: `AppSystemUI.edgeToEdge` (transparent system navigation bar) and a `StatusBarFade` that dims scrolled content under the clock instead of an opaque strip (same on Groups). The header is the greeting (small) over the user's name (large), like the Groups page title, and a raised round settings button; `HomeSyncButton` appears next to it only while a sync runs or after a failure (see [Sync Architecture](SYNC_ARCHITECTURE.md)). All groups are in the Groups tab — there is no carousel. With no active group (all archived) it shows `EmptyGroupsState`. Sizing constants live in `home_constants.dart` (`HomeLayoutConstants`, pure constants, no logic).

Card widgets (`lib/home/cards/widgets/`): `GroupCard` (wraps `BaseCard` with `mergeSemantics: false` inside a `CardOutline` hairline, background via `GroupBackgroundUtils.resolve` — except a photo, which is drawn behind the card as a `PhotoVeil` (photo just hinted under the card's surface, like the Groups cards) so the content keeps the theme's text colors; for screen readers the header is the "open group" button, while the recent-expense rows and the add-expense button stay separate nodes), `GroupCardContent`/`Header`/`Stats`/`Amounts`/`TodaySpending`/`Recents` (body composition; with no expenses yet `GroupCardGetStarted` replaces the amounts and recents with a checklist — group created, first expense, participants (≥2), photo or color — each open step tappable, done steps ticked from the group's data; `Recents` shows the last 2 expenses, 3 when the card is tall enough — `_threeRecentsMinHeight` in `group_card_content.dart`), `GroupCardVoiceButton` (voice entry with direct save when complete — see [Expense Entry § voice input](APP_EXPENSE_ENTRY.md#voice-input); its `builder` lets `GroupQuickActions` draw it), `GroupQuickActions` (shortcuts under the card), `EmptyGroupsState`.

## Search

`GroupSearchPage` (`lib/home/search/group_search_page.dart`) searches active and archived groups by title, in the app's style (`SearchTopBar` and pills from `caravella_core_ui`). Before typing (no query, no filters) it suggests recent searches (`PreferencesService.search`, last 5, recorded when a result is opened or the query submitted) and the group types present (plus Archived / Favorites); a filters button opens a sheet (status all / active / archived, favorites, type) and active filters stay as removable pills. Results are listed in Active / Archived cards (`GroupIconAvatar`, title with the match highlighted by `HighlightedText`, dates · people, total); tap opens the group, long press the options sheet (see [History & Search](APP_HISTORY_SEARCH.md)).

## First-run onboarding

`HomeWelcomeSection` (`lib/home/welcome/home_welcome_section.dart`) is the animated (fade-in, 900ms) first-run screen: title, logo, a "Settings" link, and a circular forward button that pushes `GroupCreationWizardPage(fromWelcome: true)` (see [Group Management](APP_GROUP_MANAGEMENT.md)). It manages its own system-UI overlay colors since it needs different status-bar treatment than the rest of the app.

## Android integration bootstrapping

- `lib/home/services/shortcuts_initialization.dart` (`ShortcutsInitialization.initialize()`) — configures `ShortcutsNavigationService` with navigate/error callbacks, initializes `PlatformShortcutsManager` and `PlatformHomeWidgetManager`'s tap handling, and immediately refreshes shortcuts. Home-widget taps dispatch to `NotificationManager.handleAddExpenseAction` (add-expense action) or `ShortcutsNavigationService.handleShortcutTap` (open-group action). This runs before `runApp()`, so a cold-start tap can be dispatched before `navigatorKey` has a mounted context; both handlers await `ShortcutsNavigationService.waitForNavigatorContext()` (short poll, several-second timeout) before touching the context instead of dropping the action.
- `lib/home/services/app_functions_initialization.dart` (`AppFunctionsInitialization.initialize()`) — registers the Android App Functions "add expense" handler. See [android_app_functions package](PACKAGE_ANDROID_APP_FUNCTIONS.md).

Both are invoked from `AppInitialization`/`main.dart` at startup — see [Architecture Overview § startup sequence](ARCHITECTURE.md#app-startup-sequence).

## See also

- [App: Group Management](APP_GROUP_MANAGEMENT.md)
- [App: History & Search](APP_HISTORY_SEARCH.md)
- [Notifications](NOTIFICATIONS.md)
- [caravella_core reference § ExpenseGroupNotifier](PACKAGE_CARAVELLA_CORE.md#state-notifiers)
