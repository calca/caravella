import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/widgets/group_background_utils.dart';

ExpenseGroup _group({String? file, int? color}) {
  return ExpenseGroup(
    title: 'Test group',
    expenses: const [],
    participants: const [],
    currency: 'EUR',
    file: file,
    color: color,
  );
}

void main() {
  const colorScheme = ColorScheme.light();

  group('GroupBackgroundUtils.buildGradient', () {
    test('places topColor at 0% and bottomColor at 65%', () {
      final gradient = GroupBackgroundUtils.buildGradient(
        Colors.red,
        Colors.blue,
      );

      expect(gradient.begin, Alignment.topCenter);
      expect(gradient.end, Alignment.bottomCenter);
      expect(gradient.colors, [Colors.red, Colors.blue]);
      expect(gradient.stops, [0.0, 0.65]);
    });
  });

  group('GroupBackgroundUtils.resolve', () {
    test('falls back to surfaceContainerLowest with no image and no color', () {
      final result = GroupBackgroundUtils.resolve(_group(), colorScheme);

      expect(result.hasImage, isFalse);
      expect(result.gradient, isNull);
      expect(result.color, colorScheme.surfaceContainerLowest);
    });

    test('resolves a palette color index into a theme color with gradient', () {
      final result = GroupBackgroundUtils.resolve(
        _group(color: 0), // index 0 -> colorScheme.primary
        colorScheme,
      );

      expect(result.hasImage, isFalse);
      expect(result.color, colorScheme.primary);
      expect(result.gradient, isNotNull);
    });

    test('resolves a legacy ARGB color value directly', () {
      const legacyArgb = 0xFF123456;
      final result = GroupBackgroundUtils.resolve(
        _group(color: legacyArgb),
        colorScheme,
      );

      expect(result.hasImage, isFalse);
      expect(result.color, const Color(legacyArgb));
    });

    test('prefers the background image when the file exists on disk', () {
      final tempFile = File(
        '${Directory.systemTemp.path}/caravella_test_bg_${DateTime.now().millisecondsSinceEpoch}.png',
      )..writeAsBytesSync([0]);
      addTearDown(() {
        if (tempFile.existsSync()) tempFile.deleteSync();
      });

      final result = GroupBackgroundUtils.resolve(
        _group(file: tempFile.path, color: 0),
        colorScheme,
      );

      expect(result.hasImage, isTrue);
      expect(result.imagePath, tempFile.path);
      expect(result.gradient, isNotNull);
    });

    test('ignores a file path that does not exist on disk', () {
      final result = GroupBackgroundUtils.resolve(
        _group(file: '/nonexistent/path/to/image.png'),
        colorScheme,
      );

      expect(result.hasImage, isFalse);
    });

    test('honors a custom baseColor override for the image gradient', () {
      final tempFile = File(
        '${Directory.systemTemp.path}/caravella_test_bg_base_${DateTime.now().millisecondsSinceEpoch}.png',
      )..writeAsBytesSync([0]);
      addTearDown(() {
        if (tempFile.existsSync()) tempFile.deleteSync();
      });

      final result = GroupBackgroundUtils.resolve(
        _group(file: tempFile.path),
        colorScheme,
        baseColor: Colors.purple,
      );

      expect(result.color, Colors.purple.withValues(alpha: 0.1));
    });
  });
}
