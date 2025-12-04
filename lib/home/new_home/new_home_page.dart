import 'package:flutter/material.dart';
import '../models/global_balance.dart';
import '../models/group_item.dart';
import 'widgets/our_tab_header.dart';
import 'widgets/global_balance_card.dart';
import 'widgets/group_list_section.dart';

/// New home page with custom design featuring dashboard, groups list, 
/// FAB, and bottom navigation.
class NewHomePage extends StatefulWidget {
  const NewHomePage({super.key});

  @override
  State<NewHomePage> createState() => _NewHomePageState();
}

class _NewHomePageState extends State<NewHomePage> {
  int _selectedIndex = 0;

  // Mock data - will be replaced with real data
  final GlobalBalance _mockBalance = const GlobalBalance(
    total: 150.50,
    owedToYou: 200.00,
    youOwe: 49.50,
  );

  final List<GroupItem> _mockGroups = [
    GroupItem(
      id: '1',
      name: 'Vacanza Roma',
      lastActivity: DateTime.now().subtract(const Duration(hours: 2)),
      amount: 75.50,
      status: GroupStatus.positive,
      emoji: '🏖️',
    ),
    GroupItem(
      id: '2',
      name: 'Cena Amici',
      lastActivity: DateTime.now().subtract(const Duration(days: 1)),
      amount: -25.00,
      status: GroupStatus.negative,
      emoji: '🍕',
    ),
    GroupItem(
      id: '3',
      name: 'Weekend Montagna',
      lastActivity: DateTime.now().subtract(const Duration(days: 3)),
      amount: 0.00,
      status: GroupStatus.settled,
      emoji: '⛰️',
    ),
  ];

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // TODO: Navigate to different sections
  }

  void _onFabPressed() {
    // TODO: Implement add new group/expense
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Aggiungi nuovo gruppo o spesa')),
    );
  }

  void _onNotificationTap() {
    // TODO: Navigate to notifications
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notifiche')),
    );
  }

  void _onGroupTap(GroupItem group) {
    // TODO: Navigate to group details
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Apri gruppo: ${group.name}')),
    );
  }

  void _onViewAllGroups() {
    // TODO: Navigate to all groups view
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vedi tutti i gruppi')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Custom background
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom header
              OurTabHeader(
                userName: 'Alessandro',
                hasNotifications: true,
                onNotificationTap: _onNotificationTap,
              ),
              const SizedBox(height: 8),
              // Dashboard balance card
              GlobalBalanceCard(
                balance: _mockBalance,
              ),
              const SizedBox(height: 16),
              // Active groups list
              GroupListSection(
                groups: _mockGroups,
                onViewAll: _onViewAllGroups,
                onGroupTap: _onGroupTap,
              ),
              const SizedBox(height: 80), // Space for FAB
            ],
          ),
        ),
      ),
      // Floating action button (centered)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onFabPressed,
        backgroundColor: theme.colorScheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Nuovo',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // Bottom navigation bar
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: theme.colorScheme.surface,
        elevation: 8,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home,
                label: 'Home',
                index: 0,
                isSelected: _selectedIndex == 0,
              ),
              _buildNavItem(
                icon: Icons.people,
                label: 'Amici',
                index: 1,
                isSelected: _selectedIndex == 1,
              ),
              const SizedBox(width: 60), // Space for FAB
              _buildNavItem(
                icon: Icons.history,
                label: 'Attività',
                index: 2,
                isSelected: _selectedIndex == 2,
              ),
              _buildNavItem(
                icon: Icons.person,
                label: 'Profilo',
                index: 3,
                isSelected: _selectedIndex == 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
  }) {
    final theme = Theme.of(context);
    final color = isSelected 
        ? theme.colorScheme.primary 
        : theme.colorScheme.onSurfaceVariant;
    
    return Expanded(
      child: InkWell(
        onTap: () => _onBottomNavTap(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
