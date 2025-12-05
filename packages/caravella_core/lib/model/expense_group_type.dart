import 'package:flutter/material.dart';

/// Enum representing the type/category of an expense group.
/// Each type has associated default categories that are pre-populated
/// when the type is selected.
enum ExpenseGroupType {
  personal, // personale
  family, // famiglia
  travel, // viaggio / vacanza
  other; // altro

  /// Returns the icon for this group type
  IconData get icon {
    switch (this) {
      case ExpenseGroupType.travel:
        return Icons.flight_takeoff;
      case ExpenseGroupType.personal:
        return Icons.person;
      case ExpenseGroupType.family:
        return Icons.family_restroom;
      case ExpenseGroupType.other:
        return Icons.widgets_outlined;
    }
  }

  /// Returns default category translation keys for this group type.
  /// Use [getLocalizedCategories] with AppLocalizations to get translated strings.
  List<String> get defaultCategoryKeys {
    switch (this) {
      case ExpenseGroupType.travel:
        return [
          'category_travel_transport',
          'category_travel_accommodation',
          'category_travel_restaurants',
        ];
      case ExpenseGroupType.personal:
        return [
          'category_personal_shopping',
          'category_personal_health',
          'category_personal_entertainment',
        ];
      case ExpenseGroupType.family:
        return [
          'category_family_groceries',
          'category_family_home',
          'category_family_bills',
        ];
      case ExpenseGroupType.other:
        return [
          'category_other_misc',
          'category_other_utilities',
          'category_other_services',
        ];
    }
  }

  /// Converts the enum to a string for JSON serialization
  String toJson() => name;

  /// Converts a string to the enum, returns null if invalid
  static ExpenseGroupType? fromJson(String? value) {
    if (value == null) return null;
    try {
      return ExpenseGroupType.values.firstWhere((e) => e.name == value);
    } catch (_) {
      return null;
    }
  }
}
