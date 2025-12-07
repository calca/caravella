# Markdown Export Feature

## Overview

The Markdown export feature allows users to export their expense groups in Markdown format (.md), which provides a human-readable and well-structured summary of the group expenses.

## Features

The Markdown export includes:

1. **Group Header**: Title and basic information
   - Group title
   - Period (start and end dates if set)
   - Currency
   - Number of participants

2. **Statistics Section**: Group-level statistics
   - Total expenses
   - Number of expenses
   - Expenses by participant (amount paid by each)
   - Expenses by category (total per category)
   - Settlement information (who owes whom)

3. **Expenses Table**: Complete list of all expenses
   - Description
   - Amount
   - Paid by
   - Category
   - Date

## Usage

Users can export and share expense groups in Markdown format from the Export Options menu:

1. Open an expense group
2. Tap on the export/share button
3. Choose one of the Markdown options:
   - **Share all (Markdown)**: Share the .md file via system share sheet
   - **Download all (Markdown)**: Save the .md file to a selected directory

## File Format

Exported files are named using the pattern: `YYYYMMDD_[group_title]_export.md`

Example: `20241207_summer_vacation_export.md`

## Sample Output

```markdown
# Summer Vacation 2024

**Period**: 2024-07-01 - 2024-07-15

**Currency**: €

**Participants**: 3

## Statistics

**Total expenses**: €1,250.00

**Number of expenses**: 8

### By participant

- **Alice**: €600.00
- **Bob**: €450.00
- **Charlie**: €200.00

### By category

- **Accommodation**: €500.00
- **Food**: €400.00
- **Transport**: €250.00
- **Entertainment**: €100.00

### Settlement

- **Bob** → **Alice**: €33.33
- **Charlie** → **Alice**: €183.33

## Expenses

| Description | Amount | Paid by | Category | Date |
|---|---|---|---|---|
| Hotel booking | €500.00 | Alice | Accommodation | 2024-07-01 |
| Dinner at restaurant | €120.00 | Bob | Food | 2024-07-02 |
| Train tickets | €150.00 | Alice | Transport | 2024-07-03 |
...
```

## Technical Details

### Implementation

- **Exporter Class**: `lib/manager/details/export/markdown_exporter.dart`
- **Integration**: Added to `ExportOptionsSheet` and `ExpenseGroupDetailPage`
- **Localization**: Fully localized in all supported languages (EN, IT, ES, PT, ZH)

### Special Character Handling

The exporter properly escapes special Markdown characters:
- Pipe characters (`|`) in table cells
- Backslashes (`\`)
- Line breaks in text fields

### Settlement Calculation

Settlement calculations use the same logic as the overview page, ensuring consistency across the app.

## Testing

Unit tests are provided in `test/markdown_export_test.dart` covering:
- Filename generation
- Empty group handling
- Content generation with all sections
- Special character escaping
