import 'package:flutter/material.dart';

class AppTextStyles {
  AppTextStyles._();
  static TextStyle? sectionTitle(BuildContext context) => Theme.of(
    context,
  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600);
  static TextStyle? listItem(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium;
  static TextStyle? listItemStrong(BuildContext context) => Theme.of(
    context,
  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600);
  static TextStyle? subtle(BuildContext context) => Theme.of(context)
      .textTheme
      .bodyMedium
      ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant);
}
