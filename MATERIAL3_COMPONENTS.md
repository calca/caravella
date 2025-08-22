# Material 3 Advanced Components

This document describes the Material 3 advanced components implemented for the Caravella app, following Material Design 3 specifications and the app's existing design patterns.

## Components Overview

### 1. Material3SegmentedButton

A segmented button implementation for single or multiple selections.

#### Features
- Single and multi-selection modes
- Full-width expansion option
- Helper methods for easy segment creation
- Proper Material 3 styling and theming
- Accessibility support

#### Basic Usage

```dart
import 'package:org_app_caravella/widgets/material3_segmented_button.dart';

// Single selection
Material3SegmentedButton<String>(
  segments: {
    ButtonSegment(value: 'list', label: Text('List'), icon: Icon(Icons.list)),
    ButtonSegment(value: 'grid', label: Text('Grid'), icon: Icon(Icons.grid_view)),
  },
  selected: {'list'},
  onSelectionChanged: (selection) => setState(() => _viewMode = selection),
)

// Multi-selection with helper
Material3SegmentedButton<String>(
  segments: Material3SegmentHelpers.createTextSegments({
    'all': 'All',
    'recent': 'Recent', 
    'favorites': 'Favorites',
  }),
  selected: _filters,
  multiSelectionEnabled: true,
  expandedWidth: true,
  onSelectionChanged: (selection) => setState(() => _filters = selection),
)
```

### 2. Material3MenuAnchor

Context menu implementation with Material 3 styling.

#### Features
- Menu items with icons and text
- Submenus support
- Menu dividers
- Proper Material 3 elevation and colors
- Animation and state management

#### Basic Usage

```dart
import 'package:org_app_caravella/widgets/material3_menu_anchor.dart';

Material3MenuAnchor(
  menuItems: [
    Material3MenuItem(
      text: 'Edit',
      leadingIcon: Icons.edit,
      onPressed: () => _editItem(),
    ),
    Material3MenuItem(
      text: 'Share',
      leadingIcon: Icons.share,
      onPressed: () => _shareItem(),
    ),
    Material3MenuDivider(),
    Material3SubmenuButton(
      text: 'Export',
      leadingIcon: Icons.upload,
      menuItems: [
        Material3MenuItem(text: 'PDF', onPressed: () => _exportPdf()),
        Material3MenuItem(text: 'CSV', onPressed: () => _exportCsv()),
      ],
    ),
  ],
  child: IconButton(
    icon: Icon(Icons.more_vert),
    onPressed: () {},
  ),
)
```

### 3. Material3SearchBar

Enhanced search bar with Material 3 design.

#### Features
- Standard and expandable variants
- Leading and trailing widget support
- Auto-focus and keyboard actions
- Consistent Material 3 styling
- Animation support

#### Basic Usage

```dart
import 'package:org_app_caravella/widgets/material3_search_bar.dart';

// Standard search bar
Material3SearchBar(
  hintText: 'Search items...',
  leading: Icon(Icons.search),
  trailing: [
    IconButton(icon: Icon(Icons.mic), onPressed: () {}),
    IconButton(icon: Icon(Icons.filter_list), onPressed: () {}),
  ],
  onChanged: (value) => _performSearch(value),
)

// Expandable search bar
Material3ExpandableSearchBar(
  controller: _searchController,
  isExpanded: _searchExpanded,
  hintText: 'Search...',
  onToggle: () => setState(() => _searchExpanded = !_searchExpanded),
  onChanged: (value) => _performSearch(value),
)
```

### 4. Material3Badge

Notification and status badge implementation.

#### Features
- Notification count badges with overflow handling
- Status badges (error, warning, success, info, new)
- Dot badges for simple indicators
- Animated badges with show/hide transitions
- Proper color scheme integration

#### Basic Usage

```dart
import 'package:org_app_caravella/widgets/material3_badge.dart';

// Notification count badge
Material3NotificationBadge(
  count: _notificationCount,
  child: Icon(Icons.notifications),
)

// Status badge
Material3StatusBadge(
  status: BadgeStatus.error,
  child: Icon(Icons.warning),
)

// Dot badge
Material3Badge.dot(
  child: Icon(Icons.message),
)

// Animated badge
Material3AnimatedBadge(
  showBadge: _hasNewMessages,
  label: Text('NEW'),
  child: Icon(Icons.inbox),
)
```

## Integration Examples

### Enhanced Search with Filters

The `EnhancedExpandableSearchBar` shows how to combine the search bar with segmented button filters:

```dart
import 'package:org_app_caravella/widgets/enhanced_search_integration.dart';

EnhancedExpandableSearchBar(
  controller: _searchController,
  isExpanded: _isSearchExpanded,
  searchQuery: _searchQuery,
  onToggle: () => setState(() => _isSearchExpanded = !_isSearchExpanded),
  onSearchChanged: (value) => setState(() => _searchQuery = value),
  filterOptions: ['all', 'active', 'completed', 'archived'],
  selectedFilters: _selectedFilters,
  onFiltersChanged: (filters) => setState(() => _selectedFilters = filters),
)
```

### Complete Demo

See `Material3ComponentsDemo` for a comprehensive example showing all components in action with interactive controls.

## Design Guidelines

### Color Usage
- All components automatically adapt to the app's Material 3 color scheme
- Proper contrast ratios are maintained in both light and dark themes
- Error, warning, and success colors are used consistently for status indicators

### Accessibility
- All components include proper semantic labels
- Keyboard navigation is supported where applicable
- Screen reader compatibility is ensured
- Touch targets meet minimum size requirements (48dp)

### Animation
- Smooth transitions using Material 3 motion specifications
- Consistent duration and easing curves
- Reduced motion support where appropriate

## Testing

Each component includes comprehensive tests covering:
- Widget rendering and layout
- User interactions and callbacks
- State management
- Accessibility features
- Theme adaptation

Run tests with:
```bash
flutter test test/material3_*_test.dart
```

## Customization

All components accept style parameters for customization while maintaining Material 3 compliance:

```dart
Material3SegmentedButton(
  style: SegmentedButton.styleFrom(
    backgroundColor: Colors.blue.shade50,
    selectedBackgroundColor: Colors.blue,
  ),
  // ... other properties
)
```

## Migration from Existing Components

### From ExpandableSearchBar to Material3SearchBar

Replace the existing expandable search bar:

```dart
// Before
ExpandableSearchBar(
  controller: _controller,
  isExpanded: _isExpanded,
  // ...
)

// After  
Material3ExpandableSearchBar(
  controller: _controller,
  isExpanded: _isExpanded,
  // ... same properties with enhanced features
)
```

### Adding Context Menus

Replace manual popup menus with Material3MenuAnchor:

```dart
// Before
PopupMenuButton(
  itemBuilder: (context) => [
    PopupMenuItem(child: Text('Edit')),
    PopupMenuItem(child: Text('Delete')),
  ],
)

// After
Material3MenuAnchor(
  menuItems: [
    Material3MenuItem(text: 'Edit', leadingIcon: Icons.edit),
    Material3MenuItem(text: 'Delete', leadingIcon: Icons.delete),
  ],
  child: IconButton(icon: Icon(Icons.more_vert)),
)
```

## Performance Considerations

- Components are optimized for smooth animations
- State updates are minimal and targeted
- Lazy loading is used where appropriate
- Memory usage is kept minimal through proper disposal

## Browser Compatibility

All components work across Flutter's supported platforms:
- Android
- iOS
- Web
- Desktop (Windows, macOS, Linux)

Material 3 features gracefully degrade on older platforms while maintaining functionality.