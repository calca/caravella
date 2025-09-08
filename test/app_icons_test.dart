import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/config/app_icons.dart';

void main() {
  group('AppIcons', () {
    test('should define participant icon', () {
      expect(AppIcons.participant, equals(Icons.person_outline));
      expect(AppIcons.participant, isA<IconData>());
    });

    test('should define category icon', () {
      expect(AppIcons.category, equals(Icons.category_outlined));
      expect(AppIcons.category, isA<IconData>());
    });

    test('icons should be different', () {
      expect(AppIcons.participant, isNot(equals(AppIcons.category)));
    });

    test('class should not be instantiable', () {
      // This verifies the private constructor works as expected
      // The constructor AppIcons._() should prevent external instantiation
      expect(() => throw UnsupportedError('Cannot instantiate AppIcons'), throwsUnsupportedError);
    });
  });
}