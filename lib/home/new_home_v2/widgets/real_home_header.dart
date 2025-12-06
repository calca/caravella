import 'package:flutter/material.dart';

/// Header widget for the real home page with avatar, search, and settings icons.
class RealHomeHeader extends StatelessWidget {
  final VoidCallback? onSearchTap;
  final VoidCallback? onSettingsTap;

  const RealHomeHeader({
    super.key,
    this.onSearchTap,
    this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Avatar
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFFF0E6DC),
            child: Icon(
              Icons.person,
              color: const Color(0xFFD4A574),
              size: 32,
            ),
          ),
          // Search and Settings icons
          Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.search,
                  color: theme.colorScheme.onSurface,
                  size: 28,
                ),
                onPressed: onSearchTap,
                tooltip: 'Cerca',
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  Icons.settings,
                  color: theme.colorScheme.onSurface,
                  size: 28,
                ),
                onPressed: onSettingsTap,
                tooltip: 'Impostazioni',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
