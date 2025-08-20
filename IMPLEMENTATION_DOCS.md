# Home Page Content Card - Extra Info Implementation

## Overview
This implementation adds extra information to the home page content cards when the trip duration is less than 30 days, as requested in issue #17.

## Changes Made

### 1. Core Logic (`lib/home/cards/widgets/group_card_content.dart`)

Added three new methods:

- **`_isShortDuration(ExpenseGroup group)`**: Determines if a trip duration is less than 30 days
- **`_calculateDailyAverage(ExpenseGroup group)`**: Calculates daily average spending
- **`_calculateTodaySpending(ExpenseGroup group)`**: Calculates today's total spending
- **`_buildExtraInfo(ExpenseGroup group)`**: Builds the UI component for the extra information

### 2. UI Integration

The extra info is displayed:
- **When**: Only for trips with duration < 30 days
- **Where**: Before the charts in the statistics section
- **Style**: Right-aligned text using chart colors (onSurfaceVariant with alpha 0.7)

### 3. Localization (`lib/app_localizations.dart`)

Added new localization keys:
- `daily_average`: "Media giornaliera" (IT) / "Daily average" (EN)
- `spent_today`: "Speso oggi" (IT) / "Spent today" (EN)

### 4. Testing (`test/home_extra_info_test.dart`)

Comprehensive test coverage for:
- Duration detection logic
- Daily average calculation
- Today's spending calculation
- Edge cases (no expenses, no dates)

## Visual Result

![Before and After Comparison](docs_home_card_extra_info_mockup.png)

The mockup shows:
- **Before**: Standard card without extra info
- **After**: Card with daily average and today's spending displayed for short trips

## Business Logic

### Duration Threshold
- **< 30 days**: Show extra info
- **≥ 30 days**: Hide extra info
- **No dates**: Hide extra info

### Daily Average Calculation
- **With dates**: Total spending ÷ (days from start to min(end, today))
- **Without dates**: Total spending ÷ (days from first expense to today)

### Today's Spending
- Sum of all expenses from the current date

## Implementation Notes

1. **Performance**: Calculations are performed only when needed (short duration trips)
2. **Internationalization**: Fully localized for Italian and English
3. **Styling**: Matches existing design system with chart colors
4. **Accessibility**: Maintains semantic structure and proper contrast
5. **Data Safety**: Handles edge cases like empty expense lists and null dates

## Testing

Run the validation script:
```bash
python3 /tmp/validate_logic.py
```

This validates the core business logic without requiring Flutter setup.