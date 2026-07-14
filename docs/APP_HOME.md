# App: Home

Covers `lib/home/**`, plus the `lib/main/` wiring that presents the home screen.

## `CaravellaHomePage` → `HomePage`

`CaravellaHomePage` (`lib/main/caravella_home_page.dart`) is a thin wrapper around `HomePage`. On first build it subscribes to the global `routeObserver` (see [Architecture Overview](ARCHITECTURE.md)) and calls `NotificationManager.restoreNotifications(context)` exactly once — this is what re-shows persistent notifications for all groups after an app restart (see [Notifications](NOTIFICATIONS.md)).

`HomePage` (`lib/home/home_page.dart`) is a `StatefulWidget` with `RouteAware`. State: `_pinnedTrip`, `_activeGroups`, `_archivedGroups`, `_isFirstStart` (`null` = unknown/loading), `_dataLoaded`.

- `_loadLocaleAndTrip()` loads pinned/active/archived groups in parallel (`Future.wait`), then decides whether to show the welcome screen via `_shouldShowWelcomeScreen`, which combines the `is_first_start` preference with the **actual data** (`!hasGroups && prefValue`) — a deliberate correction so a stale "first start" flag never hides real groups.
- Listens to `ExpenseGroupNotifier` (`context.read<ExpenseGroupNotifier>().addListener(_onGroupUpdated)`): reads `updatedGroupIds`, triggers `setState`, then calls `clearUpdatedGroups()` and `consumeLastEvent()`.
- `didPopNext()` (RouteAware) triggers a lighter `_softRefresh()` — no loading flicker — when returning from a pushed page.
- `_performUpdateCheckIfNeeded()` runs once per session (1s after first frame) and calls `checkAndShowUpdateIfNeeded(...)` from `play_store_updates` — see [play_store_updates package](PACKAGE_PLAY_STORE_UPDATES.md).
- `build()` crossfades (`AnimatedSwitcher`) between a loading placeholder, `HomeWelcomeSection` (first-run/no-groups state), and `HomeCardsSection` wrapped in a pull-to-refresh `RefreshIndicator`.

## `HomeCardsSection` and cards

`HomeCardsSection` (`lib/home/cards/home_cards_section.dart`) manages the active-groups list locally (seeded from `HomePage` or self-loaded), also listens to `ExpenseGroupNotifier`, and does **incremental patch updates** (`_updateAffectedGroupsLocally`) instead of full reloads when possible — falling back to a full `_loadActiveGroups()` only if a changed/deleted group isn't found locally.

Layout: `HomeCardsHeader` (greeting + settings button) → a featured `GroupCard` (pinned group, or first active group) → "Your Groups" header with a "see all" CTA (pushes [History & Search](APP_HISTORY_SEARCH.md)) → `HorizontalGroupsList` carousel of the rest. Sizing constants live in `home_constants.dart` (`HomeLayoutConstants`, pure constants, no logic).

Card widgets (`lib/home/cards/widgets/`): `GroupCard` (wraps `BaseCard`, background via `GroupBackgroundUtils.resolve`), `GroupCardContent`/`Header`/`Stats`/`Amounts`/`TodaySpending`/`Recents` (body composition), `GroupCardVoiceButton` (per-card mic button — see [Expense Entry § voice input](APP_EXPENSE_ENTRY.md#voice-input)), `CarouselGroupCard`/`HorizontalGroupsList` (carousel tiles), `NewGroupCard` (add-group tile), `EmptyGroupsState`.

## Search

`GroupSearchPage` (`lib/home/search/group_search_page.dart`) is a full-screen "Gmail-style" search: autofocused `TextField` in the app bar, filters active+archived groups client-side by title, renders results as `SwipeableExpenseGroupCard` (see [History & Search](APP_HISTORY_SEARCH.md)), supports swipe-to-archive and delete/pin actions via `ExpenseGroupNotifier`.

## First-run onboarding

`HomeWelcomeSection` (`lib/home/welcome/home_welcome_section.dart`) is the animated (fade-in, 900ms) first-run screen: title, logo, a "Settings" link, and a circular forward button that pushes `GroupCreationWizardPage(fromWelcome: true)` (see [Group Management](APP_GROUP_MANAGEMENT.md)). It manages its own system-UI overlay colors since it needs different status-bar treatment than the rest of the app.

## Android integration bootstrapping

- `lib/home/services/shortcuts_initialization.dart` (`ShortcutsInitialization.initialize()`) — configures `ShortcutsNavigationService` with navigate/error callbacks, initializes `PlatformShortcutsManager` and `PlatformHomeWidgetManager`'s tap handling, and immediately refreshes shortcuts. Home-widget taps dispatch to `NotificationManager.handleAddExpenseAction` (add-expense action) or `ShortcutsNavigationService.handleShortcutTap` (open-group action).
- `lib/home/services/app_functions_initialization.dart` (`AppFunctionsInitialization.initialize()`) — registers the Android App Functions "add expense" handler. See [android_app_functions package](PACKAGE_ANDROID_APP_FUNCTIONS.md).

Both are invoked from `AppInitialization`/`main.dart` at startup — see [Architecture Overview § startup sequence](ARCHITECTURE.md#app-startup-sequence).

## See also

- [App: Group Management](APP_GROUP_MANAGEMENT.md)
- [App: History & Search](APP_HISTORY_SEARCH.md)
- [Notifications](NOTIFICATIONS.md)
- [caravella_core reference § ExpenseGroupNotifier](PACKAGE_CARAVELLA_CORE.md#state-notifiers)
