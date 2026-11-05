import 'dart:io';

import 'package:caravella_core/caravella_core.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../data/group_form_state.dart';
import '../group_type/group_type_localization.dart';

/// The group as it's being created: its background (the photo, the color
/// chosen, or its type's color), icon and name, updated while typing.
/// Decorative for screen readers: the field and the pills say the same.
class WizardGroupPreview extends StatelessWidget {
  /// Shown until the group has a name.
  final String fallbackTitle;

  /// Shorter while the keyboard is up, so the name field stays in view.
  final bool compact;

  const WizardGroupPreview({
    super.key,
    required this.fallbackTitle,
    this.compact = false,
  });

  static const double height = 132;
  static const double compactHeight = 104;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = context.watch<GroupFormState>();
    final image = state.imagePath;
    final color =
        ExpenseGroupColorPalette.resolveColor(
          state.color ??
              ExpenseGroupColorPalette.defaultIndexFor(state.groupType),
          theme.colorScheme,
        ) ??
        theme.colorScheme.primary;
    final onBackground = image != null
        ? Colors.white
        : ExpenseGroupColorPalette.getContrastingTextColor(color);
    final title = state.title.trim();
    final icon = state.customTemplateIconCodePoint != null
        ? GroupTypeLocalization.iconFromCodePoint(
            state.customTemplateIconCodePoint!,
          )
        : (state.groupType ?? ExpenseGroupType.other).icon;

    return ExcludeSemantics(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          height: compact ? compactHeight : height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ColoredBox(color: color),
              if (image != null) ...[
                Image.file(
                  File(image),
                  key: ValueKey(image),
                  fit: BoxFit.cover,
                  cacheWidth: 900,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
                // Keeps the white name readable on any photo.
                const ColoredBox(color: Color(0x66000000)),
              ],
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: onBackground.withValues(alpha: 0.16),
                      ),
                      child: Icon(icon, size: 20, color: onBackground),
                    ),
                    Text(
                      title.isEmpty ? fallbackTitle : title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: onBackground,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              if (state.loadingImage)
                const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }
}
