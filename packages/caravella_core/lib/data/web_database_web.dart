import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

/// In the browser: SQLite compiled to WebAssembly (`web/sqlite3.wasm`), its
/// files kept in IndexedDB by a shared worker (`web/sqflite_sw.js`, both
/// installed by `dart run sqflite_common_ffi_web:setup`). The repository's
/// SQL is the same as on Android.
void useWebDatabaseIfNeeded() => databaseFactory = databaseFactoryFfiWeb;
