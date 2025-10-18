import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/bank_account.dart';
import '../models/bank_transaction.dart';
import '../models/bank_requisition.dart';

/// Service for managing GoCardless PSD2 banking integration (Local-First)
/// 
/// This service acts as a bridge between the Flutter app and Supabase Edge Function
/// which acts as a STATELESS PROXY to GoCardless API.
/// 
/// IMPORTANT: This is a stub implementation. The actual implementation requires:
/// - Supabase Edge Function (bank_proxy) as stateless proxy
/// - GoCardless API credentials configured in Edge Function environment
/// - Local encrypted storage (Drift/Hive/Sembast) with flutter_secure_storage
/// 
/// PRIVACY: No banking data is ever stored on backend servers. All data is
/// encrypted and stored locally on device only.
class BankingService {
  final String supabaseUrl;
  final String supabaseAnonKey;
  final http.Client _client;

  BankingService({
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    http.Client? client,
  }) : _client = client ?? http.Client();

  /// Create a bank link requisition
  /// 
  /// Calls the Supabase Edge Function /bank_proxy to generate a GoCardless
  /// requisition and returns the authorization URL for the user to connect their bank.
  /// 
  /// The Edge Function acts as a stateless proxy - no data is stored on backend.
  Future<BankingResult<String>> createBankLink({
    required String userId,
    required String institutionId,
    required String redirectUrl,
  }) async {
    try {
      // STUB: In production, this would call Supabase Edge Function proxy
      // final response = await _client.post(
      //   Uri.parse('$supabaseUrl/functions/v1/bank_proxy'),
      //   headers: {
      //     'Authorization': 'Bearer $supabaseAnonKey',
      //     'Content-Type': 'application/json',
      //   },
      //   body: json.encode({
      //     'action': 'createLink',
      //     'bankId': institutionId,
      //     'redirect': redirectUrl,
      //   }),
      // );
      // 
      // final data = json.decode(response.body);
      // return BankingResult.success(data['link'] as String);

      return BankingResult.failure(
        BankingError(
          code: 'NOT_IMPLEMENTED',
          message: 'Banking integration requires Supabase Edge Function setup. '
              'Configure bank_proxy Edge Function with GoCardless credentials.',
        ),
      );
    } catch (e) {
      return BankingResult.failure(
        BankingError(
          code: 'NETWORK_ERROR',
          message: e.toString(),
        ),
      );
    }
  }

  /// Fetch transactions from connected bank accounts
  /// 
  /// Calls the Supabase Edge Function /bank_proxy to fetch transactions from
  /// GoCardless. The Edge Function acts as a stateless proxy - returns JSON
  /// data without storing anything on backend.
  /// 
  /// The returned transactions should be encrypted and stored locally by the caller.
  Future<BankingResult<List<BankTransaction>>> fetchTransactions({
    required String userId,
    required String requisitionId,
  }) async {
    try {
      // STUB: In production, this would call Supabase Edge Function proxy
      // final response = await _client.post(
      //   Uri.parse('$supabaseUrl/functions/v1/bank_proxy'),
      //   headers: {
      //     'Authorization': 'Bearer $supabaseAnonKey',
      //     'Content-Type': 'application/json',
      //   },
      //   body: json.encode({
      //     'action': 'fetchTransactions',
      //     'requisitionId': requisitionId,
      //   }),
      // );
      // 
      // final data = json.decode(response.body);
      // final txList = data['transactions'] as List;
      // return BankingResult.success(
      //   txList.map((tx) => BankTransaction.fromJson(tx)).toList(),
      // );

      return BankingResult.failure(
        BankingError(
          code: 'NOT_IMPLEMENTED',
          message: 'Transaction sync requires bank_proxy Edge Function setup.',
        ),
      );
    } catch (e) {
      return BankingResult.failure(
        BankingError(
          code: 'NETWORK_ERROR',
          message: e.toString(),
        ),
      );
    }
  }

  // NOTE: In local-first architecture, these methods are not needed
  // as all data is stored and retrieved from local encrypted storage.
  // 
  // The following methods would be implemented by a LocalStorageService
  // using Drift/Hive/Sembast with encryption via flutter_secure_storage:
  // 
  // - getAccounts() - Query local DB
  // - getAccountTransactions() - Query local DB with filters
  // - canRefreshTransactions() - Check local last_refresh timestamp
  // - saveTransactions() - Encrypt and save to local DB
  // - getLastRefreshDate() - Get from local DB
  // - setLastRefreshDate() - Update in local DB

  void dispose() {
    _client.close();
  }
}

/// Result wrapper for banking operations
class BankingResult<T> {
  final T? data;
  final BankingError? error;

  const BankingResult._({this.data, this.error});

  factory BankingResult.success(T data) => BankingResult._(data: data);
  factory BankingResult.failure(BankingError error) =>
      BankingResult._(error: error);

  bool get isSuccess => error == null;
  bool get isFailure => error != null;
}

/// Banking error model
class BankingError {
  final String code;
  final String message;
  final Map<String, dynamic>? details;

  const BankingError({
    required this.code,
    required this.message,
    this.details,
  });

  @override
  String toString() => 'BankingError($code): $message';
}
