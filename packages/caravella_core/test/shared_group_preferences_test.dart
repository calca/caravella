import 'package:caravella_core/caravella_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    PreferencesService.reset();
    await PreferencesService.initialize();
  });

  test('a received group is welcomed until dismissed', () async {
    final shared = PreferencesService.instance.sharedGroups;
    expect(shared.pendingWelcomeFrom('g1'), isNull);

    await shared.addPendingWelcome('g1', 'Pixel 9');
    await shared.addPendingWelcome('g2', '');
    expect(shared.pendingWelcomeFrom('g1'), 'Pixel 9');
    expect(shared.pendingWelcomeFrom('g2'), '');

    await shared.clearPendingWelcome('g1');
    expect(shared.pendingWelcomeFrom('g1'), isNull);
    expect(shared.pendingWelcomeFrom('g2'), '');
  });
}
