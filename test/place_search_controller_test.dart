import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:io_caravella_egm/manager/expense/location/state/place_search_controller.dart';
import 'package:io_caravella_egm/manager/expense/location/state/place_search_state.dart';
import 'package:latlong2/latlong.dart';

/// The place picker says what happened to a search: nothing found (with
/// the query), or failed (and Try again searches again).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<PlaceSearchController> search(String query, http.Client client) async {
    final controller = PlaceSearchController();
    controller.searchController.text = query;
    await http.runWithClient(() async {
      controller.retrySearch();
      // The search waits out Nominatim's 1 request/s, then answers.
      for (var i = 0; i < 40 && !_settled(controller); i++) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
    }, () => client);
    return controller;
  }

  test('a search that finds nothing says so, with the query', () async {
    final controller = await search(
      'zzqxwvkj',
      MockClient((_) async => http.Response('[]', 200)),
    );
    expect(controller.state.noResultsQuery, 'zzqxwvkj');
    expect(controller.state.hasError, isFalse);
    expect(controller.state.searchResults, isEmpty);
  });

  test('a failed search is an error, and Try again searches again', () async {
    var calls = 0;
    final client = MockClient((_) async {
      calls++;
      return calls == 1
          ? http.Response('busy', 503)
          : http.Response(
              '[{"place_id": 1, "lat": "60.39", "lon": "5.32", '
              '"display_name": "Bergen, Vestland, Norway"}]',
              200,
            );
    });
    final controller = await search('Bergen', client);
    expect(controller.state.errorMessage, PlaceSearchController.searchFailed);
    expect(controller.state.noResultsQuery, isNull);

    await http.runWithClient(() async {
      controller.retrySearch();
      for (var i = 0; i < 40 && !_settled(controller); i++) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
    }, () => client);
    expect(controller.state.hasError, isFalse);
    expect(
      controller.state.searchResults.single.displayName,
      contains('Bergen'),
    );
  });

  test('the picked point is "you are here" only when it is the phone\'s', () {
    const here = LatLng(59.9139, 10.7522);
    final mine = PlaceSearchState.initial().copyWith(
      userLocation: here,
      selectedMapLocation: here,
    );
    expect(mine.selectedIsUserLocation, isTrue);
    final tapped = mine.copyWith(selectedMapLocation: const LatLng(60, 11));
    expect(tapped.selectedIsUserLocation, isFalse);
  });
}

bool _settled(PlaceSearchController c) =>
    !c.state.isSearching &&
    (c.state.hasError ||
        c.state.noResultsQuery != null ||
        c.state.hasSearchResults);
