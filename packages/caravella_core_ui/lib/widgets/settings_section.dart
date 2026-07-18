import 'package:flutter/material.dart';
import '../themes/app_spacing.dart';
import 'section_header.dart';

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
          padding:
              headerPadding ??
              const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.xl,
                AppSpacing.xl,
                0,
              ),
        ),
        Padding(
          padding:
              contentPadding ??
              const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
          child: Column(children: children),
        ),
      ],
    );
  }
}
