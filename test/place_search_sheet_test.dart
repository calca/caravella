import 'dart:convert';

import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:io_caravella_egm/l10n/app_localization_delegates.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart';
import 'package:io_caravella_egm/manager/expense/pages/place_search_page.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('the sheet shows the address when it arrives', (tester) async {
    final client = MockClient((request) async {
      if (request.url.path.contains('reverse')) {
        return http.Response(
          jsonEncode({
            'lat': '41.9',
            'lon': '12.4',
            'display_name': 'Piazza della Repubblica, Roma',
          }),
          200,
        );
      }
      return http.Response('', 404);
    });

    await http.runWithClient(() async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const PlaceSearchPage(hintText: 'Place'),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tapAt(tester.getCenter(find.byType(FlutterMap)));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Piazza della Repubblica, Roma'), findsOneWidget);
      expect(find.text('Finding address…'), findsNothing);
    }, () => client);
  });

  testWidgets('a place already set: its card shows and search stays usable', (
    tester,
  ) async {
    final client = MockClient((request) async => http.Response('[]', 200));
    await http.runWithClient(() async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: PlaceSearchPage(
            hintText: 'Place',
            initialPlace: NominatimPlace(
              latitude: 41.9,
              longitude: 12.4,
              displayName: 'Piazza della Repubblica, Roma',
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));

      // No modal sheet in the way: the place is in a card on the page.
      expect(find.byType(BottomSheet), findsNothing);
      expect(find.text('Piazza della Repubblica, Roma'), findsOneWidget);

      // The search field takes text; the card steps aside while typing.
      await tester.tap(find.byType(SearchBar));
      await tester.pump();
      await tester.enterText(find.byType(SearchBar), 'Colosseo');
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Colosseo'), findsOneWidget);
      expect(find.text('Piazza della Repubblica, Roma'), findsNothing);
      await tester.pump(const Duration(seconds: 2));
    }, () => client);
  });
}
