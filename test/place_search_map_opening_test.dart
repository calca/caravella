import 'dart:async';

import 'package:caravella_core/caravella_core.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:io_caravella_egm/l10n/app_localization_delegates.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart';
import 'package:io_caravella_egm/manager/expense/location/location_service.dart';
import 'package:io_caravella_egm/manager/expense/location/repository/location_repository.dart';
import 'package:io_caravella_egm/manager/expense/pages/place_search_page.dart';
import 'package:material_ui/material_ui.dart';

/// A position that arrives when the test says so.
class _SlowFix implements LocationRepository {
  final fix = Completer<ExpenseLocation?>();

  @override
  Future<bool> isLocationServiceEnabled() async => true;

  @override
  Future<LocationPermissionStatus> checkPermission() async =>
      LocationPermissionStatus.whileInUse;

  @override
  Future<LocationPermissionStatus> requestPermission() async =>
      LocationPermissionStatus.whileInUse;

  @override
  Future<ExpenseLocation?> getCurrentLocation({bool resolveAddress = true}) =>
      fix.future;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

/// The place picker built its map on a default spot (Rome), then moved it
/// to the phone's position: two sets of tiles, the first shown in pieces.
/// Now the map is built once, where it opens.
void main() {
  final client = MockClient((request) async => http.Response('{}', 200));

  late _SlowFix location;

  Future<void> open(WidgetTester tester) {
    LocationService.debugSetRepository(location = _SlowFix());
    return tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: const PlaceSearchPage(hintText: 'Place'),
      ),
    );
  }

  testWidgets('the map opens on the position, once it is found', (
    tester,
  ) async {
    await http.runWithClient(() async {
      await open(tester);
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(FlutterMap), findsNothing);

      // The position's future resolves outside the fake clock.
      await tester.runAsync(() async {
        location.fix.complete(
          ExpenseLocation(latitude: 45.46, longitude: 9.19),
        );
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();

      final map = tester.widget<FlutterMap>(find.byType(FlutterMap));
      expect(map.options.initialCenter.latitude, closeTo(45.46, 0.01));
      expect(map.options.initialCenter.longitude, closeTo(9.19, 0.001));
      await tester.pump(const Duration(seconds: 4));
    }, () => client);
  });

  testWidgets('a slow position does not keep the map away', (tester) async {
    await http.runWithClient(() async {
      await open(tester);
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(FlutterMap), findsNothing);

      await tester.pump(const Duration(seconds: 3));
      expect(find.byType(FlutterMap), findsOneWidget);

      location.fix.complete(null);
      await tester.pump(const Duration(seconds: 4));
    }, () => client);
  });
}
