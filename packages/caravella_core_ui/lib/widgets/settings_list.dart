import 'package:material_ui/material_ui.dart';

import '../themes/caravella_themes.dart';
import 'card_outline.dart';
import 'status_bar_fade.dart';

/// Settings page in the app's style (app settings, a group's settings):
/// grey page, a raised round back button, a small [eyebrow] above a large
/// [title], then [children] (typically a [SettingsProfileCard] and
/// [SettingsGroup]s). Edge to edge.
class SettingsScaffold extends StatelessWidget {
  final String? eyebrow;
  final String title;
  final List<Widget> children;

  const SettingsScaffold({
    super.key,
    this.eyebrow,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final padding = MediaQuery.paddingOf(context);
    return Scaffold(
      backgroundColor: s.surfaceContainer,
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.fromLTRB(
              16,
              padding.top + 8,
              16,
              padding.bottom + 32,
            ),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Material(
                  color: s.raisedSurface,
                  shape: const CircleBorder(),
                  child: const BackButton(),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (eyebrow != null)
                      Text(
                        eyebrow!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: s.onSurfaceVariant,
                        ),
                      ),
                    Semantics(
                      header: true,
                      child: Text(
                        title,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ...children,
            ],
          ),
          StatusBarFade(color: s.surfaceContainer),
        ],
      ),
    );
  }
}

/// A card standing for what the page sets up (you, or the group): a
/// [leading] avatar, a name and a line of details; tapping edits it.
class SettingsProfileCard extends StatelessWidget {
  final Widget leading;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  /// Spoken action, e.g. "Edit".
  final String? actionLabel;

  const SettingsProfileCard({
    super.key,
    required this.leading,
    required this.title,
    this.subtitle,
    this.onTap,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final radius = BorderRadius.circular(24);
    return Semantics(
      button: onTap != null,
      label: [title, ?subtitle, ?actionLabel].join(', '),
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
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  SizedBox.square(dimension: 52, child: leading),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (subtitle != null)
                          Text(
                            subtitle!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: s.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (onTap != null)
                    Icon(Icons.edit_outlined, color: s.onSurfaceVariant),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A labelled section: [label] above a card holding [children]
/// ([SettingsTile]s), separated by hairlines.
class SettingsGroup extends StatelessWidget {
  final String? label;
  final List<Widget> children;

  const SettingsGroup({super.key, this.label, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final visible = children.toList();
    if (visible.isEmpty) return const SizedBox.shrink();
    final radius = BorderRadius.circular(20);
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (label != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Semantics(
                header: true,
                child: Text(
                  label!.toUpperCase(),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: s.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ),
          CardOutline(
            borderRadius: radius,
            child: Material(
              color: s.raisedSurface,
              borderRadius: radius,
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  for (var i = 0; i < visible.length; i++) ...[
                    if (i > 0)
                      Divider(
                        height: 1,
                        indent: 64,
                        endIndent: 16,
                        color: s.outlineVariant.withValues(alpha: 0.5),
                      ),
                    visible[i],
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A settings row: a monochrome [icon] in a neutral circle, [title],
/// optional [subtitle], then a chevron (when [onTap] opens something), a
/// switch ([switchValue] + [onSwitch]) or a custom [trailing].
/// [destructive] draws title and icon in the error color.
class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? subtitleWidget;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool? switchValue;
  final ValueChanged<bool>? onSwitch;
  final bool destructive;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.subtitleWidget,
    this.onTap,
    this.trailing,
    this.switchValue,
    this.onSwitch,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final fg = destructive ? s.error : s.onSurface;
    final isSwitch = switchValue != null;
    final VoidCallback? tap =
        onTap ??
        (isSwitch && onSwitch != null ? () => onSwitch!(!switchValue!) : null);

    final Widget? trail =
        trailing ??
        (isSwitch
            ? ExcludeSemantics(
                child: Switch(value: switchValue!, onChanged: onSwitch),
              )
            : onTap != null
            ? Icon(Icons.chevron_right_rounded, color: s.onSurfaceVariant)
            : null);

    return MergeSemantics(
      child: Semantics(
        toggled: isSwitch ? switchValue : null,
        button: !isSwitch && onTap != null,
        child: InkWell(
          onTap: tap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 60),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 12, 10),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: destructive
                          ? s.error.withValues(alpha: 0.1)
                          : s.onSurface.withValues(alpha: 0.06),
                    ),
                    child: Icon(icon, size: 20, color: fg),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: fg,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (subtitleWidget != null)
                          DefaultTextStyle.merge(
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: s.onSurfaceVariant,
                            ),
                            child: subtitleWidget!,
                          )
                        else if (subtitle != null)
                          Text(
                            subtitle!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: s.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (trail != null) ...[const SizedBox(width: 8), trail],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
