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
    return Theme.of(context).textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w400,
    );
  }

  /// Returns the text style for amount/numeric input fields
  static TextStyle? getAmountTextStyle(BuildContext context) {
    return Theme.of(context).textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w600,
    );
  }

  /// Returns the text style for inline select fields
  static TextStyle? getSelectTextStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w400,
    );
  }

  /// Returns the text style for multiline text fields (notes, descriptions)
  static TextStyle? getMultilineTextStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w400,
    );
  }

  /// Returns standard decoration for form fields that should use theme defaults
  static InputDecoration getStandardDecoration({
    String? hintText,
    Widget? suffixIcon,
    Widget? prefixIcon,
    bool isDense = true,
  }) {
    return InputDecoration(
      hintText: hintText,
      suffixIcon: suffixIcon,
      prefixIcon: prefixIcon,
      isDense: isDense,
      contentPadding: standardContentPadding,
      // Border styles come from theme
    );
  }

  /// Returns decoration for multiline fields (notes, descriptions)
  static InputDecoration getMultilineDecoration({
    String? hintText,
    Widget? suffixIcon,
    Widget? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
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
  static InputDecoration getBorderlessDecoration({
    String? hintText,
    Widget? suffixIcon,
    Widget? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      suffixIcon: suffixIcon,
      prefixIcon: prefixIcon,
      border: InputBorder.none,
      isDense: true,
      contentPadding: standardContentPadding,
    );
  }
}