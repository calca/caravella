# Expense Group Typology Feature

This document describes the new expense group typology feature added to the Caravella app.

## Overview

Users can now assign a type/category to each expense group during creation or modification. Each type has:
- An associated icon for visual identification
- 3 predefined default categories that are auto-populated when the type is selected

## Available Types

### 1. Travel / Vacation (Viaggio / Vacanza)
- **Icon**: ✈️ (flight_takeoff)
- **Default Categories**: 
  - Trasporti (Transportation)
  - Alloggio (Accommodation)
  - Ristoranti (Restaurants)

### 2. Personal (Personale)
- **Icon**: 👤 (person)
- **Default Categories**:
  - Shopping
  - Salute (Health)
  - Intrattenimento (Entertainment)

### 3. Family (Famiglia)
- **Icon**: 👨‍👩‍👧‍👦 (family_restroom)
- **Default Categories**:
  - Spesa (Groceries)
  - Casa (Home)
  - Bambini (Children)

### 4. Other (Altro)
- **Icon**: ⋯ (more_horiz)
- **Default Categories**:
  - Varie (Miscellaneous)
  - Utilità (Utilities)
  - Servizi (Services)

## User Experience

### Group Creation
1. When creating a new group, users see the type selector after the categories section
2. Users can select one of the four available types
3. If categories list is empty, selecting a type automatically populates the 3 default categories
4. Users can then modify, add, or remove categories as needed
5. Type selection is optional - groups can be created without a type

### Group Editing
1. The type selector is shown in the same position
2. Current type is highlighted with a checkmark
3. Changing type does NOT replace existing categories (preserves user data)
4. Users can tap the selected type again to deselect it

## Technical Implementation

### Data Model
- `ExpenseGroupType` enum in `lib/data/model/expense_group_type.dart`
- `groupType` field added to `ExpenseGroup` model (nullable)
- JSON serialization/deserialization support

### UI Components
- `GroupTypeSelector` widget in `lib/manager/group/widgets/group_type_selector.dart`
- Integrated into `ExpensesGroupEditPage` between categories and period sections
- Uses Material 3 design with `SelectionTile` component

### State Management
- `groupType` field added to `GroupFormState`
- `setGroupType()` method in `GroupFormController` handles type selection
- Auto-population of categories happens only when list is empty

### Localization
Translations added for all 5 supported languages:
- Italian (it)
- English (en)
- Spanish (es)
- Portuguese (pt)
- Chinese (zh)

## Testing

Comprehensive test suite in `test/expense_group_type_test.dart` covers:
- Enum functionality (icons, default categories, JSON conversion)
- ExpenseGroup model integration
- JSON serialization and deserialization
- copyWith behavior

## Future Enhancements

Potential improvements for future releases:
1. Display group type icon in the home page cards
2. Filter/sort groups by type in the home view
3. Statistics and analytics broken down by group type
4. Custom categories templates that users can save and reuse
5. Allow users to customize default categories for each type
