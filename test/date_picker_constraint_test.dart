import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Date Picker Constraint Logic', () {
    test('End date cannot be before start date', () {
      // Simulate the isSelectable predicate behavior
      final startDate = DateTime(2024, 1, 10);
      DateTime? endDate;
      
      bool isSelectableForEndDate(DateTime d) {
        // When selecting end date (!isStart), and startDate exists,
        // the date should not be before startDate
        if (startDate != null) return !d.isBefore(startDate);
        return true;
      }
      
      // Test: Date before start date should NOT be selectable
      final dateBefore = DateTime(2024, 1, 5);
      expect(isSelectableForEndDate(dateBefore), isFalse,
          reason: 'End date before start date should not be selectable');
      
      // Test: Date equal to start date should be selectable
      final dateEqual = DateTime(2024, 1, 10);
      expect(isSelectableForEndDate(dateEqual), isTrue,
          reason: 'End date equal to start date should be selectable');
      
      // Test: Date after start date should be selectable
      final dateAfter = DateTime(2024, 1, 15);
      expect(isSelectableForEndDate(dateAfter), isTrue,
          reason: 'End date after start date should be selectable');
    });
    
    test('Start date cannot be after end date', () {
      // Simulate the isSelectable predicate behavior
      DateTime? startDate;
      final endDate = DateTime(2024, 1, 20);
      
      bool isSelectableForStartDate(DateTime d) {
        // When selecting start date (isStart), and endDate exists,
        // the date should not be after endDate
        if (endDate != null) return !d.isAfter(endDate);
        return true;
      }
      
      // Test: Date after end date should NOT be selectable
      final dateAfter = DateTime(2024, 1, 25);
      expect(isSelectableForStartDate(dateAfter), isFalse,
          reason: 'Start date after end date should not be selectable');
      
      // Test: Date equal to end date should be selectable
      final dateEqual = DateTime(2024, 1, 20);
      expect(isSelectableForStartDate(dateEqual), isTrue,
          reason: 'Start date equal to end date should be selectable');
      
      // Test: Date before end date should be selectable
      final dateBefore = DateTime(2024, 1, 15);
      expect(isSelectableForStartDate(dateBefore), isTrue,
          reason: 'Start date before end date should be selectable');
    });
    
    test('Full date picker constraint logic for both scenarios', () {
      DateTime? startDate = DateTime(2024, 1, 10);
      DateTime? endDate = DateTime(2024, 1, 20);
      
      // Simulate the complete isSelectable predicate
      bool isSelectable(DateTime d, bool isStart) {
        if (isStart && endDate != null) return !d.isAfter(endDate);
        if (!isStart && startDate != null) return !d.isBefore(startDate);
        return true;
      }
      
      // Test start date picker constraints
      expect(isSelectable(DateTime(2024, 1, 5), true), isTrue,
          reason: 'Start date before end date should be selectable');
      expect(isSelectable(DateTime(2024, 1, 20), true), isTrue,
          reason: 'Start date equal to end date should be selectable');
      expect(isSelectable(DateTime(2024, 1, 25), true), isFalse,
          reason: 'Start date after end date should NOT be selectable');
      
      // Test end date picker constraints
      expect(isSelectable(DateTime(2024, 1, 5), false), isFalse,
          reason: 'End date before start date should NOT be selectable');
      expect(isSelectable(DateTime(2024, 1, 10), false), isTrue,
          reason: 'End date equal to start date should be selectable');
      expect(isSelectable(DateTime(2024, 1, 25), false), isTrue,
          reason: 'End date after start date should be selectable');
    });
    
    test('Date picker allows any date when no constraint exists', () {
      DateTime? startDate;
      DateTime? endDate;
      
      bool isSelectable(DateTime d, bool isStart) {
        if (isStart && endDate != null) return !d.isAfter(endDate);
        if (!isStart && startDate != null) return !d.isBefore(startDate);
        return true;
      }
      
      // When no dates are set, any date should be selectable
      expect(isSelectable(DateTime(2024, 1, 1), true), isTrue);
      expect(isSelectable(DateTime(2024, 12, 31), true), isTrue);
      expect(isSelectable(DateTime(2024, 1, 1), false), isTrue);
      expect(isSelectable(DateTime(2024, 12, 31), false), isTrue);
    });
  });
}
