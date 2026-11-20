# Caravella in the browser (experimental)

Work in progress on the `feature/web` branch (issue #764). The goal: a static single-page app, its data in the browser, no server of ours.

## How it runs

- **Same code**: `flutter build web` builds the app from `lib/` and the packages; CI builds it on every PR into `feature/**` and keeps `build/web` as the `caravella-web` artifact for 14 days.
- **Storage**: `SqliteExpenseGroupRepository` is unchanged. On the web it sets sqflite's factory to `sqflite_common_ffi_web` first (`packages/caravella_core/lib/data/web_database_web.dart`, picked by a conditional import): SQLite compiled to WebAssembly (`web/sqlite3.wasm`), its files kept in IndexedDB by a shared worker (`web/sqflite_sw.js`). Both files come from `dart run sqflite_common_ffi_web:setup`; rerun it when that package is upgraded.
- **Platform checks**: never `dart:io`'s `Platform` (it throws in a browser). Use `PlatformInfo` (`caravella_core/lib/platform/platform_info.dart`): `isWeb`, `isAndroid`… and capabilities (`supportsLanSync`, `supportsAndroidIntegrations`, `hasFileSystem`). Natively it asks the real OS through `platform_os_io.dart`, the only file there that imports `dart:io`.
- **Layout**: on the web the phone layout stays a centered column, at most 520 dp wide, on the page color (`AppFrame`).
- **Play Store updates**: `play_store_updates` swaps in no-op classes on the web (`update_service_playstore_web.dart`).

## Try it locally

```sh
flutter build web --dart-define=FLAVOR=dev
cd build/web && python3 -m http.server 8642
```

Then open http://127.0.0.1:8642. The data lives in that browser's site data for `127.0.0.1:8642`.

## Next steps

See #764: a `FileStore` for photos, attachments and backups (files natively, blobs in the browser) and a CI guard against `dart:io` outside `*_io.dart`; backup export/import as download/upload; "in the Android app" invites for what the web can't do; then hosting as a PWA.
