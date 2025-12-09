# New Home Page V2 - Real Implementation

Functional home page based on the actual design mockup with compile-time switching.

## Design

The new home page features:

1. **Top Header**: Avatar (left), Search & Settings icons (right)
2. **Balance Summary**: "In totale ti spettano: +XX,XX€" in white card
3. **Featured Group Card**: Large teal gradient card with:
   - Group title with flag emoji
   - "Polso del Gruppo" progress bar
   - Payment status ("Devi dare X€ a...")
   - "Salda la tua parte" button
4. **Altri gruppi attivi**: Horizontal scrollable cards showing other groups
5. **Attività Recente**: Recent expense items with category icons
6. **Bottom FAB**: Floating action button for adding new items

## Compile-Time Switch

The app supports switching between old and new home page at compile time using `--dart-define`:

### Use Old Home Page (Default)

```bash
flutter run
# or
flutter run --dart-define=USE_NEW_HOME=false
```

### Use New Home Page

```bash
flutter run --dart-define=USE_NEW_HOME=true
```

### Build with New Home Page

```bash
# Debug APK
flutter build apk --debug --dart-define=USE_NEW_HOME=true

# Release APK
flutter build apk --release --dart-define=USE_NEW_HOME=true --dart-define=FLAVOR=prod

# With flavor
flutter build apk --flavor prod --release --dart-define=FLAVOR=prod --dart-define=USE_NEW_HOME=true
```

## Implementation Details

### File Structure

```
new_home_v2/
├── real_home_page.dart              (main page)
├── README.md                        (this file)
└── widgets/
    ├── real_home_header.dart        (avatar + search + settings)
    ├── featured_group_card.dart     (large teal card)
    ├── other_groups_section.dart    (horizontal group cards)
    └── recent_activity_section.dart (activity list)
```

### Features

- ✅ Real data integration with `ExpenseGroupStorageV2`
- ✅ Pull-to-refresh
- ✅ Auto-refresh on group updates
- ✅ Balance calculation across all groups
- ✅ Pinned/featured group display
- ✅ Recent activity from all groups
- ✅ Category-based icons and colors
- ✅ Responsive design

### Data Flow

1. Load all active groups from `ExpenseGroupStorageV2`
2. Calculate total balance across all groups
3. Show pinned group as featured card
4. Display other groups in horizontal scroll
5. Aggregate recent expenses from all groups
6. Update on group changes via `ExpenseGroupNotifier`

### Balance Calculation

The balance is calculated per group:
- Positive: User is owed money (green)
- Negative: User owes money (red)
- Zero: Settled (gray)

Total balance = Sum of all group balances

### Navigation

- Tap featured card → Group details
- Tap other group card → Group details
- Search icon → Search (placeholder)
- Settings icon → Settings page
- FAB → Add new (placeholder)

## Switch Implementation

The switch is implemented in `lib/main/caravella_home_page.dart`:

```dart
const bool _useNewHome = bool.fromEnvironment('USE_NEW_HOME', defaultValue: false);

@override
Widget build(BuildContext context) {
  return _useNewHome ? const RealHomePage() : const HomePage();
}
```

This is a compile-time constant, so:
- No runtime overhead
- Dead code elimination by compiler
- Only one page included in final binary

## Testing

### Test Old Home Page
```bash
flutter run
```

### Test New Home Page
```bash
flutter run --dart-define=USE_NEW_HOME=true
```

### VS Code Launch Configuration

Add to `.vscode/launch.json`:

```json
{
  "name": "New Home Page (dev)",
  "request": "launch",
  "type": "dart",
  "args": [
    "--dart-define=FLAVOR=dev",
    "--dart-define=USE_NEW_HOME=true"
  ]
}
```

## Color Scheme

- **Background**: #F5F5F5 (light gray)
- **Featured Card Gradient**: #4ECDC4 → #44A5A0 (teal)
- **Positive Balance**: #2ECC71 (green)
- **Negative Balance**: #E74C3C (red)
- **Cards**: White (#FFFFFF)

## Future Enhancements

- [ ] Real user name from user service
- [ ] Actual navigation to group details
- [ ] Search functionality
- [ ] Filter/sort recent activity
- [ ] Skeleton loaders
- [ ] Animations/transitions
- [ ] Localization of new strings
- [ ] More sophisticated balance calculation
- [ ] Payment settlement flow

## Migration Path

1. **Testing Phase**: Use `USE_NEW_HOME=true` for internal testing
2. **Beta Phase**: Release with flag to select users
3. **A/B Testing**: Monitor engagement metrics
4. **Full Rollout**: Make new home page default
5. **Cleanup**: Remove old home page code

## Notes

- Current user detection is simplified (uses "Tu")
- Balance calculation is basic - may need refinement
- Category icon mapping is limited
- Some navigation is placeholder (shows snackbar)
- Compatible with existing architecture
- No breaking changes to data models
