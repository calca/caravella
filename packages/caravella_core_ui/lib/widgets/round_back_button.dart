import 'package:material_ui/material_ui.dart';

import '../themes/caravella_themes.dart';

/// The app's back button: a raised round button with a rounded arrow in the
/// theme's text color (Flutter's [BackButton] took its color from the app
/// bar theme, wrong on these pages in the dark theme).
class RoundBackButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const RoundBackButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Material(
      color: s.raisedSurface,
      shape: const CircleBorder(),
      child: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        color: s.onSurface,
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        onPressed: onPressed ?? () => Navigator.of(context).maybePop(),
      ),
    );
  }
}
