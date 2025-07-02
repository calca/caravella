import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app_localizations.dart';
import '../../state/locale_notifier.dart';

class AppIconSelector extends StatefulWidget {
  const AppIconSelector({super.key});

  @override
  State<AppIconSelector> createState() => _AppIconSelectorState();
}

class _AppIconSelectorState extends State<AppIconSelector> {
  String _selectedIcon = 'default';

  @override
  void initState() {
    super.initState();
    _loadSelectedIcon();
  }

  Future<void> _loadSelectedIcon() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedIcon = prefs.getString('app_icon') ?? 'default';
    });
  }

  Future<void> _saveSelectedIcon(String iconName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_icon', iconName);
    setState(() {
      _selectedIcon = iconName;
    });

    if (mounted) {
      final locale = LocaleNotifier.of(context)?.locale ?? 'it';
      final loc = AppLocalizations(locale);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${loc.get('app_icon')}: $iconName'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = LocaleNotifier.of(context)?.locale ?? 'it';
    final loc = AppLocalizations(locale);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.get('app_icon'),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          loc.get('app_icon_description'),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.7),
              ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              _buildIconOption(
                'default',
                loc.get('icon_default'),
                Icons.apps,
                Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              _buildIconOption(
                'blue',
                loc.get('icon_blue'),
                Icons.apps,
                Colors.blue.shade700,
              ),
              const SizedBox(height: 12),
              _buildIconOption(
                'green',
                loc.get('icon_green'),
                Icons.apps,
                Colors.green.shade600,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIconOption(
      String iconKey, String label, IconData icon, Color color) {
    final isSelected = _selectedIcon == iconKey;

    return InkWell(
      onTap: () => _saveSelectedIcon(iconKey),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context)
                  .colorScheme
                  .primaryContainer
                  .withValues(alpha: 0.5)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(
                  color: Theme.of(context).colorScheme.primary, width: 2)
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
