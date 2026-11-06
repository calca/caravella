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
}
