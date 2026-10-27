import 'package:material_ui/material_ui.dart';

/// Top bar for full-screen dark pages (photo viewer, QR scanner): round
/// translucent buttons floating over the content — back, an optional
/// centered [title] pill, then [actions] — like the app's round buttons
/// on light pages.
class MediaTopBar extends StatelessWidget {
  final String? title;
  final List<Widget> actions;
  final String? backTooltip;

  const MediaTopBar({
    super.key,
    this.title,
    this.actions = const [],
    this.backTooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Row(
          children: [
            MediaRoundButton(
              icon: Icons.arrow_back_rounded,
              tooltip:
                  backTooltip ??
                  MaterialLocalizations.of(context).backButtonTooltip,
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: title == null
                  ? const SizedBox.shrink()
                  // heightFactor 1: a plain Center grows to the height it's
                  // given, which stretched the row — and centered every
                  // button — down the middle of the attachment viewer.
                  : Center(
                      heightFactor: 1,
                      child: DecoratedBox(
                        decoration: ShapeDecoration(
                          shape: const StadiumBorder(),
                          color: Colors.black.withValues(alpha: 0.45),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          child: Text(
                            title!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
            for (final (i, a) in actions.indexed) ...[
              if (i > 0) const SizedBox(width: 8),
              a,
            ],
            // Keeps the title centered when there are no actions.
            if (actions.isEmpty) const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }
}

/// A round translucent icon button for [MediaTopBar].
class MediaRoundButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  const MediaRoundButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) => IconButton(
    icon: Icon(icon),
    tooltip: tooltip,
    onPressed: onPressed,
    color: Colors.white,
    style: IconButton.styleFrom(
      backgroundColor: Colors.black.withValues(alpha: 0.45),
      minimumSize: const Size(48, 48),
    ),
  );
}
