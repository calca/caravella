import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

/// Web: SQLite compiled to WebAssembly (web/sqlite3.wasm), kept in the
/// browser's IndexedDB by a shared worker (web/sqflite_sw.js).
void useWebDatabase() => databaseFactory = databaseFactoryFfiWeb;
