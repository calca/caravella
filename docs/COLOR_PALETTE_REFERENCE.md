# Color Palette Visual Reference

## Palette Index to Semantic Color Mapping

| Index | Light Mode Color Scheme | Dark Mode Color Scheme |
|-------|------------------------|------------------------|
| 0     | primary                | primary                |
| 1     | tertiary               | tertiary               |
| 2     | secondary              | secondary              |
| 3     | errorContainer         | errorContainer         |
| 4     | primaryContainer       | primaryContainer       |
| 5     | secondaryContainer     | secondaryContainer     |
| 6     | primaryFixedDim        | primaryFixedDim        |
| 7     | secondaryFixedDim      | secondaryFixedDim      |
| 8     | tertiaryFixed          | tertiaryFixed          |
| 9     | error                  | error                  |
| 10    | outlineVariant         | outlineVariant         |
| 11    | inversePrimary         | inversePrimary         |

## Example: Default Theme Colors

### Light Mode (default theme)
- Index 0 (primary): `#009688` (teal)
- Index 1 (tertiary): `#BF4A50` (muted red)
- Index 2 (secondary): `#FF4F58` (bright red)

### Dark Mode (default theme)
- Index 0 (primary): `#80CBC4` (light teal)
- Index 1 (tertiary): `#F75F67` (bright coral)
- Index 2 (secondary): `#FC6E75` (light red)

## Usage Flow

### Creating a New Group
1. User opens color picker
2. Sees 12 colors (from current theme's ColorScheme)
3. Selects a color (e.g., primary)
4. **Stored:** Index `0` (not the ARGB value!)

### Viewing the Group
1. App loads group with `color: 0`
2. Detects it's a palette index (0-11)
3. Resolves: `ExpenseGroupColorPalette.resolveColor(0, colorScheme)`
4. **Light mode:** Returns `#009688`
5. **Dark mode:** Returns `#80CBC4`

### Legacy Groups
1. App loads group with `color: 0xFF009688`
2. Detects it's a legacy ARGB value (> 11)
3. Displays: `Color(0xFF009688)` directly
4. **Both modes:** Show exact same teal `#009688`

## Visual Example

```
┌─────────────────────────────────────────────────────────┐
│                    COLOR PICKER                         │
├─────────────────────────────────────────────────────────┤
│  Light Mode:                                            │
│  ┌───┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐                  │
│  │ 0 │ │ 1 │ │ 2 │ │ 3 │ │ 4 │ │ 5 │                  │
│  │🟢 │ │🔴 │ │🔴 │ │🟠 │ │🟢 │ │🔴 │ <-- User picks 0  │
│  └───┘ └───┘ └───┘ └───┘ └───┘ └───┘                  │
│  ┌───┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐                  │
│  │ 6 │ │ 7 │ │ 8 │ │ 9 │ │10 │ │11 │                  │
│  │🟢 │ │🔴 │ │🔴 │ │🔴 │ │⚫ │ │🟢 │                  │
│  └───┘ └───┘ └───┘ └───┘ └───┘ └───┘                  │
└─────────────────────────────────────────────────────────┘
                      ↓ Stored as: 0

┌─────────────────────────────────────────────────────────┐
│                   GROUP CARD                            │
├─────────────────────────────────────────────────────────┤
│  Light Mode:          │  Dark Mode:                     │
│  ┌──────────────┐     │  ┌──────────────┐              │
│  │              │     │  │              │              │
│  │   🟢 Teal    │     │  │   🟦 Lt Teal │              │
│  │  (#009688)   │     │  │  (#80CBC4)   │              │
│  │              │     │  │              │              │
│  │  Trip Name   │     │  │  Trip Name   │              │
│  └──────────────┘     │  └──────────────┘              │
│                       │                                 │
│  ✅ Good contrast     │  ✅ Good contrast               │
└─────────────────────────────────────────────────────────┘
```

## Benefits

✅ **Theme Consistency**: Colors match the app's theme aesthetic  
✅ **Readability**: Proper contrast in both light and dark modes  
✅ **Material 3**: Uses semantic color roles from Material Design  
✅ **Backward Compatible**: Existing colors continue to work  
✅ **Future-proof**: New themes automatically work with existing groups
