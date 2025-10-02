# Store Rating Feature

## Overview

The in-app rating feature prompts users to rate Caravella on their respective app stores (Google Play Store or Apple App Store) to gather user feedback and improve app visibility.

## Behavior

### Initial Rating Prompt
- **Trigger**: After the user adds their **10th expense** (cumulative across all groups)
- **Frequency**: Once only, when the threshold is reached
- **Tracking**: The system tracks total expenses added across all expense groups

### Subsequent Rating Prompts
- **Frequency**: Once per month (minimum 30-day gap between prompts)
- **Condition**: Only shown if it has been at least 30 days since the last rating prompt was shown
- **No limit**: The monthly prompt will continue indefinitely (but respects the 30-day gap)

## Technical Implementation

### Components

#### 1. RatingService (`lib/data/services/rating_service.dart`)
Main service that handles the rating logic:
- `checkAndPromptForRating()`: Checks conditions and shows rating dialog if appropriate
- `openStoreForRating()`: Manually opens store for rating (for testing or user-initiated actions)
- `resetRatingState()`: Resets all rating preferences (useful for testing)

#### 2. PreferencesService Updates
New preferences added to track rating state:
- `total_expense_count`: Total number of expenses added across all groups
- `last_rating_prompt`: Timestamp of the last time rating prompt was shown
- `has_shown_initial_rating`: Boolean flag indicating if initial rating has been shown

### Integration Points

The rating check is integrated at these locations where expenses are added:

1. **ExpenseGroupDetailPage** (`lib/manager/details/pages/expense_group_detail_page.dart`)
   - When adding a new expense to an existing group
   
2. **GroupCardContent** (`lib/home/cards/widgets/group_card_content.dart`)
   - When adding a quick expense from the home page card

### Flow Diagram

```
User adds expense
    ↓
Expense saved successfully
    ↓
RatingService.checkAndPromptForRating()
    ↓
Is in-app review available? ──No──> Exit
    ↓ Yes
Count total expenses across all groups
    ↓
Update total_expense_count preference
    ↓
Should show rating prompt?
    ├─ Total < 10 expenses? ──Yes──> Exit
    ├─ Initial not shown & Total >= 10? ──Yes──> Show Rating Dialog
    └─ Initial shown & 30+ days since last? ──Yes──> Show Rating Dialog
    ↓
Update last_rating_prompt timestamp
Update has_shown_initial_rating flag
```

## Dependencies

- **Package**: `in_app_review` (^2.0.10)
- **Platform Support**: 
  - Android: minSdkVersion 21+
  - iOS: 10.3+
  - Web: Not supported (gracefully degrades)
  - Desktop: Not supported (gracefully degrades)

## User Experience

### Native Dialog
- Uses the **native system rating dialog** provided by the platform
- On Android: Google Play in-app review API
- On iOS: StoreKit's SKStoreReviewController
- Automatically translated to user's system language
- User can rate directly without leaving the app

### Non-intrusive Design
- Rating check runs asynchronously (does not block user flow)
- Fails gracefully if review API is unavailable
- Logs warnings but never shows error to user
- Never interrupts critical user actions

## Testing

### Manual Testing Scenarios

1. **First-time user flow**:
   - Create a new group
   - Add 9 expenses → No rating prompt
   - Add 10th expense → Rating prompt appears
   - Add 11th expense → No rating prompt (already shown)

2. **Monthly prompt flow**:
   - After initial rating shown, wait 29 days
   - Add expense → No rating prompt
   - Wait 1 more day (30 days total)
   - Add expense → Rating prompt appears

3. **Platform availability**:
   - Test on Android device → Native Google Play dialog
   - Test on iOS device → Native App Store dialog
   - Test on web/desktop → Gracefully skips (logs info)

### Testing Utilities

```dart
// Reset rating state for testing
import 'package:io_caravella_egm/data/services/rating_service.dart';

await RatingService.resetRatingState();
```

### Unit Tests

Location: `test/rating_service_test.dart`

Tests cover:
- Preference storage and retrieval
- Initial state (defaults)
- Multiple updates
- Timestamp handling

## Monitoring

The service uses `LoggerService` for tracking:
- Info: When rating prompt is shown
- Info: When in-app review is not available
- Warning: When errors occur during rating check

Example logs:
```
[rating] Showing rating prompt at 10 expenses
[rating] In-app review not available on this platform
[rating] Error checking/prompting for rating: ...
```

## Privacy & App Store Guidelines

### Compliance
- ✅ Uses official in-app review APIs (complies with store policies)
- ✅ Non-intrusive timing (after significant user engagement)
- ✅ Reasonable frequency (30-day gap between prompts)
- ✅ No custom UI (uses native dialogs only)

### App Store Review Guidelines
- Follows Apple's guidelines for SKStoreReviewController
- Follows Google Play's guidelines for in-app reviews
- Does not incentivize ratings
- Does not ask for positive ratings specifically

## Future Enhancements

Potential improvements for consideration:
- Make thresholds configurable (currently hardcoded)
- Add A/B testing capability for optimal timing
- Track rating outcomes (rated vs. dismissed)
- Add more sophisticated triggers (e.g., after positive actions)
- Internationalized custom prompts (if using custom UI in the future)

## Troubleshooting

### Rating prompt not showing
1. Check platform support (iOS 10.3+, Android API 21+)
2. Verify expense count: `await PreferencesService.getTotalExpenseCount()`
3. Check if initial rating shown: `await PreferencesService.getHasShownInitialRating()`
4. Verify time gap: `await PreferencesService.getLastRatingPrompt()`
5. Check logs for any warnings

### Testing on simulator/emulator
- iOS Simulator: Rating dialog may not appear (limitation of simulator)
- Android Emulator: May require Google Play Services installed
- Recommendation: Test on real devices for accurate behavior

## References

- [in_app_review package](https://pub.dev/packages/in_app_review)
- [Google Play In-App Reviews](https://developer.android.com/guide/playcore/in-app-review)
- [Apple StoreKit Review Controller](https://developer.apple.com/documentation/storekit/skstorereviewcontroller)
