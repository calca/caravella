import 'package:caravella_core/caravella_core.dart';
import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;

class GroupTypeLocalization {
  /// Icons available for group type templates, ordered by appearance in the
  /// template editor.
  static const List<IconData> availableIcons = [
    Icons.flight_takeoff,
    Icons.person,
    Icons.family_restroom,
    Icons.widgets_outlined,
    Icons.directions_car,
    Icons.restaurant,
    Icons.home,
    Icons.hotel,
    Icons.sports_esports,
    Icons.event,
  ];

  static String typeName(gen.AppLocalizations gloc, ExpenseGroupType type) {
    switch (type) {
      case ExpenseGroupType.travel:
        return gloc.group_type_travel;
      case ExpenseGroupType.personal:
        return gloc.group_type_personal;
      case ExpenseGroupType.family:
        return gloc.group_type_family;
      case ExpenseGroupType.other:
        return gloc.group_type_other;
    }
  }

  static List<String> localizedDefaultCategories(
    gen.AppLocalizations gloc,
    ExpenseGroupType type,
  ) {
    switch (type) {
      case ExpenseGroupType.travel:
        return [
          gloc.category_travel_transport,
          gloc.category_travel_accommodation,
          gloc.category_travel_restaurants,
        ];
      case ExpenseGroupType.personal:
        return [
          gloc.category_personal_shopping,
          gloc.category_personal_health,
          gloc.category_personal_entertainment,
        ];
      case ExpenseGroupType.family:
        return [
          gloc.category_family_groceries,
          gloc.category_family_home,
          gloc.category_family_bills,
        ];
      case ExpenseGroupType.other:
        return [
          gloc.category_other_misc,
          gloc.category_other_utilities,
          gloc.category_other_services,
        ];
    }
  }

  static IconData iconFromCodePoint(int codePoint) {
    if (codePoint <= 0) return Icons.category_outlined;
    for (final icon in availableIcons) {
      if (icon.codePoint == codePoint) return icon;
    }
    return Icons.category_outlined;
  }
}
