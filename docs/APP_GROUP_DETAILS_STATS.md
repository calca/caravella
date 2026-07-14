# App: Group Details & Stats

Covers `lib/manager/details/**` — the per-group detail screen, the stats tabs, the settlements ("who owes whom") algorithm, the locations map, search, group settings, and data export.

## Group detail page

`ExpenseGroupDetailPage` (`details/pages/expense_group_detail_page.dart`) is the main per-group screen — **not itself tabbed**: hero header, expense list via `FilteredExpenseList`, a hide-on-scroll FAB, and the expense add/edit sheet (`lib/manager/expense/pages/expense_form_page.dart` — see [Expense Entry](APP_EXPENSE_ENTRY.md)). It links out to:

- `_openUnifiedOverviewPage()` → `UnifiedOverviewPage` (the tabbed stats UI, below)
- `_openSearchPage()` → `ExpenseSearchPage.show`
- An export-options bottom sheet using the exporters (below)

## Stats tabs

`UnifiedOverviewPage` (`pages/unified_overview_page.dart`) is where the tabbed UI actually lives: `DefaultTabController(length: 3)` with tabs **General / Participants / Categories** (in that source-code order), rendering `GeneralOverviewTab`, `ParticipantsOverviewTab`, `CategoriesOverviewTab` inside a `RepaintBoundary` so the whole page can be captured as a shareable image (`_shareImage`). A parallel `_shareText` builds a plain-text summary using the same settlement computation as the Participants tab. A map button opens `ExpenseLocationsMapPage` (below); a share sheet offers text vs. image export.

Chart/series helpers live in `pages/tabs/usecase/`:

- `daily_totals_utils.dart` — `calculateDailyTotalsOptimized(group, startDate, days)` buckets expense amounts into a fixed-length daily array; `buildWeeklySeries`/`buildMonthlySeries` wrap it ("this week starting Monday" / "this calendar month"); `buildAdaptiveDateRangeSeries` picks the group's explicit date range if ≤30 days, else falls back to the actual expense date span (also capped at 30 days); `shouldShowDateRangeChart` decides whether `GeneralOverviewTab` shows one combined date-range chart instead of separate weekly+monthly charts.
- `date_range_formatter.dart` — `formatDateRange({start, end, locale})`, omitting the year when it matches the current year, always showing both years when a range crosses a year boundary.

> **Known dead code**: `pages/tabs/usecase/overview_stats_logic.dart` is an empty file with no references anywhere in `lib/` — the real stats logic lives directly on `ExpenseGroup` in `caravella_core` (`getTotalExpenses`, `getDailyAverage`, `getCategoryTotals`, etc., called directly by the tab widgets). Similarly, `settlements_logic.dart` is just a re-export shim (`export 'package:caravella_core/caravella_core.dart' show Settlement, computeSettlements;`) — the real algorithm is in `caravella_core`. Feel free to delete `overview_stats_logic.dart` if you're in the area; it's leftover scaffolding from a refactor.

## Settlements algorithm

The "who owes whom" logic is `computeSettlements(ExpenseGroup trip)` in `packages/caravella_core/lib/model/group_settlements.dart` (re-exported through the shim above for convenience):

1. Returns `[]` if fewer than 2 participants or no expenses.
2. `fairShare = total / participants.length` — an **equal-split assumption**; there is no per-expense weighting or itemized-share support.
3. Builds a `balances` map per participant, crediting each expense's `amount` to whoever **paid** it, then subtracting `fairShare` from every participant. Positive = creditor (is owed money), negative = debtor.
4. Splits into `creditors`/`debtors` (ignoring near-zero balances via a `0.01` epsilon), sorts each descending.
5. Runs a classic **greedy minimal-transaction matching**: repeatedly settle `min(largestCreditor, largestDebtor)`, record a `Settlement(fromId, toId, amount)` (participant **IDs**, not names — survives renames), decrement both sides, advance whichever hit zero.

This produces a minimal (or near-minimal) set of transactions, not a full pairwise ledger. Consumers: `ParticipantsOverviewTab`, `UnifiedOverviewPage._buildTextSummary`, `MarkdownExporter.generate`.

If you ever need to support unequal/itemized splits, this is the function to change — but note it's a fundamental behavior change (currently *whoever pays* is credited the full amount, not *whoever benefits*).

## Locations map

`expense_locations_map_page.dart` filters expenses down to those with a non-null lat/lng, computes bounds via `computeBounds` (see [caravella_core_ui reference](PACKAGE_CARAVELLA_CORE_UI.md)), and renders pins on a `flutter_map` (OSM). Tapping a pin opens `ExpenseMapDetailSheet`. See [Location & Maps](LOCATION_AND_MAPS.md).

## Search

`expense_search_page.dart` (`ExpenseSearchPage`) is full-text + filter search over a group's expenses (name/note/category/paidBy/location/amount), with quick date-range chips (`PeriodSelectionBottomSheet`), category/paid-by filter chips, and has-attachment/has-location toggles.

## Group settings

`group_settings_page.dart` (`GroupSettingsPage`) is a list of tiles navigating into the standalone group editor pages described in [Group Management](APP_GROUP_MANAGEMENT.md) (`ExpenseGroupGeneralPage`, `...ParticipantsPage`, `...CategoriesPage`, `...OtherPage`) plus export options.

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
