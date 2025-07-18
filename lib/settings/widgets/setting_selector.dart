import 'package:flutter/material.dart';

class SettingSelector extends StatelessWidget {
  final IconData? icon;
  final String label;
  final Widget selector;
  const SettingSelector({
    super.key,
    this.icon,
    required this.label,
    required this.selector,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(),
          ),
          const SizedBox(width: 8),
          Expanded(child: selector),
        ],
      ),
    );
  }
}
