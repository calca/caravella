import 'package:flutter/material.dart';

/// Custom header widget for OurTab home page with avatar, greeting, and notification bell.
class OurTabHeader extends StatelessWidget {
  /// User's name for the greeting
  final String userName;
  
  /// Whether to show notification badge
  final bool hasNotifications;
  
  /// Callback when notification icon is tapped
  final VoidCallback? onNotificationTap;
  
  /// Avatar image URL or asset path (optional)
  final String? avatarImage;

  const OurTabHeader({
    super.key,
    required this.userName,
    this.hasNotifications = false,
    this.onNotificationTap,
    this.avatarImage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side: Avatar and greeting
          Row(
            children: [
              // Circular avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: theme.colorScheme.primaryContainer,
                backgroundImage: avatarImage != null 
                    ? AssetImage(avatarImage!) as ImageProvider
                    : null,
                child: avatarImage == null
                    ? Icon(
                        Icons.person,
                        color: theme.colorScheme.onPrimaryContainer,
                        size: 28,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              // Greeting text
              Text(
                'Ciao, $userName 👋',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          // Right side: Notification bell with badge
          Stack(
            children: [
              IconButton(
                icon: Icon(
                  Icons.notifications_outlined,
                  color: theme.colorScheme.onSurface,
                  size: 28,
                ),
                onPressed: onNotificationTap,
                tooltip: 'Notifiche',
              ),
              if (hasNotifications)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.surface,
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
