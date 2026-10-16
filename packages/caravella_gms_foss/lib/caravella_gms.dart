/// FOSS build of `caravella_gms`: no Google libraries.
///
/// Selected by `./build_variant.sh foss` (the F-Droid build). Every
/// proprietary feature is reported as unavailable and the app hides it, or
/// falls back to a free implementation (location uses the platform
/// `LocationManager`). See `docs/PACKAGE_CARAVELLA_GMS.md`.
library;

import 'package:caravella_core/caravella_core.dart';

/// The integrations of this build: none.
const GmsIntegrations gmsIntegrations = NoGmsIntegrations();
