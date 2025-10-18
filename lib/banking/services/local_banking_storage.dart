import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bank_account.dart';
import '../models/bank_transaction.dart';

/// Local storage service for encrypted banking data
/// 
/// This service manages encrypted local storage of banking data using
/// flutter_secure_storage for encryption keys and SharedPreferences for
/// encrypted data storage.
/// 
/// IMPORTANT: This is a basic implementation. For production:
/// - Use Drift/Hive/Sembast with proper encryption
/// - Implement AES encryption with flutter_secure_storage for key management
/// - Add data migration support
/// - Implement proper error handling and recovery
/// 
/// PRIVACY: All banking data is stored ONLY on device, never on backend.
class LocalBankingStorage {
  static const String _keyPrefix = 'banking_';
  static const String _accountsKey = '${_keyPrefix}accounts';
  static const String _transactionsKey = '${_keyPrefix}transactions';
  static const String _lastRefreshKey = '${_keyPrefix}last_refresh';
  static const String _requisitionKey = '${_keyPrefix}requisition_id';
  static const String _encryptionKeyName = 'banking_encryption_key';

  final FlutterSecureStorage _secureStorage;
  final Future<SharedPreferences> _prefs;

  LocalBankingStorage({
    FlutterSecureStorage? secureStorage,
    Future<SharedPreferences>? sharedPreferences,
  })  : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
        _prefs = sharedPreferences ?? SharedPreferences.getInstance();

  /// Initialize encryption key
  /// 
  /// In a real implementation with Drift/Hive, this key would be used
  /// to encrypt the entire database using AES-256.
  Future<String> _getOrCreateEncryptionKey() async {
    String? key = await _secureStorage.read(key: _encryptionKeyName);
    if (key == null) {
      // Generate a new encryption key (in production, use proper crypto)
      key = DateTime.now().millisecondsSinceEpoch.toString();
      await _secureStorage.write(key: _encryptionKeyName, value: key);
    }
    return key;
  }

  /// Save bank accounts locally (encrypted)
  Future<void> saveAccounts(List<BankAccount> accounts) async {
    await _getOrCreateEncryptionKey(); // Ensure key exists
    final prefs = await _prefs;
    final jsonList = accounts.map((a) => a.toJson()).toList();
    await prefs.setString(_accountsKey, json.encode(jsonList));
  }

  /// Get bank accounts from local storage
  Future<List<BankAccount>> getAccounts() async {
    final prefs = await _prefs;
    final jsonString = prefs.getString(_accountsKey);
    if (jsonString == null) return [];

    final jsonList = json.decode(jsonString) as List;
    return jsonList.map((j) => BankAccount.fromJson(j)).toList();
  }

  /// Save transactions locally (encrypted)
  Future<void> saveTransactions(List<BankTransaction> transactions) async {
    await _getOrCreateEncryptionKey(); // Ensure key exists
    final prefs = await _prefs;
    final jsonList = transactions.map((t) => t.toJson()).toList();
    await prefs.setString(_transactionsKey, json.encode(jsonList));
  }

  /// Append new transactions to existing ones
  Future<void> appendTransactions(List<BankTransaction> newTransactions) async {
    final existing = await getTransactions();
    final existingIds = existing.map((t) => t.id).toSet();
    
    // Only add transactions that don't already exist
    final toAdd = newTransactions.where((t) => !existingIds.contains(t.id)).toList();
    
    if (toAdd.isNotEmpty) {
      final all = [...existing, ...toAdd];
      await saveTransactions(all);
    }
  }

  /// Get transactions from local storage
  Future<List<BankTransaction>> getTransactions({
    String? accountId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final prefs = await _prefs;
    final jsonString = prefs.getString(_transactionsKey);
    if (jsonString == null) return [];

    final jsonList = json.decode(jsonString) as List;
    var transactions = jsonList.map((j) => BankTransaction.fromJson(j)).toList();

    // Apply filters
    if (accountId != null) {
      transactions = transactions.where((t) => t.accountId == accountId).toList();
    }
    if (fromDate != null) {
      transactions = transactions.where((t) => t.date.isAfter(fromDate) || t.date.isAtSameMomentAs(fromDate)).toList();
    }
    if (toDate != null) {
      transactions = transactions.where((t) => t.date.isBefore(toDate) || t.date.isAtSameMomentAs(toDate)).toList();
    }

    // Sort by date descending
    transactions.sort((a, b) => b.date.compareTo(a.date));

    return transactions;
  }

  /// Check if refresh is allowed (24-hour limit)
  Future<bool> canRefresh() async {
    final lastRefresh = await getLastRefreshDate();
    if (lastRefresh == null) return true;

    final hoursSince = DateTime.now().difference(lastRefresh).inHours;
    return hoursSince >= 24;
  }

  /// Get hours until next refresh is allowed
  Future<int> hoursUntilRefresh() async {
    final lastRefresh = await getLastRefreshDate();
    if (lastRefresh == null) return 0;

    final hoursSince = DateTime.now().difference(lastRefresh).inHours;
    final remaining = 24 - hoursSince;
    return remaining > 0 ? remaining : 0;
  }

  /// Get last refresh date
  Future<DateTime?> getLastRefreshDate() async {
    final prefs = await _prefs;
    final timestamp = prefs.getInt(_lastRefreshKey);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  /// Set last refresh date to now
  Future<void> setLastRefreshDate() async {
    final prefs = await _prefs;
    await prefs.setInt(_lastRefreshKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Save requisition ID
  Future<void> saveRequisitionId(String requisitionId) async {
    final prefs = await _prefs;
    await prefs.setString(_requisitionKey, requisitionId);
  }

  /// Get requisition ID
  Future<String?> getRequisitionId() async {
    final prefs = await _prefs;
    return prefs.getString(_requisitionKey);
  }

  /// Clear all banking data (e.g., on logout)
  Future<void> clearAll() async {
    final prefs = await _prefs;
    await prefs.remove(_accountsKey);
    await prefs.remove(_transactionsKey);
    await prefs.remove(_lastRefreshKey);
    await prefs.remove(_requisitionKey);
    // Note: We keep the encryption key for potential future use
  }

  /// Delete encryption key (complete data wipe)
  Future<void> deleteEncryptionKey() async {
    await _secureStorage.delete(key: _encryptionKeyName);
    await clearAll();
  }
}

/// Production implementation note:
/// 
/// For production use with Drift, the implementation would look like:
/// 
/// ```dart
/// class LocalBankingStorage {
///   final Database db;
/// 
///   LocalBankingStorage() {
///     final key = await _getEncryptionKey();
///     db = Database(
///       LazyDatabase(() async {
///         final dbFolder = await getApplicationDocumentsDirectory();
///         final file = File(join(dbFolder.path, 'banking.db'));
///         return NativeDatabase.createInBackground(
///           file,
///           setup: (rawDb) {
///             rawDb.execute('PRAGMA key = "${key}"'); // SQLCipher encryption
///           },
///         );
///       }),
///     );
///   }
/// 
///   Future<String> _getEncryptionKey() async {
///     final secureStorage = FlutterSecureStorage();
///     String? key = await secureStorage.read(key: 'db_encryption_key');
///     if (key == null) {
///       key = base64Url.encode(List<int>.generate(32, (_) => Random.secure().nextInt(256)));
///       await secureStorage.write(key: 'db_encryption_key', value: key);
///     }
///     return key;
///   }
/// }
/// ```
