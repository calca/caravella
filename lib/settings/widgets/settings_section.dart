import 'package:flutter/material.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';

class SettingsSection extends StatelessWidget {
  final String title;
  final String description;
  final List<Widget> children;
  final EdgeInsets? headerPadding;
  final EdgeInsets? contentPadding;

  const SettingsSection({
    super.key,
    required this.title,
    required this.description,
    required this.children,
    this.headerPadding,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: title,
          description: description,
          padding: headerPadding ?? const EdgeInsets.fromLTRB(24, 24, 24, 0),
        ),
        Padding(
          padding:
              contentPadding ??
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(children: children),
        ),
      ],
    );
  }
}
