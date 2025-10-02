import 'package:flutter_test/flutter_test.dart';

bool _isSelectable({
  required DateTime candidate,
  required bool isStart,
  DateTime? startDate,
  DateTime? endDate,
}) {
  if (isStart && endDate != null) {
    return !candidate.isAfter(endDate);
  }
  if (!isStart && startDate != null) {
    return !candidate.isBefore(startDate);
  }
  return true;
}

void main() {
  group('Date Picker Constraint Logic', () {
    test('End date cannot be before start date', () {
      final startDate = DateTime(2024, 1, 10);

      expect(
        _isSelectable(
          candidate: DateTime(2024, 1, 5),
          isStart: false,
          startDate: startDate,
        ),
        isFalse,
        reason: 'End date before start date should not be selectable',
      );

      expect(
        _isSelectable(
          candidate: DateTime(2024, 1, 10),
          isStart: false,
          startDate: startDate,
        ),
        isTrue,
        reason: 'End date equal to start date should be selectable',
      );

      expect(
        _isSelectable(
          candidate: DateTime(2024, 1, 15),
          isStart: false,
          startDate: startDate,
        ),
        isTrue,
        reason: 'End date after start date should be selectable',
      );
    });

    test('Start date cannot be after end date', () {
      final endDate = DateTime(2024, 1, 20);

      expect(
        _isSelectable(
          candidate: DateTime(2024, 1, 25),
          isStart: true,
          endDate: endDate,
        ),
        isFalse,
        reason: 'Start date after end date should not be selectable',
      );

      expect(
        _isSelectable(
          candidate: DateTime(2024, 1, 20),
          isStart: true,
          endDate: endDate,
        ),
        isTrue,
        reason: 'Start date equal to end date should be selectable',
      );

      expect(
        _isSelectable(
          candidate: DateTime(2024, 1, 15),
          isStart: true,
          endDate: endDate,
        ),
        isTrue,
        reason: 'Start date before end date should be selectable',
      );
    });

    test('Full date picker constraint logic for both scenarios', () {
      final startDate = DateTime(2024, 1, 10);
      final endDate = DateTime(2024, 1, 20);

      expect(
        _isSelectable(
          candidate: DateTime(2024, 1, 5),
          isStart: true,
          endDate: endDate,
        ),
        isTrue,
        reason: 'Start date before end date should be selectable',
      );

      expect(
        _isSelectable(
          candidate: DateTime(2024, 1, 20),
          isStart: true,
          endDate: endDate,
        ),
        isTrue,
        reason: 'Start date equal to end date should be selectable',
      );

      expect(
        _isSelectable(
          candidate: DateTime(2024, 1, 25),
          isStart: true,
          endDate: endDate,
        ),
        isFalse,
        reason: 'Start date after end date should NOT be selectable',
      );

      expect(
        _isSelectable(
          candidate: DateTime(2024, 1, 5),
          isStart: false,
          startDate: startDate,
        ),
        isFalse,
        reason: 'End date before start date should NOT be selectable',
      );

      expect(
        _isSelectable(
          candidate: DateTime(2024, 1, 10),
          isStart: false,
          startDate: startDate,
        ),
        isTrue,
        reason: 'End date equal to start date should be selectable',
      );

      expect(
        _isSelectable(
          candidate: DateTime(2024, 1, 25),
          isStart: false,
          startDate: startDate,
        ),
        isTrue,
        reason: 'End date after start date should be selectable',
      );
    });

    test('Date picker allows any date when no constraint exists', () {
      expect(
        _isSelectable(candidate: DateTime(2024, 1, 1), isStart: true),
        isTrue,
      );
      expect(
        _isSelectable(candidate: DateTime(2024, 12, 31), isStart: true),
        isTrue,
      );
      expect(
        _isSelectable(candidate: DateTime(2024, 1, 1), isStart: false),
        isTrue,
      );
      expect(
        _isSelectable(candidate: DateTime(2024, 12, 31), isStart: false),
        isTrue,
      );
    });
  });
}
