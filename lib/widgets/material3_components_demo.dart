import 'package:flutter/material.dart';
import 'package:org_app_caravella/widgets/widgets.dart';

/// Demo page showcasing the new Material 3 components
class Material3ComponentsDemo extends StatefulWidget {
  const Material3ComponentsDemo({super.key});

  @override
  State<Material3ComponentsDemo> createState() => _Material3ComponentsDemoState();
}

class _Material3ComponentsDemoState extends State<Material3ComponentsDemo> {
  // SegmentedButton state
  Set<String> _viewMode = {'list'};
  Set<String> _multiFilters = {'all'};
  
  // Search state
  bool _searchExpanded = false;
  final _searchController = TextEditingController();
  
  // Badge state
  int _notificationCount = 5;
  bool _showStatusBadge = true;
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Material 3 Components Demo'),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSegmentedButtonSection(),
            const SizedBox(height: 32),
            _buildSearchBarSection(),
            const SizedBox(height: 32),
            _buildBadgeSection(),
            const SizedBox(height: 32),
            _buildMenuAnchorSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentedButtonSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Segmented Buttons',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        
        // Single selection view mode
        Text(
          'View Mode (Single Selection)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Material3SegmentedButton<String>(
          segments: Material3SegmentHelpers.createIconSegments({
            'list': Icons.list,
            'grid': Icons.grid_view,
            'card': Icons.view_agenda,
          }, tooltips: {
            'list': 'List View',
            'grid': 'Grid View',
            'card': 'Card View',
          }),
          selected: _viewMode,
          onSelectionChanged: (selection) {
            setState(() {
              _viewMode = selection;
            });
          },
        ),
        const SizedBox(height: 16),
        
        // Multi selection filters
        Text(
          'Filters (Multi Selection)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Material3SegmentedButton<String>(
          segments: Material3SegmentHelpers.createTextSegments({
            'all': 'All',
            'recent': 'Recent',
            'favorites': 'Favorites',
            'shared': 'Shared',
          }),
          selected: _multiFilters,
          multiSelectionEnabled: true,
          emptySelectionAllowed: false,
          expandedWidth: true,
          onSelectionChanged: (selection) {
            setState(() {
              _multiFilters = selection;
            });
          },
        ),
      ],
    );
  }

  Widget _buildSearchBarSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Search Bars',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        
        // Standard search bar
        Text(
          'Standard Search Bar',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Material3SearchBar(
          hintText: 'Search items...',
          leading: const Icon(Icons.search),
          trailing: [
            IconButton(
              icon: const Icon(Icons.mic),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () {},
            ),
          ],
          onChanged: (value) {
            // Handle search
          },
        ),
        const SizedBox(height: 16),
        
        // Expandable search bar
        Text(
          'Expandable Search Bar',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Spacer(),
            Material3ExpandableSearchBar(
              controller: _searchController,
              isExpanded: _searchExpanded,
              hintText: 'Search...',
              onToggle: () {
                setState(() {
                  _searchExpanded = !_searchExpanded;
                });
              },
              onChanged: (value) {
                setState(() {}); // Trigger rebuild for clear button
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBadgeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Badges',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            // Notification badge
            Column(
              children: [
                Material3NotificationBadge(
                  count: _notificationCount,
                  child: const Icon(Icons.notifications, size: 32),
                ),
                const SizedBox(height: 8),
                const Text('Notifications'),
              ],
            ),
            
            // Status badges
            Column(
              children: [
                Material3StatusBadge(
                  status: BadgeStatus.error,
                  child: const Icon(Icons.warning, size: 32),
                ),
                const SizedBox(height: 8),
                const Text('Error Status'),
              ],
            ),
            
            Column(
              children: [
                Material3StatusBadge(
                  status: BadgeStatus.success,
                  child: const Icon(Icons.check_circle, size: 32),
                ),
                const SizedBox(height: 8),
                const Text('Success Status'),
              ],
            ),
            
            Column(
              children: [
                Material3StatusBadge(
                  status: BadgeStatus.new_,
                  child: const Icon(Icons.star, size: 32),
                ),
                const SizedBox(height: 8),
                const Text('New Item'),
              ],
            ),
            
            // Dot badge
            Column(
              children: [
                const Material3Badge.dot(
                  child: Icon(Icons.message, size: 32),
                ),
                const SizedBox(height: 8),
                const Text('Dot Badge'),
              ],
            ),
            
            // Animated badge
            Column(
              children: [
                Material3AnimatedBadge(
                  showBadge: _showStatusBadge,
                  label: const Text('NEW'),
                  child: const Icon(Icons.inbox, size: 32),
                ),
                const SizedBox(height: 8),
                const Text('Animated'),
              ],
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        Row(
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _notificationCount = (_notificationCount + 1) % 100;
                });
              },
              child: const Text('Add Notification'),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _showStatusBadge = !_showStatusBadge;
                });
              },
              child: Text(_showStatusBadge ? 'Hide Badge' : 'Show Badge'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuAnchorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Menu Anchors',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        
        Row(
          children: [
            // Simple menu
            Material3MenuAnchor(
              menuItems: [
                Material3MenuItem(
                  text: 'Edit',
                  leadingIcon: Icons.edit,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Edit selected')),
                    );
                  },
                ),
                Material3MenuItem(
                  text: 'Share',
                  leadingIcon: Icons.share,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Share selected')),
                    );
                  },
                ),
                const Material3MenuDivider(),
                Material3MenuItem(
                  text: 'Delete',
                  leadingIcon: Icons.delete,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Delete selected')),
                    );
                  },
                ),
              ],
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Options Menu'),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Menu with submenu
            Material3MenuAnchor(
              menuItems: [
                Material3MenuItem(
                  text: 'New File',
                  leadingIcon: Icons.description,
                  onPressed: () {},
                ),
                Material3SubmenuButton(
                  text: 'Export',
                  leadingIcon: Icons.upload,
                  menuItems: [
                    Material3MenuItem(
                      text: 'PDF',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Export as PDF')),
                        );
                      },
                    ),
                    Material3MenuItem(
                      text: 'CSV',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Export as CSV')),
                        );
                      },
                    ),
                    Material3MenuItem(
                      text: 'JSON',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Export as JSON')),
                        );
                      },
                    ),
                  ],
                ),
                const Material3MenuDivider(),
                Material3MenuItem(
                  text: 'Settings',
                  leadingIcon: Icons.settings,
                  onPressed: () {},
                ),
              ],
              child: OutlinedButton(
                onPressed: () {},
                child: const Text('File Menu'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}