# UI Mockups for Expense Filters

## 1. Default View (Filters Collapsed)
```
┌─────────────────────────────────────────────────────┐
│ ← [Trip Name]                           ⋮ ↻ [+]     │
├─────────────────────────────────────────────────────┤
│ [Summary Info - Total, Actions, etc.]              │
├─────────────────────────────────────────────────────┤
│ Attività                              🔍 [filter]   │
│                                                     │
│ ┌─────────────────────────────────────────────────┐ │
│ │ 🍕 Pizza dinner                           €25.50│ │
│ │ 👤 Alice  🏷️ Food                              │ │
│ │ Today, 14:30                                  │ │
│ └─────────────────────────────────────────────────┘ │
│                                                     │
│ ┌─────────────────────────────────────────────────┐ │
│ │ 🚌 Bus ticket                             €5.00│ │
│ │ 👤 Bob  🏷️ Transport                           │ │
│ │ Today, 13:30                                  │ │
│ └─────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────┘
```

## 2. Filters Expanded
```
┌─────────────────────────────────────────────────────┐
│ ← [Trip Name]                           ⋮ ↻ [+]     │
├─────────────────────────────────────────────────────┤
│ [Summary Info - Total, Actions, etc.]              │
├─────────────────────────────────────────────────────┤
│ Attività                     [Pulisci] [filter_off] │
│                                                     │
│ ┌─────────────────────────────────────────────────┐ │
│ │ 🔍 │ Cerca per nome o nota...              │ │
│ └─────────────────────────────────────────────────┘ │
│                                                     │
│ Categoria                                           │
│ [Tutte] [Food] [Transport] [Accommodation]          │
│                                                     │
│ Pagato da                                           │
│ [Tutti] [Alice] [Bob] [Charlie]                     │
│                                                     │
│ ┌─────────────────────────────────────────────────┐ │
│ │ 🍕 Pizza dinner                           €25.50│ │
│ │ 👤 Alice  🏷️ Food                              │ │
│ │ Today, 14:30                                  │ │
│ └─────────────────────────────────────────────────┘ │
│                                                     │
│ ┌─────────────────────────────────────────────────┐ │
│ │ 🚌 Bus ticket                             €5.00│ │
│ │ 👤 Bob  🏷️ Transport                           │ │
│ │ Today, 13:30                                  │ │
│ └─────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────┘
```

## 3. Active Filters with Results
```
┌─────────────────────────────────────────────────────┐
│ ← [Trip Name]                           ⋮ ↻ [+]     │
├─────────────────────────────────────────────────────┤
│ [Summary Info - Total, Actions, etc.]              │
├─────────────────────────────────────────────────────┤
│ Attività (1/3)                   [Pulisci] [filter] │
│                                                     │
│ ┌─────────────────────────────────────────────────┐ │
│ │ 🔍 │ pizza                                 ❌│ │
│ └─────────────────────────────────────────────────┘ │
│                                                     │
│ Categoria                                           │
│ [Tutte] [●Food] [Transport] [Accommodation]         │
│                                                     │
│ Pagato da                                           │
│ [Tutti] [Alice] [Bob] [Charlie]                     │
│                                                     │
│ ┌─────────────────────────────────────────────────┐ │
│ │ 🍕 Pizza dinner                           €25.50│ │
│ │ 👤 Alice  🏷️ Food                              │ │
│ │ Today, 14:30                                  │ │
│ └─────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────┘
```

## 4. No Results Found
```
┌─────────────────────────────────────────────────────┐
│ ← [Trip Name]                           ⋮ ↻ [+]     │
├─────────────────────────────────────────────────────┤
│ [Summary Info - Total, Actions, etc.]              │
├─────────────────────────────────────────────────────┤
│ Attività (0/3)                   [Pulisci] [filter] │
│                                                     │
│ ┌─────────────────────────────────────────────────┐ │
│ │ 🔍 │ xyz                                   ❌│ │
│ └─────────────────────────────────────────────────┘ │
│                                                     │
│ Categoria                                           │
│ [Tutte] [Food] [Transport] [Accommodation]          │
│                                                     │
│ Pagato da                                           │
│ [Tutti] [●Alice] [Bob] [Charlie]                    │
│                                                     │
│                     🔍⃠                              │
│                                                     │
│         Nessuna spesa trovata con i                 │
│         filtri selezionati                          │
└─────────────────────────────────────────────────────┘
```

## Key UI Elements:

### Icons:
- 🔍 = search/filter icon
- [filter] = filter_list icon (outlined)
- [filter_off] = filter_list_off icon
- ❌ = clear search icon
- 🔍⃠ = search_off icon for empty state
- ● = selected filter chip (filled)
- [ ] = unselected filter chip (outlined)

### Interactive Elements:
- [Pulisci] = Clear all filters button (appears when filters active)
- Search field = Real-time filtering as user types
- Filter chips = Toggle on/off with visual feedback
- Count display = Shows "(filtered/total)" when filters active

### States:
1. **Default**: Filters collapsed, all expenses shown
2. **Expanded**: Filter controls visible but no filters applied
3. **Filtered**: Active filters with some results
4. **Empty**: Active filters but no matching results

### Design Notes:
- Material 3 design language
- Consistent with existing app styling
- Proper spacing and alignment
- Clear visual hierarchy
- Responsive layout
- Italian text labels