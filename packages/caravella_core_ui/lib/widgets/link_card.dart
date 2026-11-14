import 'package:material_ui/material_ui.dart';

import '../themes/caravella_themes.dart';
import 'card_outline.dart';

/// A card that leads somewhere: a round icon, a title, a line under it and a
/// chevron when it can be tapped (the map and budget cards of a group's
/// statistics). Read by screen readers as one button, "title, subtitle".
class LinkCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  /// Null makes it a note: no chevron, not tappable.
  final VoidCallback? onTap;

  const LinkCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final radius = BorderRadius.circular(20);
    return Semantics(
      button: onTap != null,
      label: '$title, $subtitle',
      onTap: onTap,
      excludeSemantics: true,
      child: CardOutline(
        borderRadius: radius,
        child: Material(
          color: s.raisedSurface,
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: s.surfaceContainerHighest,
                    ),
                    child: Icon(icon, color: s.onSurface),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: s.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onTap != null)
                    Icon(
                      Icons.chevron_right_rounded,
                      color: s.onSurfaceVariant,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
