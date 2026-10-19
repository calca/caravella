# Package: `caravella_core_ui`

Shared design-system package: reusable widgets, themes, map building blocks. Depends only on `caravella_core` among local packages (see [Architecture Overview](ARCHITECTURE.md)). Import as a whole: `import 'package:caravella_core_ui/caravella_core_ui.dart';` — avoid deep-importing individual widget files.

**Before building any new screen, dialog, card, or chart in `lib/`, check here first.** This page is the catalog.

## Widgets (`lib/widgets/`)

| Widget | Solves | Key params |
|---|---|---|
| `BaseCard` | Generic content card: flat/bordered, plain color, or background image + gradient overlay | `backgroundColor`, `backgroundImage` (a **file path**, not asset/URL), `backgroundGradient`, `isFlat`, `noBorder`, `borderRadius` (default 16), `semanticLabel`, `mergeSemantics` (default `true`: a tappable card is announced as one button; pass `false` when the card hosts its own buttons/tappable rows so they stay individually reachable by screen readers — the caller then exposes the card's main action on a child, as `GroupCard` does on its header) |
| `CaravellaBottomSheetScaffold` | Standard modal-bottom-sheet wrapper: drag handle, optional title, consistent padding | `title`, `padding` (default `EdgeInsets.fromLTRB(20,20,20,24)`), `scrollable`, `showHandle` |
| `FloatingNavBar` / `FloatingNavItem` / `FloatingNavAction` | Floating pill navigation drawn over page content: unselected destinations show their icon, the selected one sits on a tonal pill with its label sliding out; changing selection slides the pill to the new destination and bounces its icon (one `AnimationController` drives widths, pill and label, labels measured with `TextPainter`; instant with `disableAnimations`); optional round primary-action button beside it (the only colored element). Neutral colors from surface roles (`pillColor`/`selectedColor`). Screen readers get label + selected state + tap on each destination | `items`, `selectedIndex`, `onSelected`, `action`; reserve `FloatingNavBar.reservedHeight` (+ bottom inset) at the end of scrollable content |
| `SectionHeader` | Title + optional description + trailing action, with optional required-field asterisk | `title`, `description`, `trailing`, `requiredMark`, `showRequiredHint` |
| `SettingsCard` | Semantics-aware settings row, built on `BaseCard` | `context`, `child`, `semanticsButton`, `semanticsLabel`, `semanticsHint`, `semanticsToggled`, `color` |
| `SettingsSection` | `SectionHeader` + padded content column, for grouping `SettingsCard`s | `title`, `description`, `children`, `headerPadding`, `contentPadding` |
| `CaravellaAppBar` | Flat `AppBar` with **no title slot** (content lives below, e.g. home-like/settings pages) — semantic labels for a11y. Not for pages that need a visible page title: it hardcodes `title: null` | `actions`, `leading`, `headerSemanticLabel`, `backButtonSemanticLabel` |
| `SearchAppBar` | `AppBar` hosting an inline search `TextField` in a pill background (Gmail-style), transparent status bar tuned to theme brightness | `controller`, `hintText`, `onChanged`, `focusNode`, `suffixIcon`, `autofocus` |
| `CaravellaTabBar` | Standardized `TabBar` styling | `tabs`, `controller` (or wrap in `DefaultTabController`), `isScrollable` |
| `BottomActionBar` | Sticky bottom bar with one full-width `FilledButton` | `onPressed`, `label` (auto-uppercased), `enabled` |
| `AppToast` | Toasts/snackbars — **never call `ScaffoldMessenger.of` directly**, use this | `AppToast.show(context, message, {type: ToastType.info/success/error, duration, icon})` |
| `Material3Dialog` / `Material3Dialogs` | M3-styled dialogs and ready-made confirm/info flows | `Material3Dialogs.showConfirmation({title, content, isDestructive})`, `.showInfo({title, content})` |
| `showSelectionBottomSheet<T>` | Generic picker with inline "add new item" support and duplicate-name checking; `autoStartAdd` opens it straight into the inline-add text field | `items`, `selected`, `itemLabel`, `onAddItemInline`, `autoStartAdd` |
| `ChipSelectorRow<T>` | Horizontally scrolling row of selectable chips for compact single-value pickers; shows up to 4 items (in whatever order the caller passes), collapses the rest behind a "..." chip (label falls back to the hidden selection's name, never a count) that opens `showSelectionBottomSheet`, plus an optional trailing "+" chip for inline add. The row is 48dp tall and chips use `MaterialTapTargetSize.padded`, so every chip (and the "+") is a 48dp touch target while keeping its compact look | `items`, `selected`, `itemLabel`, `onSelected`, `onAddItemInline` |
| `CurrencyDisplay` | Large locale-aware amount + currency-code display | `value`, `currency`, `valueFontSize` (default 54), `showDecimals`; static `formatCurrencyText(...)` for text-only use. Rendered with `Text.rich` (not `RichText`) so the amount follows the system text size |
| `EmptyStateView` | Generic "nothing to show" placeholder: muted icon + message + optional hint | `icon`, `message`, `hint`, `iconSize` (default 48). For a richer animated/emoji empty state (e.g. "no expenses yet"), that's a distinct, deliberately separate pattern — see `lib/home/cards/widgets/group_card_empty_state.dart` in the app layer (used by the group page's empty expense list), not this widget |
| `NoExpense` | Empty-state widget (receipt icon + message) — currently unused in `lib/`, prefer `EmptyStateView` for new call sites unless this one's specific copy fits | `semanticLabel`, `noExpenseLabel`, `addFirstExpenseLabel` (caller supplies localized strings) |
| `ParticipantAvatar` / `ExpenseGroupAvatar` | Circular initials avatar for a participant / an expense group (palette- or legacy-color aware). Screen readers hear the participant's **name**, never the initials (`decorative: true` silences it when the name is already shown beside it); group initials are always excluded, since every caller shows the group title next to the avatar | `participant`/`trip`, `size`, `decorative` (participant only), `backgroundColor` (group only) |
| `ExpenseAmountCard` | Expense row: avatar + title (with optional search-highlight) + category/date + amount | `title`, `amount`, `paidBy`, `category`, `date`, `currency`, `compact`, `fullWidth`, `highlightQuery` |
| `AddFab` | Round 64 dp primary `FloatingActionButton`, same size and shadow as the "+" beside `FloatingNavBar` (the theme's `floatingActionButtonTheme` also makes plain FABs round) | `onPressed`, `icon` (default `Icons.add_rounded`), `tooltip` |
| Expense charts (`DateRangeExpenseChart`, `WeeklyExpenseChart`, `MonthlyExpenseChart`) | Inline line chart of daily totals with a letter badge (D / W / M) | `dailyTotals`, `badgeText`, `semanticLabel`; `height` (40), `showBadge` (off when a surrounding card titles the chart — the semantic label is kept), `color` (line, area at 15 %) |
| `PillSegmentedControl` | Pill segmented control in the floating navigation's style (neutral pill, tonal selected segment); screen readers get label + selected + tap per segment | `labels`, `selectedIndex`, `onChanged`, `expand` (equal widths across the row) |
| `AppSystemUI` | Status/nav bar color + icon-brightness management | Factories: `.surface()`, `.surfaceContainer()`, `.custom()` |
| `PhotoVeil` | A group photo just hinted under the card color (Home card and Groups cards), so text keeps the theme colors | `PhotoVeil(path:, color:)` behind the card content; `alpha` (0.9) keeps `onSurface`, `onSurfaceVariant` and `outline` ≥4.5:1 over a pure white or black photo (checked in `test/themes/theme_contrast_test.dart`) |
| `CardOutline` | Hairline over a card's edge (black 8 % light / white 10 % dark) so cards stand out from the page, also over photos | `CardOutline(borderRadius: …, child: card)`; use `BaseCard(noBorder: true)` inside it |
| `GroupBackgroundUtils` / `GroupBackground` | Computes a group's card background (color/gradient/image) consistently everywhere a group is rendered | `GroupBackgroundUtils.resolve(group, colorScheme)` → feed `.gradient`/`.imagePath` into `BaseCard`. Over a photo the veil (`buildImageScrim`) is `surface` at `imageTextScrimAlpha` (0.7) down to 50 %, then 0.95 at 65 %: text drawn there must use `onSurface` (not `onSurfaceVariant`) to keep ≥4.5:1 on any photo |
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

- **`caravella_themes.dart`** — hand-authored Material 3 `ColorScheme` consts: `lightColorScheme` (primary `0xFF00736A`, a darker shade of the brand teal `0xFF009688` so it passes 4.5:1 as text; the icon/splash keep `0xFF009688`) and `darkColorScheme` (a custom "soft dark" scheme tuned for WCAG AA contrast). `CaravellaThemes.createLightTheme({dynamicColorScheme})` / `createDarkTheme(...)` build full `ThemeData` (Material 3, `AppTypography.fontFamily`, custom text theme, dialog/input decoration themes), supporting Android dynamic color (Material You) with a fallback to the hardcoded scheme's container shades. Text fields use an `outline` underline (≥3:1 non-text contrast), 2 px `primary` when focused. Precomputed statics: `CaravellaThemes.light` / `.dark`. `test/themes/theme_contrast_test.dart` enforces the WCAG AA ratios of both schemes — run it after changing any color. Also defines the `CaravellaSemanticColors` extension on `ColorScheme` — `.success`/`.onSuccess`/`.warning`/`.onWarning`, plus `.raisedSurface` (fill for elements that sit above the `surfaceContainer` page: white in light, `surfaceContainerHighest` in dark — never use `surfaceContainerLowest` for that, it is near-black in dark), contrast-checked (≥4.5:1) against `surface` in both themes — use these instead of ad hoc `Colors.green`/`Colors.amber` for "ok/attention" status (there's no `.error` counterpart: Material 3's own `ColorScheme.error`/`.onError` already cover that role).
- **`app_text_styles.dart`** — `AppTypography.fontFamily` (`'Montserrat'`), the single source of truth for the app font family — never hardcode the string elsewhere. `AppTextStyles` convenience tokens: `sectionTitle`, `listItem`, `listItemStrong`, `subtle` (all derived from `Theme.of(context).textTheme`), plus non-theme-derived `static const TextStyle` tokens for fixed-background contexts: `mediaOverlayMessage`/`mediaOverlayCaption` (white text over the fixed black background of image/video/PDF viewers) and `emojiDisplay` (72pt, the wizard's emoji picker steps).
- **`app_dimens.dart`** — `AppDimens.minTouchTarget` (48.0) / `.minTouchTargetCompact` (44.0) / `.minTouchTargetInline` (24.0, WCAG 2.5.8 floor for targets embedded in a text flow), the shared touch-target constants. Prefer these over hardcoding `Size(48, 48)`/`44`/etc. on `styleFrom(minimumSize: ...)`.
- **`app_spacing.dart`** — `AppSpacing` padding/gap scale derived from the values already dominant in the app (`xxs`=4, `xs`=8, `sm`=12, `md`=16, `lg`=20, `xl`=24, `xxl`=32). Use these instead of hardcoding `EdgeInsets`/`SizedBox` numbers in new shared components; existing call sites are migrated incrementally (see `plan.todo.ds.md`), not all at once.
- **`app_radius.dart`** — `AppRadius` corner-radius scale (`xs`=4, `sm`=8, `md`=12, `lg`=16, `dialog`=28 — the Material 3 large-shape dialog radius, used by `Material3Dialog` and `CaravellaThemes`' dialog theme). `BaseCard`'s default radius is `AppRadius.lg`.
- **`form_theme.dart`** — `FormTheme` spacing constants (`fieldSpacing`, `sectionSpacing`, ...) aliased to `AppSpacing` so form spacing stays in sync with the rest of the scale, plus `iconSpacing` (6.0, inline icon-to-text gap fine-tuned for forms — intentionally not on the general scale) and decoration builders: `getStandardDecoration`, `getMultilineDecoration`, `getBorderlessDecoration` (all three accept an optional `labelText` alongside `hintText` — prefer it for real form fields, since a hint alone disappears once the user types, see WCAG 3.3.2), `getBorderlessAmountDecoration` (large amount entry, hint-only by design), `getSearchPillDecoration` (28dp pill search field, hint-only by design). The standard, multiline and borderless decorations set `constraints: BoxConstraints(minHeight: FormTheme.minFieldHeight)` (48dp) so dense fields still meet the minimum touch target.

Text: prefer `Text.rich` over `RichText` — `RichText` ignores the system text size unless given a `textScaler`. Light-theme `outline` (#666666) doubles as the secondary-text color and is ≥4.5:1 on every light surface (WCAG AA); don't use `onSurface`/`onSurfaceVariant` at low alpha for readable text.

Always match these tokens instead of hardcoding spacing/shape/text values. `validate_design_tokens.sh` guards the highest-risk regressions (see `plan.todo.ds.md`) in CI.

## Utilities

- **`Debouncer`** (`lib/utils/debounce.dart`) — `Debouncer(duration: ...)`; `.call(callback)` cancels+reschedules, `.cancel()`/`.dispose()`. Typical use: debounced search-as-you-type.

## Dependencies

Local: `caravella_core` only. Third-party: `fl_chart`, `flutter_map` + `latlong2`, `intl`, `timeago`, `zentoast` (toast backend). Bundles its own `Montserrat` font (`assets/fonts/`), used as the app-wide default font family.

## See also

- [caravella_core reference](PACKAGE_CARAVELLA_CORE.md)
- [Location & Maps](LOCATION_AND_MAPS.md)
- [Architecture Overview](ARCHITECTURE.md)
