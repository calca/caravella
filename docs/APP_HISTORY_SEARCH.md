# App: History & Search

Covers `lib/manager/history/**` (the all-groups list) and `lib/home/search/group_search_page.dart` (cross-group search).

## Groups list ("history")

`ExpesensHistoryPage` (`history/expenses_history_page.dart` — note: the class/file typo "Expesens" is in the actual source, not a documentation error) is the **all-groups index**, not an activity log: an **Active / Archived** `TabController(length: 2)` view, loading `ExpenseGroupStorageV2.getActiveGroups()`/`.getArchivedGroups()` in parallel.

- Listens to `ExpenseGroupNotifier` for external delete/update events and reloads (`_onNotifierChanged`).
- Sorts pinned groups first (`_applyFilter`).
- A hide-on-scroll `AddFab` opens `GroupCreationWizardPage` (see [Group Management](APP_GROUP_MANAGEMENT.md)).
- A search icon opens `GroupSearchPage` (in `lib/home/search/`, not under `manager/`).
- Archive toggling goes through `ExpenseGroupNotifier.updateGroupArchive` (handles storage persistence + app-shortcuts refresh), then the list reloads.

## Group cards in this view

`SwipeableExpenseGroupCard` (`widgets/swipeable_expense_group_card.dart`) — despite the name, the current implementation is **long-press-to-open-menu**, not swipe gestures. Long-press (with haptic feedback) opens `HistoryOptionsSheet`. Its three actions:

- `onPinToggle` → `_executePinAction` → `ExpenseGroupNotifier.updateGroupPin`
- `onArchiveToggle` → the parent page's callback, wired to the notifier
- `onDelete`

Each completes with an `AppToast` that mentions "undo" wording, though the actual undo mechanism isn't implemented in this file — it likely relies on the toast action button from `caravella_core_ui`; verify current behavior before assuming undo works end-to-end.

`HistoryOptionsSheet` (`widgets/history_options_sheet.dart`) is a pure presentation `StatelessWidget` (pin/unpin, archive/unarchive, delete `ListTile`s) — the pin option is disabled when the group is already archived.

## Empty states

`ExpsenseGroupEmptyStates` (`widgets/expense_group_empty_states.dart` — again, "Expsense" typo is in the actual source) picks one of three layouts by priority: active search query > archived-tab-specific ("no archived groups") > generic all-groups empty state.

## Cross-group search

`GroupSearchPage` (`lib/home/search/group_search_page.dart`) — see [App: Home § Search](APP_HOME.md#search) for the full description; it reuses `SwipeableExpenseGroupCard` from this area.

## See also

- [App: Home](APP_HOME.md)
- [App: Group Management](APP_GROUP_MANAGEMENT.md)
- [caravella_core reference § ExpenseGroupNotifier](PACKAGE_CARAVELLA_CORE.md#state-notifiers)
