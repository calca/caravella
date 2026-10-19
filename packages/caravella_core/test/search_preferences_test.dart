import 'package:caravella_core/caravella_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    PreferencesService.reset();
    await PreferencesService.initialize();
  });

  test('recent group searches: newest first, deduplicated, capped', () async {
    final search = PreferencesService.instance.search;
    for (final q in ['ski', 'casa', ' Ski ', 'a', 'b', 'c', 'd']) {
      await search.addRecentGroupSearch(q);
    }
    expect(search.getRecentGroupSearches(), ['d', 'c', 'b', 'a', 'Ski']);
    await search.addRecentGroupSearch('   ');
    expect(search.getRecentGroupSearches().length, 5);
    await search.clearRecentGroupSearches();
    expect(search.getRecentGroupSearches(), isEmpty);
  });
}
