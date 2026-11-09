import 'package:caravella_core/caravella_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalePreferences.deviceDefault', () {
    test('follows the first device language the app supports', () {
      expect(LocalePreferences.deviceDefault(['en']), 'en');
      expect(LocalePreferences.deviceDefault(['de', 'pt', 'it']), 'pt');
      expect(LocalePreferences.deviceDefault(['zh']), 'zh');
    });

    test('falls back to English, not Italian', () {
      expect(LocalePreferences.deviceDefault(['de', 'fr']), 'en');
      expect(LocalePreferences.deviceDefault(const []), 'en');
    });
  });
}
