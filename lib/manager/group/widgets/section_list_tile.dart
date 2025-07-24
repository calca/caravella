import 'package:flutter/material.dart';

class SectionListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Color? borderColor;
  final Color? iconColor;
  final Color? deleteColor;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final Widget? trailing;

  const SectionListTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.borderColor,
    this.iconColor,
    this.deleteColor,
    this.backgroundColor,
    this.padding,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(vertical: 4.0),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 16.0),
                // No decoration here, background is on the parent
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          if (subtitle != null)
                            Text(
                              subtitle!,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                        ],
                      ),
                    ),
                    if (trailing != null) ...[
                      const SizedBox(width: 8),
                      trailing!,
                    ],
                  ],
                ),
              ),
            ),
            if (onEdit != null) ...[
              const SizedBox(width: 4),
              IconButton.filledTonal(
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: onEdit,
                style: IconButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainer,
                  foregroundColor: Theme.of(context).colorScheme.onSurface,
                  minimumSize: const Size(42, 42),
                ),
              ),
            ],
            if (onDelete != null) ...[
              const SizedBox(width: 4),
              IconButton.filledTonal(
                icon: const Icon(Icons.delete_outline, size: 20),
                onPressed: onDelete,
                style: IconButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainer,
                  foregroundColor:
                      deleteColor ?? Theme.of(context).colorScheme.error,
                  minimumSize: const Size(42, 42),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
