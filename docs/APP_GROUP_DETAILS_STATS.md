# App: Group Details & Stats

Covers `lib/manager/details/**` — the per-group detail screen, the stats tabs, the settlements ("who owes whom") algorithm, the locations map, search, group settings, and data export.

## Group detail page

`ExpenseGroupDetailPage` (`details/pages/expense_group_detail_page.dart`) is the main per-group screen, in the Home / Groups style: `surfaceContainer` page, one `CustomScrollView` with

- **Header** — `GroupHeaderBand` (`widgets/group_detail_header.dart`) behind the top of the page: the group's photo (`PhotoVeil`: full color all the way up — no shade under the top bar — melting into the page color above the dates, so dates, title and figure cards keep the theme's colors; the header gets `GroupHeaderBand.photoExtraTop` more room above the title so the photo shows) or its palette color, melting into the page color. Over a color, title and top-bar icons use its contrasting text color (`GroupHeaderBand.foregroundOf`) and the status bar follows. The page is edge to edge (`AppSystemUI.edgeToEdge`: transparent system navigation bar). On it `GroupDetailHeader`: a heart when the group is a favorite, dates · participant count, the title, and three key-figure cards — total, today (`getTodaySpendingSync`), per person.
- **Selector** — a `PillSegmentedControl` (from `caravella_core_ui`) **Expenses / Balances / Statistics** (`_section`); the selected fill slides like the floating navigation's and the new content fades in (`_sectionFade`, a `SliverFadeTransition`, skipped with `disableAnimations`):
  - Expenses: `WeekGroupedExpenseSliver` (`widgets/grouped_expense_list.dart`) — one card per calendar week (Monday–Sunday), newest first; the header names it ("This week", "Last week", else the date range) with the week total; rows are `ExpenseDayRow`s (`widgets/expense_day_row.dart`: the day like a calendar — weekday over day number —, title, "payer · category", amount; 12 dp above and below) opening the edit sheet; a just-added expense fades in (`highlightedExpenseId`). With no expenses, `EmptyExpenseState`.
  - Balances: `GroupBalancesView` (`widgets/group_balances_view.dart`) — a bar per participant from `computeBalances` in one hue (right/primary = gets back, left/lighter primary = owes; amounts primary / onSurface), then "Settle up" with the `computeSettlements` payments, each with a share button sending a reminder to the payer (`balance_reminder_message`), and "Share balances" sending the whole summary (payments, total, per person) — both through the system share sheet (`share`, injectable for tests); or "All settled up".
  - Statistics: `GroupStatisticsView` (`widgets/group_statistics_view.dart`) — one spending chart in a card titled above it, over the whole group (`buildGroupSpendingSeries` in `daily_totals_utils.dart`: from the start date or first expense to the end date or last expense — an ongoing group stops at today — day by day up to 31 days, week by week up to ~6 months, month by month beyond; titled "Day by day" / "Week by week" / "Month by month" with the period), `GroupPayersBubbles` (each participant's avatar sized by what they paid, area ∝ amount), `GroupMapCard` (always shown; `groupPlacesCount` counts distinct coordinates rounded to ~100 m): with places it opens `ExpenseLocationsMapPage`; without any, if the group's automatic location is off it says so and opens the group's Other settings (`ExpenseGroupOtherPage`, via `onEnableLocation`) where it's turned on, otherwise it's a non-tappable "No expenses with a place yet" note, `SpendingPaceCard` (the group's total spread over every day of its period — or every month, for groups longer than two months — from `SpendingPace.of` in `caravella_core`, with what it's averaged over and pills for the expense count, the average expense and how many days/months had any), highest expense and most expensive day (`highestExpense`, `mostExpensiveDay` — reusing `WeekGroupedExpenseSliver.groupByDay`; `mostExpensiveMonth` instead of the day when the pace is per month), then `CategoriesOverviewTab(embedded: true)`. Total, period and participants aren't repeated (they're in the header).
- **Welcome** — a group received from another device and not opened yet shows `GroupWelcomeCard` (`widgets/group_welcome_card.dart`) above the section selector until OK or Add expense (see [Sync Architecture](SYNC_ARCHITECTURE.md)).
- **Top bar** — an overlay with round buttons (back, search, ⋯) that turns opaque as soon as content scrolls under it (`_barOpaque`) and shows the group name once the title scrolls away (`_collapsedTitleVisible`). The ⋯ menu (`_GroupMenuButton`, a `MenuAnchor` whose items are at least 248 dp wide so its end lines up with the button) holds favorite/unfavorite, synchronization and settings (`GroupSettingsPage`); the map opens from its card in Statistics, and share & export (`showExpenseExportOptionsSheet`) is in the group's settings only. In the header, a synced group's "Shared" pill (`GroupSyncBadge` with `onTap` — a 48 dp touch target around the small pill —, its dot showing the sync state — see [Sync Architecture](SYNC_ARCHITECTURE.md)) also opens the sync page; on Home's card it is the same pill without the chevron.
- A round, hide-on-scroll `AddFab` and the expense add/edit sheet (`lib/manager/expense/pages/expense_form_page.dart` — see [Expense Entry](APP_EXPENSE_ENTRY.md)).

The old separate Overview page (`UnifiedOverviewPage` with General / Participants / Categories tabs) is gone: its content lives in Statistics and Balances.

## Stats helpers

`CategoriesOverviewTab` (`pages/tabs/categories_overview_tab.dart`) renders one `StatCard` per category (total, per day — or per month — over the same period as `SpendingPace`, % bar); the group page uses it with `embedded: true` (no own scroll view or padding).

Chart/series helpers live in `pages/tabs/usecase/`:

- `daily_totals_utils.dart` — `calculateDailyTotalsOptimized(group, startDate, days)` buckets expense amounts into a fixed-length daily array; `buildWeeklySeries`/`buildMonthlySeries` wrap it ("this week starting Monday" / "this calendar month"); `buildAdaptiveDateRangeSeries` picks the group's explicit date range if ≤30 days, else falls back to the actual expense date span (also capped at 30 days); `shouldShowDateRangeChart` decides whether `GroupStatisticsView` shows one combined date-range chart instead of separate weekly+monthly charts.
- `date_range_formatter.dart` — `formatDateRange({start, end, locale})`, omitting the year when it matches the current year, always showing both years when a range crosses a year boundary.

> `settlements_logic.dart` is just a re-export shim (`export 'package:caravella_core/caravella_core.dart' show Settlement, computeSettlements;`) — the real algorithm is in `caravella_core`; the stats logic lives on `ExpenseGroup` (`getTotalExpenses`, `getCategoryTotals`, …) and in `SpendingPace` (period, unit and averages: the period runs from the start date or first expense to the end date — capped at today — or today, always covering every expense).

## Settlements algorithm

The "who owes whom" logic is `computeSettlements(ExpenseGroup trip)` in `packages/caravella_core/lib/model/group_settlements.dart` (re-exported through the shim above for convenience):

1. Returns `[]` if fewer than 2 participants or no expenses.
2. `fairShare = total / participants.length` — an **equal-split assumption**; there is no per-expense weighting or itemized-share support.
3. Builds a `balances` map per participant, crediting each expense's `amount` to whoever **paid** it, then subtracting `fairShare` from every participant. Positive = creditor (is owed money), negative = debtor.
4. Splits into `creditors`/`debtors` (ignoring near-zero balances via a `0.01` epsilon), sorts each descending.
5. Runs a classic **greedy minimal-transaction matching**: repeatedly settle `min(largestCreditor, largestDebtor)`, record a `Settlement(fromId, toId, amount)` (participant **IDs**, not names — survives renames), decrement both sides, advance whichever hit zero.

This produces a minimal (or near-minimal) set of transactions, not a full pairwise ledger. Consumers: `GroupBalancesView`, `MarkdownExporter.generate`. The per-participant balances themselves (step 3) are `computeBalances(trip)`, used directly by `GroupBalancesView`.

If you ever need to support unequal/itemized splits, this is the function to change — but note it's a fundamental behavior change (currently *whoever pays* is credited the full amount, not *whoever benefits*).

## Locations map

`expense_locations_map_page.dart` filters expenses down to those with a non-null lat/lng, computes bounds via `computeBounds` (see [caravella_core_ui reference](PACKAGE_CARAVELLA_CORE_UI.md)), and renders pins on a `flutter_map` (OSM). Pins that would overlap on screen (closer than 44 logical px at the current zoom) are merged into one numbered pin; the clustering runs in a `Builder` inside the map's layers, so it's recomputed on every zoom/pan and zooming in splits a group back up. Tapping a pin opens `ExpenseMapDetailSheet`, which shows a single address + coordinates when every expense in the group shares the spot, or the distinct place names otherwise. See [Location & Maps](LOCATION_AND_MAPS.md).

## Search

`expense_search_page.dart` (`ExpenseSearchPage`) is full-text + filter search over a group's expenses (name / note / category / payer / place / amount), in the app's style (`SearchTopBar`, `FilterPill`, `PillSection`, `SearchSummaryBar` from `caravella_core_ui`). Before typing (no query, no filters) it shows the filters as suggestions: paid by, categories, period (today, last 7 days, this month, a range via `PeriodSelectionBottomSheet`), with attachment / with place. The filters button opens the same choices in a sheet ("Show N results"); active filters stay as removable pills (plus "Clear" when there are several). Results show their count and total, then one card of `ExpenseDayRow`s (`showMonth`: month over day number, since results span weeks) with the match highlighted in title and "payer · category"; an expense found only through its place or note gets a line under the row saying so (`_matchReason`).

## Group settings

`group_settings_page.dart` (`GroupSettingsPage`) uses the same layout as the app settings (`SettingsScaffold`, see [Settings](APP_SETTINGS.md#settings-hub)): eyebrow "Group", "Settings" title, a `SettingsProfileCard` with the group's photo / color / type icon, title and dates · people · currency (tap → `ExpenseGroupGeneralPage`; tapping the picture itself opens it with the background sheet already open), then **Group** (participants and categories, with their first names as subtitle; Other → `ExpenseGroupOtherPage`), **Share & export** (sync page, export options — disabled without expenses) and **Danger zone** (archive / unarchive, delete in the error color). The editor pages are described in [Group Management](APP_GROUP_MANAGEMENT.md); they use the same `SettingsScaffold` layout (General: name, period, currency and background in cards; Participants / Categories: `EditableNameList` rows in a card, `showHeader: false`; Other: notification / auto-location switches; Sync: `ExpenseGroupSyncPage`).

## Data export

All in `export/`, static classes with `generate(...)`/`buildFilename(...)`:

| Exporter | Format | Filename pattern |
|---|---|---|
| `CsvExporter` | One row per expense (name, amount, paidBy, category, ISO date, note, location text) | `YYYYMMDD_<slug-title>_export.csv` |
| `MarkdownExporter` | Full report: metadata, per-participant/per-category totals, settlements section, expense table | `YYYYMMDD_<slug-title>_export.md` |
| `OfxExporter` | Pseudo-OFX 2.0 XML (`<STMTTRN>` per expense, all typed `DEBIT`) for import into personal-finance apps | `YYYY-MM-DD_<slug-title>_export.ofx` |

## See also

- [App: Expense Entry](APP_EXPENSE_ENTRY.md)
- [App: Group Management](APP_GROUP_MANAGEMENT.md)
- [Location & Maps](LOCATION_AND_MAPS.md)
- [caravella_core reference](PACKAGE_CARAVELLA_CORE.md)
