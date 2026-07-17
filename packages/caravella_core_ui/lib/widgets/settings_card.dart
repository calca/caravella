import 'package:flutter/material.dart';
import 'base_card.dart';

/// Semantics-aware settings row card, built on the shared [BaseCard]
/// instead of reimplementing a rounded surface container.
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
    final card = BaseCard(
      padding: EdgeInsets.zero,
      backgroundColor: color,
      child: child,
    );
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
