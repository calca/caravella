# Theme-Aware Expense Group Colors

## Problem

Previously, expense group colors were stored as absolute ARGB color values (e.g., `0xFF009688` for teal). When a user selected a color from the theme's color palette in light mode, that exact color value was saved. When switching to dark mode, the same color would be displayed, which could result in:

- Poor contrast and visibility in dark mode
- Colors that don't match the dark theme aesthetic
- Inconsistent color experience across themes

## Solution

We've implemented a theme-aware color palette system that:

1. **Stores colors as palette indices** (0-11) instead of ARGB values
2. **Resolves colors at runtime** based on the current theme
3. **Maintains backward compatibility** with existing ARGB color values

### How It Works

#### Color Palette

The `ExpenseGroupColorPalette` class defines a fixed palette of 12 semantic colors that adapt to the theme:

```dart
static List<Color> _getPaletteColors(ColorScheme colorScheme) {
  return [
    colorScheme.primary,              // Index 0
    colorScheme.tertiary,             // Index 1
    colorScheme.secondary,            // Index 2
    colorScheme.errorContainer,       // Index 3
    colorScheme.primaryContainer,     // Index 4
    colorScheme.secondaryContainer,   // Index 5
    colorScheme.primaryFixedDim,      // Index 6
    colorScheme.secondaryFixedDim,    // Index 7
    colorScheme.tertiaryFixed,        // Index 8
    colorScheme.error,                // Index 9
    colorScheme.outlineVariant,       // Index 10
    colorScheme.inversePrimary,       // Index 11
  ];
}
```

#### Storage

- **New colors**: Stored as palette indices (0-11)
- **Legacy colors**: Existing ARGB values (e.g., 0xFF009688) continue to work

#### Resolution

When displaying a color:

```dart
if (ExpenseGroupColorPalette.isLegacyColorValue(colorValue)) {
  // Use the legacy ARGB value as-is
  displayColor = Color(colorValue);
} else {
  // Resolve from palette using current theme
  displayColor = ExpenseGroupColorPalette.resolveColor(
    colorValue,
    Theme.of(context).colorScheme,
  ) ?? fallbackColor;
}
```

### Example

**Before:**
- User selects teal (`0xFF009688`) in light mode
- Color is stored as `0xFF009688`
- Same teal displays in dark mode (may have poor contrast)

**After:**
- User selects primary color (palette index 0) in light mode
- Index `0` is stored
- In light mode: Resolves to light theme's primary color (teal)
- In dark mode: Resolves to dark theme's primary color (lighter teal with better contrast)

### Migration

Existing expense groups with ARGB color values will continue to work as before. When a group is edited and a new color is selected, it will use the new palette index system. No automatic migration is performed to preserve user expectations.

### Files Modified

1. **`packages/caravella_core/lib/model/expense_group_color_palette.dart`** (new)
   - Core color palette logic

2. **`lib/manager/group/widgets/background_picker.dart`**
   - Color picker now stores palette indices
   - Preview resolves colors from palette

3. **`lib/home/cards/widgets/group_card.dart`**
   - Group card display resolves colors from palette

4. **`lib/manager/details/widgets/group_header.dart`**
   - Group avatar resolves colors from palette

### Testing

A comprehensive test suite in `test/expense_group_color_palette_test.dart` verifies:
- Palette size and structure
- Color resolution for valid/invalid indices
- Theme-specific color resolution
- Legacy vs palette index detection
- Color migration logic
- Consistency across multiple calls
