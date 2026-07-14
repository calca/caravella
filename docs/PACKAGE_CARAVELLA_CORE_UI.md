# Package: `caravella_core_ui`

Shared design-system package: reusable widgets, themes, map building blocks. Depends only on `caravella_core` among local packages (see [Architecture Overview](ARCHITECTURE.md)). Import as a whole: `import 'package:caravella_core_ui/caravella_core_ui.dart';` — avoid deep-importing individual widget files.

**Before building any new screen, dialog, card, or chart in `lib/`, check here first.** This page is the catalog.

## Widgets (`lib/widgets/`)

| Widget | Solves | Key params |
|---|---|---|
| `BaseCard` | Generic content card: flat/bordered, plain color, or background image + gradient overlay | `backgroundColor`, `backgroundImage` (a **file path**, not asset/URL), `backgroundGradient`, `isFlat`, `noBorder`, `borderRadius` (default 16) |
| `GroupBottomSheetScaffold` | Standard modal-bottom-sheet wrapper: drag handle, optional title, consistent padding | `title`, `padding` (default `EdgeInsets.fromLTRB(20,20,20,24)`), `scrollable`, `showHandle` |
| `SectionHeader` | Title + optional description + trailing action, with optional required-field asterisk | `title`, `description`, `trailing`, `requiredMark`, `showRequiredHint` |
| `CaravellaAppBar` | Thin `AppBar` wrapper (no title slot — content lives below), semantic labels for a11y | `actions`, `leading`, `headerSemanticLabel`, `backButtonSemanticLabel` |
| `CaravellaTabBar` | Standardized `TabBar` styling | `tabs`, `controller` (or wrap in `DefaultTabController`), `isScrollable` |
| `BottomActionBar` | Sticky bottom bar with one full-width `FilledButton` | `onPressed`, `label` (auto-uppercased), `enabled` |
| `AppToast` | Toasts/snackbars — **never call `ScaffoldMessenger.of` directly**, use this | `AppToast.show(context, message, {type: ToastType.info/success/error, duration, icon})` |
| `Material3Dialog` / `Material3Dialogs` | M3-styled dialogs and ready-made confirm/info flows | `Material3Dialogs.showConfirmation({title, content, isDestructive})`, `.showInfo({title, content})` |
| `showSelectionBottomSheet<T>` | Generic picker with inline "add new item" support and duplicate-name checking | `items`, `selected`, `itemLabel`, `onAddItemInline` |
| `CurrencyDisplay` | Large locale-aware amount + currency-code display | `value`, `currency`, `valueFontSize` (default 54), `showDecimals`; static `formatCurrencyText(...)` for text-only use |
| `NoExpense` | Empty-state widget (receipt icon + message) | `semanticLabel`, `noExpenseLabel`, `addFirstExpenseLabel` (caller supplies localized strings) |
| `AddFab` | Styled `FloatingActionButton` with tinted shadow | `onPressed`, `icon` (default `Icons.add_rounded`), `tooltip` |
| `AppSystemUI` | Status/nav bar color + icon-brightness management | Factories: `.surface()`, `.surfaceContainer()`, `.custom()` |
| `GroupBackgroundUtils` / `GroupBackground` | Computes a group's card background (color/gradient/image) consistently everywhere a group is rendered | `GroupBackgroundUtils.resolve(group, colorScheme)` → feed `.gradient`/`.imagePath` into `BaseCard` |
| `ChartBadge`, `WeeklyExpenseChart`, `MonthlyExpenseChart`, `DateRangeExpenseChart`, `Last15DaysBarChart`, `ChartType` | `fl_chart`-based sparklines/bar chart for spending trends | `{dailyTotals, theme, badgeText, semanticLabel}`; `ChartType` enum drives i18n keys via `getBadgeKey()`/`getSemanticLabelKey()` |

`lib/widgets/widgets.dart` is a secondary barrel re-exporting only `base_card`, `bottom_action_bar`, `caravella_tab_bar`, `material3_dialog`, `section_header` — prefer the main package barrel unless you specifically want this subset.

## Map widgets (`lib/map/`)

Built on **`flutter_map`** (OpenStreetMap tiles) + **`latlong2`**:

- `MapTileLayerWidget` — centralizes the OSM tile layer config (`tile.openstreetmap.org`, `userAgentPackageName`, swallows tile-load errors).
- `StandardMap` — the entry point for any new map screen: always includes the tile layer, pass markers/polylines via `layers`.
- `computeBounds(points, {minSpanDegrees})` — bounding box for a set of points, expanding near-degenerate spans so camera fit doesn't over-zoom.
- `MapLoadingOverlay`, `MapErrorOverlay`, `MapErrorState`, `MapEmptyState`, `MapNoResultsMessage` — presentational overlays for common map states.

See [Location & Maps](LOCATION_AND_MAPS.md) for how these compose with the geocoding/search pipeline.

## Themes (`lib/themes/`)

- **`caravella_themes.dart`** — hand-authored Material 3 `ColorScheme` consts: `lightColorScheme` (seed primary `0xFF009688` teal) and `darkColorScheme` (a custom "soft dark" scheme tuned for WCAG AA contrast). `CaravellaThemes.createLightTheme({dynamicColorScheme})` / `createDarkTheme(...)` build full `ThemeData` (Material 3, `Montserrat` font family, custom text theme, dialog/input decoration themes), supporting Android dynamic color (Material You) with a fallback to the hardcoded scheme's container shades. Precomputed statics: `CaravellaThemes.light` / `.dark`.
- **`app_text_styles.dart`** — `AppTextStyles` convenience tokens derived from `Theme.of(context).textTheme`: `sectionTitle`, `listItem`, `listItemStrong`, `subtle`.
- **`form_theme.dart`** — `FormTheme` spacing constants (`fieldSpacing`, `sectionSpacing`, ...) and decoration builders: `getStandardDecoration`, `getMultilineDecoration`, `getBorderlessDecoration`, `getBorderlessAmountDecoration` (large amount entry), `getSearchPillDecoration` (28dp pill search field).

Always match these tokens instead of hardcoding spacing/shape/text values.

## Utilities

- **`Debouncer`** (`lib/utils/debounce.dart`) — `Debouncer(duration: ...)`; `.call(callback)` cancels+reschedules, `.cancel()`/`.dispose()`. Typical use: debounced search-as-you-type.

## Dependencies

Local: `caravella_core` only. Third-party: `fl_chart`, `flutter_map` + `latlong2`, `intl`, `timeago`, `zentoast` (toast backend). Bundles its own `Montserrat` font (`assets/fonts/`), used as the app-wide default font family.

## See also

- [caravella_core reference](PACKAGE_CARAVELLA_CORE.md)
- [Location & Maps](LOCATION_AND_MAPS.md)
- [Architecture Overview](ARCHITECTURE.md)
