import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:io_caravella_egm/l10n/app_localization_delegates.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:io_caravella_egm/manager/group/widgets/unsplash_thumbnail.dart';
import 'package:material_ui/material_ui.dart';

/// A 1x1 transparent PNG.
final _png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA'
  '60e6kgAAAABJRU5ErkJggg==',
);

void main() {
  late int requests;
  late List<int> statuses;

  final client = MockClient((request) async {
    final status = statuses[requests++ % statuses.length];
    return http.Response.bytes(status == 200 ? _png : [], status);
  });

  Widget thumbnail(bool shown) => MaterialApp(
    localizationsDelegates: appLocalizationsDelegates,
    supportedLocales: gen.AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: Scaffold(
      body: shown
          ? const UnsplashThumbnail(url: 'https://images.test/a.jpg')
          : const SizedBox(),
    ),
  );

  setUp(() {
    requests = 0;
    UnsplashThumbnail.clearCache();
  });

  testWidgets('a thumbnail seen before is not downloaded again', (
    tester,
  ) async {
    statuses = [200];
    await http.runWithClient(() async {
      await tester.pumpWidget(thumbnail(true));
      await tester.pump();
      await tester.pump();
      expect(find.byType(Image), findsOneWidget);

      await tester.pumpWidget(thumbnail(false));
      await tester.pumpWidget(thumbnail(true));

      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(requests, 1);
    }, () => client);
  });

  testWidgets('a server error tries once more, then on tap', (tester) async {
    statuses = [500, 500, 200];
    await http.runWithClient(() async {
      await tester.pumpWidget(thumbnail(true));
      await tester.pump();
      expect(requests, 1);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));
      await tester.pump();
      expect(requests, 2);
      expect(find.byIcon(Icons.broken_image_outlined), findsOneWidget);

      await tester.tap(find.byIcon(Icons.broken_image_outlined));
      await tester.pump();
      await tester.pump();
      await tester.pump();
      expect(requests, 3);
      expect(find.byType(Image), findsOneWidget);
    }, () => client);
  });

  testWidgets('a pending retry is dropped with the thumbnail', (tester) async {
    statuses = [500];
    await http.runWithClient(() async {
      await tester.pumpWidget(thumbnail(true));
      await tester.pump();
      await tester.pumpWidget(thumbnail(false));
      await tester.pump(const Duration(seconds: 3));
      expect(requests, 1);
    }, () => client);
  });
}
