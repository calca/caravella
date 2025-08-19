# Location Feature UI Description

## Visual Layout

The location input appears in the expense form after the note field, following this pattern:

```
┌─────────────────────────────────────────┐
│ Expense Name: [________________]        │
├─────────────────────────────────────────┤
│ Amount: [________________]              │
├─────────────────────────────────────────┤
│ Paid by: [Dropdown ▼]                   │
├─────────────────────────────────────────┤
│ Category: [Dropdown ▼]                  │
├─────────────────────────────────────────┤
│ Date: [📅 Select date]                  │
├─────────────────────────────────────────┤
│ Note:                                   │
│ [________________                       │
│  ________________]                      │
├─────────────────────────────────────────┤
│ Location:               📍 🗑️           │
│ [________________]                      │
├─────────────────────────────────────────┤
│          [Cancel] [Save]                │
└─────────────────────────────────────────┘
```

## Button Functions

- **📍 (Location Button)**: 
  - Tap to get current GPS location
  - Shows spinner while loading
  - Fills field with coordinates
  
- **🗑️ (Clear Button)**:
  - Only appears when location is set
  - Clears the location field
  - Resets location data

## States

### Empty State
```
Location:                    📍
[Enter location (optional)]
```

### Manual Entry
```
Location:                📍 🗑️
[Milano, Italy         ]
```

### GPS Loading
```
Location:                ⟳ 🗑️
[Getting location...   ]
```

### GPS Result
```
Location:                📍 🗑️
[45.464200, 9.190000  ]
```

## User Flow

1. User opens expense form
2. Scrolls to location field (after note)
3. Either:
   - Types location name manually, OR
   - Taps GPS button to get current location
4. Saves expense with location data
5. Location appears in expense details and CSV exports

## Responsive Behavior

- Field width adapts to screen size
- Buttons maintain consistent spacing
- Loading indicators show appropriate feedback
- Error messages appear as snackbars