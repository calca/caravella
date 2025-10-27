/// Update service exports with conditional Play Store support.
/// 
/// When building with Play Store support:
///   flutter build apk --dart-define=ENABLE_PLAY_UPDATES=true
/// 
/// When building without Play Store support (F-Droid):
///   flutter build apk

library updates;

export 'update_service_interface.dart';
export 'update_service_noop.dart';
export 'update_service_factory.dart';
