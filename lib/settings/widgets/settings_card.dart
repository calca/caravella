import 'package:flutter/material.dart';

class SettingsCard extends StatelessWidget {
  final Widget child;
  final bool? semanticsButton;
  final String? semanticsLabel;
  final String? semanticsHint;
  final bool? semanticsToggled;
  final Color? color;
  final BuildContext context;

  const SettingsCard({
    super.key,
    required this.context,
    required this.child,
    this.semanticsButton,
    this.semanticsLabel,
    this.semanticsHint,
    this.semanticsToggled,
    this.color,
  });

  @override
  Widget build(BuildContext ctx) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    );
    final card = Card(elevation: 0, color: color, shape: shape, child: child);
    if (semanticsButton == true ||
        semanticsLabel != null ||
        semanticsHint != null ||
        semanticsToggled != null) {
      return Semantics(
        button: semanticsButton,
        label: semanticsLabel,
        hint: semanticsHint,
        toggled: semanticsToggled,
        child: card,
      );
    }
    return card;
  }
}
