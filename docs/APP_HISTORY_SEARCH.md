# App: History & Search

Covers `lib/manager/history/**` (the all-groups list) and `lib/home/search/group_search_page.dart` (cross-group search).

## Groups list ("history")

`ExpesensHistoryPage` (`history/expenses_history_page.dart` — note: the class/file typo "Expesens" is in the actual source, not a documentation error) is the **all-groups index**, not an activity log, loading `ExpenseGroupStorageV2.getActiveGroups()`/`.getArchivedGroups()` in parallel. It shares Home's look: `surfaceContainer` page, a "N active groups" line above a large "Groups" title, search in a raised circle, and an **Active · n / Archived · n** pill switch (`PillSegmentedControl` from `caravella_core_ui`, styled like the floating navigation) instead of tabs.

- Groups are `GroupPhotoCard`s (`widgets/group_photo_card.dart`): on the Active view the favorite group is a wide card on top, the others a two-column grid of tiles. All cards share one background treatment — a photo is a cover (`PhotoVeil` from `caravella_core_ui`, like the Home card and the group page): full color on top, a black scrim behind the white text at the bottom; a palette color is used solid with contrasting text; otherwise a raised neutral surface, and cards without a photo show the group type icon top-left. Every card has the `CardOutline` hairline to stand out from the page. Tap opens the group; long press opens the shared options sheet (`showGroupOptionsSheet` in `widgets/group_options.dart`: favorite, archive, delete — also used by group search).

- Listens to `ExpenseGroupNotifier` for external delete/update events and reloads (`_onNotifierChanged`).
- Sorts pinned groups first (`_applyFilter`).
- It is the **Groups tab** of the app shell (see [Home § AppShell](APP_HOME.md#appshell-home-and-groups-tabs)): there it registers "create new group" as the round button next to the floating navigation and pads its list so the last card scrolls clear of the bar. When pushed on its own (e.g. from the all-archived empty state) it shows a hide-on-scroll `AddFab` instead. Both open `GroupCreationWizardPage` (see [Group Management](APP_GROUP_MANAGEMENT.md)).
- A search icon opens `GroupSearchPage` (in `lib/home/search/`, not under `manager/`).
- Archive toggling goes through `ExpenseGroupNotifier.updateGroupArchive` (handles storage persistence + app-shortcuts refresh), then the list reloads.

## Group options

Long press on a group card (here and in group search) opens `showGroupOptionsSheet` (`widgets/group_options.dart`): favorite / unfavorite (`ExpenseGroupNotifier.updateGroupPin`), archive / unarchive (the caller's callback, wired to the notifier), delete. `HistoryOptionsSheet` (`widgets/history_options_sheet.dart`) is the presentation of those actions; the pin option is disabled when the group is archived.

## Empty states

`ExpsenseGroupEmptyStates` (`widgets/expense_group_empty_states.dart` — again, "Expsense" typo is in the actual source) picks one of three layouts by priority: active search query > archived-tab-specific ("no archived groups") > generic all-groups empty state.

## Cross-group search

`GroupSearchPage` (`lib/home/search/group_search_page.dart`) — see [App: Home § Search](APP_HOME.md#search) for the full description; its rows open the group and, on long press, the same options sheet.

## See also

- [App: Home](APP_HOME.md)
- [App: Group Management](APP_GROUP_MANAGEMENT.md)
- [caravella_core reference § ExpenseGroupNotifier](PACKAGE_CARAVELLA_CORE.md#state-notifiers)
