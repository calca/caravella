import 'package:flutter/material.dart';

/// Centralized form styling constants and utilities to ensure consistency
/// across all form components in the application.
class FormTheme {
  FormTheme._();

  // Standard spacing constants
  static const double fieldVerticalPadding = 8.0;
  static const double fieldHorizontalPadding = 0.0;
  static const double iconSpacing = 6.0;
  static const double fieldSpacing = 16.0; // Space between form fields
  static const double sectionSpacing = 24.0; // Space between form sections

  // Standard content padding for all form fields
  static const EdgeInsets standardContentPadding = EdgeInsets.symmetric(
    vertical: fieldVerticalPadding,
    horizontal: fieldHorizontalPadding,
  );

  // Standard icon padding for IconLeadingField
  static const EdgeInsets standardIconPadding = EdgeInsets.only(
    top: fieldVerticalPadding,
    bottom: fieldVerticalPadding,
    right: iconSpacing,
  );

  // Standard icon padding for multiline fields (aligned to top)
  static const EdgeInsets topAlignedIconPadding = EdgeInsets.only(
    top: fieldVerticalPadding,
    bottom: 0,
    right: iconSpacing,
  );

  /// Returns the standard text style for form field inputs
  static TextStyle? getFieldTextStyle(BuildContext context) {
    return Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w400);
  }

  /// Returns the text style for amount/numeric input fields
  static TextStyle? getAmountTextStyle(BuildContext context) {
    return Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600);
  }

  /// Returns the text style for inline select fields
  static TextStyle? getSelectTextStyle(BuildContext context) {
    return Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w400);
  }

  /// Returns the text style for multiline text fields (notes, descriptions)
  static TextStyle? getMultilineTextStyle(BuildContext context) {
    return Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w400);
  }

  /// Returns standard decoration for form fields that should use theme defaults
  ///
  /// [labelText], when provided, gives the field a persistent accessible
  /// name (WCAG 3.3.2) that survives after the user starts typing, unlike
  /// [hintText] alone which disappears once the field has content.
  static InputDecoration getStandardDecoration({
    String? hintText,
    String? labelText,
    Widget? suffixIcon,
    Widget? prefixIcon,
    bool isDense = true,
  }) {
    return InputDecoration(
      hintText: hintText,
      labelText: labelText,
      suffixIcon: suffixIcon,
      prefixIcon: prefixIcon,
      isDense: isDense,
      contentPadding: standardContentPadding,
      // Border styles come from theme
    );
  }

  /// Returns decoration for multiline fields (notes, descriptions)
  ///
  /// See [getStandardDecoration] re: [labelText] vs [hintText].
  static InputDecoration getMultilineDecoration({
    String? hintText,
    String? labelText,
    Widget? suffixIcon,
    Widget? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      labelText: labelText,
      suffixIcon: suffixIcon,
      prefixIcon: prefixIcon,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        vertical: fieldVerticalPadding,
        horizontal: 12.0, // Multiline fields need some horizontal padding
      ),
      border: const OutlineInputBorder(),
    );
  }

  /// Returns decoration for borderless fields (like embedded in custom containers)
  ///
  /// See [getStandardDecoration] re: [labelText] vs [hintText].
  static InputDecoration getBorderlessDecoration({
    String? hintText,
    String? labelText,
    Widget? suffixIcon,
    Widget? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      labelText: labelText,
      suffixIcon: suffixIcon,
      prefixIcon: prefixIcon,
      border: InputBorder.none,
      isDense: true,
      contentPadding: standardContentPadding,
    );
  }

  /// Returns decoration for large amount fields rendered without borders.
  static InputDecoration getBorderlessAmountDecoration({
    String hintText = '0.00',
    TextStyle? hintStyle,
    EdgeInsetsGeometry contentPadding = const EdgeInsets.symmetric(vertical: 4),
  }) {
    return InputDecoration(
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      focusedErrorBorder: InputBorder.none,
      hintText: hintText,
      hintStyle: hintStyle,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      isDense: false,
      contentPadding: contentPadding,
      semanticCounterText: '',
    );
  }

  /// Returns decoration for AppBar/top search fields with pill shape.
  ///
  /// Use this for full-width search inputs where the field should visually
  /// blend with the containing surface (page/sheet/app bar).
  static InputDecoration getSearchPillDecoration({
    required Color backgroundColor,
    required String hintText,
    Widget? suffixIcon,
    Widget? prefixIcon,
  }) {
    const radius = Radius.circular(28);
    const border = OutlineInputBorder(
      borderRadius: BorderRadius.all(radius),
      borderSide: BorderSide.none,
    );

    return InputDecoration(
      hintText: hintText,
      suffixIcon: suffixIcon,
      prefixIcon: prefixIcon,
      filled: true,
      fillColor: backgroundColor,
      border: border,
      enabledBorder: border,
      focusedBorder: border,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      isDense: false,
    );
  }

  /// Returns a darker Gmail-like background color for AppBar search widgets.
  ///
  /// The color is darkened in both light and dark themes so the search field
  /// stands out from the AppBar surface.
  static Color getGmailAppBarSearchBackground(ColorScheme colorScheme) {
    final base = colorScheme.surfaceContainerHighest;
    final overlay = colorScheme.brightness == Brightness.dark
        ? Colors.black.withValues(alpha: 0.24)
        : Colors.black.withValues(alpha: 0.12);
    return Color.alphaBlend(overlay, base);
  }
}
