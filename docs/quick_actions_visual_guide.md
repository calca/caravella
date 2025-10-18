# Quick Actions Visual Guide

## What the user sees when they long-press the Caravella icon:

```
┌─────────────────────────────────────────┐
│                                         │
│        [Caravella App Icon]             │
│                                         │
│  ┌────────────────────────────────────┐ │
│  │  Caravella                         │ │
│  └────────────────────────────────────┘ │
│                                         │
│  ┌────────────────────────────────────┐ │
│  │  📌 Summer Vacation 2024           │ │  ← Pinned group (always first)
│  │  Add expense                       │ │
│  └────────────────────────────────────┘ │
│                                         │
│  ┌────────────────────────────────────┐ │
│  │  Weekly Shopping                   │ │  ← Most recently updated
│  │  Add expense                       │ │
│  └────────────────────────────────────┘ │
│                                         │
│  ┌────────────────────────────────────┐ │
│  │  Roommate Expenses                 │ │  ← 2nd most recent
│  │  Add expense                       │ │
│  └────────────────────────────────────┘ │
│                                         │
│  ┌────────────────────────────────────┐ │
│  │  Birthday Party                    │ │  ← 3rd most recent
│  │  Add expense                       │ │
│  └────────────────────────────────────┘ │
│                                         │
└─────────────────────────────────────────┘
```

## Shortcut Behavior

### Scenario 1: With Pinned Group
```
Shortcuts (max 4):
1. Pinned Group (📌 emoji prefix)
2. Most recent non-pinned group
3. 2nd most recent non-pinned group
4. 3rd most recent non-pinned group
```

### Scenario 2: Without Pinned Group
```
Shortcuts (max 4):
1. Most recently updated group
2. 2nd most recently updated group
3. 3rd most recently updated group
4. 4th most recently updated group
```

### Scenario 3: Few Groups
```
If you have 2 groups:
1. Group A
2. Group B

(Only 2 shortcuts appear)
```

## User Flow

```
User Action                     System Response
────────────────────────────────────────────────────

1. Long-press app icon    →     Show Quick Actions menu

2. Tap "Summer Vacation" →      App opens/comes to foreground
                                 ↓
                                Navigate to group detail page
                                 ↓
                                Show "Summer Vacation" details
                                 ↓
                                User can tap + to add expense
```

## Visual States

### Empty State (No Groups)
```
┌─────────────────────────────────────────┐
│                                         │
│        [Caravella App Icon]             │
│                                         │
│  ┌────────────────────────────────────┐ │
│  │  Caravella                         │ │
│  └────────────────────────────────────┘ │
│                                         │
│  (No shortcuts available)               │
│                                         │
└─────────────────────────────────────────┘
```

### Single Pinned Group
```
┌─────────────────────────────────────────┐
│                                         │
│        [Caravella App Icon]             │
│                                         │
│  ┌────────────────────────────────────┐ │
│  │  Caravella                         │ │
│  └────────────────────────────────────┘ │
│                                         │
│  ┌────────────────────────────────────┐ │
│  │  📌 Work Expenses                  │ │
│  │  Add expense                       │ │
│  └────────────────────────────────────┘ │
│                                         │
└─────────────────────────────────────────┘
```

## Label Truncation

If a group title is too long, it will be truncated:

```
Original Title:
"Summer Vacation Trip to Europe 2024"

Short Label (25 chars max):
"Summer Vacation Trip ..."

Long Label (125 chars max):
"Add expense to Summer Vacation Trip to Europe 2024"
```

## Icon

All shortcuts use the standard Android "Add" icon:
- Default system icon: `ic_menu_add`
- Appears as a "+" or "Add" icon
- Consistent with material design

## Platform Compatibility

```
Android Version          Quick Actions Support
────────────────────────────────────────────
Android 7.0 or lower    ✗ Not supported
Android 7.1 (API 25)    ✓ Supported
Android 8.0+            ✓ Supported (enhanced)
```

## Notes

- Shortcuts appear instantly when long-pressing
- No animation or loading state
- Tapping outside the menu dismisses it
- Standard Android system behavior
- Works on all launchers that support shortcuts
