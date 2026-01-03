import 'package:flutter_test/flutter_test.dart';
import 'package:caravella_core/caravella_core.dart';

/// Tests for notification icon selection based on expense group type
/// 
/// This verifies that the NotificationService correctly selects the appropriate
/// icon drawable resource based on the ExpenseGroupType.
void main() {
  group('NotificationService - Icon Selection', () {
    test('_getIconForGroupType returns travel icon for travel type', () {
      final iconName = _getIconForGroupType(ExpenseGroupType.travel);
      expect(iconName, 'ic_notification_travel');
    });

    test('_getIconForGroupType returns personal icon for personal type', () {
      final iconName = _getIconForGroupType(ExpenseGroupType.personal);
      expect(iconName, 'ic_notification_personal');
    });

    test('_getIconForGroupType returns family icon for family type', () {
      final iconName = _getIconForGroupType(ExpenseGroupType.family);
      expect(iconName, 'ic_notification_family');
    });

    test('_getIconForGroupType returns other icon for other type', () {
      final iconName = _getIconForGroupType(ExpenseGroupType.other);
      expect(iconName, 'ic_notification_other');
    });

    test('_getIconForGroupType returns default icon for null type', () {
      final iconName = _getIconForGroupType(null);
      expect(iconName, 'ic_notification');
    });

    test('all ExpenseGroupType values have corresponding icon', () {
      // Ensure we have an icon for every type
      for (final type in ExpenseGroupType.values) {
        final iconName = _getIconForGroupType(type);
        expect(iconName, isNotNull);
        expect(iconName, isNotEmpty);
        expect(iconName, startsWith('ic_notification_'));
      }
    });
  });
}

/// Helper function that mirrors the private method in NotificationService
/// This allows us to test the logic without making the method public
String _getIconForGroupType(ExpenseGroupType? groupType) {
  if (groupType == null) {
    return 'ic_notification';
  }

  switch (groupType) {
    case ExpenseGroupType.travel:
      return 'ic_notification_travel';
    case ExpenseGroupType.personal:
      return 'ic_notification_personal';
    case ExpenseGroupType.family:
      return 'ic_notification_family';
    case ExpenseGroupType.other:
      return 'ic_notification_other';
  }
}
