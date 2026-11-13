import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Every modal bottom sheet goes through `showAppBottomSheet`
/// (`caravella_core_ui`), so they all move the same way (`AppMotion.sheet`).
void main() {
  test('no modal bottom sheet bypasses showAppBottomSheet', () {
    final offenders = <String>[];
    for (final root in [Directory('lib'), Directory('packages')]) {
      for (final file in root.listSync(recursive: true).whereType<File>()) {
        final path = file.path.replaceAll('\\', '/');
        if (!path.endsWith('.dart') ||
            path.contains('/test/') ||
            path.contains('/.dart_tool/') ||
            path.contains('/build/') ||
            path.endsWith('widgets/app_bottom_sheet.dart')) {
          continue;
        }
        if (file.readAsStringSync().contains('showModalBottomSheet')) {
          offenders.add(path);
        }
      }
    }
    expect(offenders, isEmpty, reason: 'use showAppBottomSheet instead');
  });
}
