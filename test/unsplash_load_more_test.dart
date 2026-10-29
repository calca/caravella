import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:io_caravella_egm/manager/group/pages/unsplash_search_page.dart';
import 'package:io_caravella_egm/services/unsplash/unsplash_photo.dart';
import 'package:io_caravella_egm/services/unsplash/unsplash_service.dart';
import 'package:material_ui/material_ui.dart';

UnsplashPhoto _photo(String id) => UnsplashPhoto(
  id: id,
  urls: UnsplashUrls(raw: id, full: id, regular: id, small: id, thumb: id),
  user: const UnsplashUser(name: 'Ann', username: 'ann'),
);

/// Scrolling to the end of the results loads the next page of the search.
void main() {
  late List<int> calls;
  late bool failNext;

  Future<UnsplashSearchResults> search(String query, {int page = 1}) async {
    calls.add(page);
    if (failNext) {
      failNext = false;
      throw Exception('offline');
    }
    return (
      photos: [for (var i = 0; i < 30; i++) _photo('$query-$page-$i')],
      totalPages: 3,
    );
  }

  Future<void> pumpPage(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          gen.AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: gen.AppLocalizations.supportedLocales,
        home: UnsplashSearchPage(initialQuery: 'beach', search: search),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  Future<void> scrollToEnd(WidgetTester tester) async {
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -6000));
    await tester.pump();
    await tester.pump();
  }

  setUp(() {
    calls = [];
    failNext = false;
  });

  testWidgets('loads the next pages while scrolling, up to the last', (
    tester,
  ) async {
    await pumpPage(tester);
    expect(calls, [1]);

    await scrollToEnd(tester);
    expect(calls, [1, 2]);

    await scrollToEnd(tester);
    expect(calls, [1, 2, 3]);

    // Page 3 of 3: nothing more to ask for.
    await scrollToEnd(tester);
    expect(calls, [1, 2, 3]);
  });

  testWidgets('a failed page offers Retry, which loads it', (tester) async {
    await pumpPage(tester);
    failNext = true;
    await scrollToEnd(tester);
    expect(calls, [1, 2]);

    // Scrolling again doesn't hammer the API; it shows the error, and
    // Retry loads the page.
    await scrollToEnd(tester);
    expect(calls, [1, 2]);
    expect(find.text('Couldn’t load more photos'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pump();
    await tester.pump();
    expect(calls, [1, 2, 2]);
    expect(find.text('Couldn’t load more photos'), findsNothing);
  });
}
