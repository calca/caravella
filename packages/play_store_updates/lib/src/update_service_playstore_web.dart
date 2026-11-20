// Web: no Play Store. The same names as update_service_playstore.dart,
// doing nothing, so the conditional import compiles.
import 'update_service_noop.dart';

void initializePlayStoreUpdatesLogger() {}

class PlayStoreUpdateService extends NoOpUpdateService {
  const PlayStoreUpdateService();
}

class PlayStoreUpdateNotifier extends NoOpUpdateNotifier {}
