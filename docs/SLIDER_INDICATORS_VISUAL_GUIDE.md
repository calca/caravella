# Home Slider Page Indicators - Visual Guide

## What Changed

### Before
The home screen slider showed group cards but had no visual indication of:
- Which page/card is currently active
- How many total pages exist
- Position within the slider

This made it difficult for users (especially those with visual impairments) to understand their navigation context.

### After
Now the slider includes animated page indicators below the cards:

```
       ⚫  ⚪  ⚪  ⚪
```

- **Filled dot (⚫)**: Current active page
- **Outlined dots (⚪)**: Other available pages
- Smooth animation as you swipe between pages
- Screen reader announces: "Page 2 of 4" when navigating

## Visual Representation

```
┌─────────────────────────────────────────┐
│         Home Screen                     │
├─────────────────────────────────────────┤
│  ┌───────┐                              │
│  │ Avatar│  Welcome back!               │
│  └───────┘                              │
│                                         │
│  ┌──────────┐  ┌──────────┐            │
│  │  Trip 1  │  │  Trip 2  │            │
│  │  Card    │  │  Card    │  ◄─ Swipe  │
│  └──────────┘  └──────────┘            │
│                                         │
│       ⚫  ⚪  ⚪  ⚪  ◄─ NEW!          │
│                                         │
│  [Bottom Navigation Bar]                │
└─────────────────────────────────────────┘
```

## Accessibility Features

### Visual Users
- Clear indication of current page position
- Smooth animations provide visual feedback
- Color contrast meets WCAG AA standards
- Dots scale and fade based on distance from active page

### Screen Reader Users
- Automatic announcements when page changes
- Clear semantic label: "Page X of Y"
- Live region updates without requiring focus
- No interference with card content

### Keyboard Users
- Indicators update automatically when using keyboard navigation
- Focus remains on cards, not indicators
- No additional tab stops required

## Technical Details

### Design
- **Size**: 8px dots (active), 5.6px (inactive, 70% scale)
- **Spacing**: 8px between dots
- **Colors**: 
  - Active: Theme primary color
  - Inactive: OnSurface with 20% opacity
- **Animation**: 200ms ease-in-out
- **Position**: 12px below slider, 8px above bottom bar

### Behavior
- Updates in real-time as user swipes
- Supports fractional page positions (smooth scrolling)
- Works with any number of pages (1 to N)
- Automatically includes the "new group" card in count

## WCAG 2.2 Compliance

✅ **1.3.1 Info and Relationships** - Clear visual relationship between indicators and slider  
✅ **2.4.6 Headings and Labels** - Descriptive labels for screen readers  
✅ **4.1.2 Name, Role, Value** - Proper semantic structure  
✅ **Live Regions** - Dynamic updates announced to assistive technologies

## Files Modified

1. **lib/home/cards/widgets/page_indicator.dart** (NEW) - 79 lines
2. **lib/home/cards/widgets/horizontal_groups_list.dart** (MODIFIED)
3. **lib/home/cards/widgets/widgets.dart** (MODIFIED)
4. **test/page_indicator_test.dart** (NEW) - 102 lines, 4 tests
5. **validate_accessibility.sh** (MODIFIED)

## Testing

### Manual Testing
1. Open the app and navigate to home screen
2. Observe page indicators below group cards
3. Swipe left/right through cards
4. Verify dots animate to show active page

### With Screen Reader
1. Enable TalkBack/VoiceOver
2. Swipe through group cards
3. Listen for "Page 1 of 3", "Page 2 of 3" announcements

### Automated Tests
```bash
flutter test test/page_indicator_test.dart
```

## Impact Summary

✅ Better navigation awareness for all users  
✅ WCAG 2.2 Level AA compliant  
✅ Screen reader friendly  
✅ Material 3 design consistency  
✅ Minimal performance impact  
✅ Well-tested and documented  
