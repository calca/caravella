import 'package:flutter/material.dart';

/// Enum representing the type/category of an expense group.
/// Each type has associated default categories that are pre-populated
/// when the type is selected.
enum ExpenseGroupType {
  travel, // viaggio / vacanza
  personal, // personale
  family, // famiglia
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
        return Icons.more_horiz;
    }
  }

  /// Returns default category names for this group type
  List<String> get defaultCategories {
    switch (this) {
      case ExpenseGroupType.travel:
        return ['Trasporti', 'Alloggio', 'Ristoranti'];
      case ExpenseGroupType.personal:
        return ['Shopping', 'Salute', 'Intrattenimento'];
      case ExpenseGroupType.family:
        return ['Spesa', 'Casa', 'Bambini'];
      case ExpenseGroupType.other:
        return ['Varie', 'Utilità', 'Servizi'];
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
