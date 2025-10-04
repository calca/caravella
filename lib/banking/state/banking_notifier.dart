import 'package:flutter/foundation.dart';
import '../models/bank_account.dart';
import '../models/bank_transaction.dart';
import '../services/banking_service.dart';
import '../services/premium_service.dart';

/// State notifier for banking features
/// 
/// Manages the state of connected bank accounts and transactions.
/// Integrates with BankingService for API calls and PremiumService for
/// subscription validation.
class BankingNotifier extends ChangeNotifier {
  final BankingService? _bankingService;
  final PremiumService _premiumService;

  List<BankAccount> _accounts = [];
  List<BankTransaction> _transactions = [];
  bool _isPremium = false;
  bool _isLoading = false;
  String? _error;
  DateTime? _lastRefresh;

  BankingNotifier({
    BankingService? bankingService,
    PremiumService? premiumService,
  })  : _bankingService = bankingService,
        _premiumService = premiumService ?? PremiumService();

  // Getters
  List<BankAccount> get accounts => List.unmodifiable(_accounts);
  List<BankTransaction> get transactions => List.unmodifiable(_transactions);
  bool get isPremium => _isPremium;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastRefresh => _lastRefresh;
  bool get hasAccounts => _accounts.isNotEmpty;
  bool get hasTransactions => _transactions.isNotEmpty;

  /// Check if refresh is available (24-hour limit)
  bool get canRefresh {
    if (_lastRefresh == null) return true;
    final difference = DateTime.now().difference(_lastRefresh!);
    return difference.inHours >= 24;
  }

  /// Hours until next refresh is available
  int get hoursUntilRefresh {
    if (_lastRefresh == null) return 0;
    final difference = DateTime.now().difference(_lastRefresh!);
    final remaining = 24 - difference.inHours;
    return remaining > 0 ? remaining : 0;
  }

  /// Initialize banking features - check premium status
  Future<void> initialize() async {
    _setLoading(true);
    try {
      final premiumResult = await _premiumService.checkPremiumStatus();
      _isPremium = premiumResult.isActive;

      if (_isPremium && _bankingService != null) {
        // Load accounts if premium
        await _loadAccounts();
      }

      _clearError();
    } catch (e) {
      _setError('Failed to initialize banking: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Create a bank connection link
  Future<String?> createBankLink({
    required String userId,
    required String institutionId,
    required String redirectUrl,
  }) async {
    if (_bankingService == null) {
      _setError('Banking service not configured');
      return null;
    }

    _setLoading(true);
    try {
      final result = await _bankingService!.createBankLink(
        userId: userId,
        institutionId: institutionId,
        redirectUrl: redirectUrl,
      );

      if (result.isSuccess) {
        _clearError();
        return result.data;
      } else {
        _setError(result.error?.message ?? 'Failed to create bank link');
        return null;
      }
    } catch (e) {
      _setError('Failed to create bank link: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Fetch transactions from bank
  Future<bool> fetchTransactions({
    required String userId,
    required String requisitionId,
  }) async {
    if (_bankingService == null) {
      _setError('Banking service not configured');
      return false;
    }

    if (!canRefresh) {
      _setError(
        'Please wait $hoursUntilRefresh hours before refreshing again',
      );
      return false;
    }

    _setLoading(true);
    try {
      final result = await _bankingService!.fetchTransactions(
        userId: userId,
        requisitionId: requisitionId,
      );

      if (result.isSuccess) {
        _transactions = result.data ?? [];
        _lastRefresh = DateTime.now();
        _clearError();
        notifyListeners();
        return true;
      } else {
        _setError(result.error?.message ?? 'Failed to fetch transactions');
        return false;
      }
    } catch (e) {
      _setError('Failed to fetch transactions: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Load connected accounts
  Future<void> _loadAccounts() async {
    if (_bankingService == null) return;

    try {
      final result = await _bankingService!.getAccounts(userId: 'current');
      if (result.isSuccess) {
        _accounts = result.data ?? [];
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to load accounts: $e');
    }
  }

  /// Show premium paywall
  Future<bool> showPaywall() async {
    return await _premiumService.presentPaywall();
  }

  /// Restore purchases
  Future<void> restorePurchases() async {
    _setLoading(true);
    try {
      final result = await _premiumService.restorePurchases();
      _isPremium = result.isActive;
      if (_isPremium) {
        await _loadAccounts();
      }
      _clearError();
    } catch (e) {
      _setError('Failed to restore purchases: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  /// Clear all banking data (e.g., on logout)
  void clear() {
    _accounts = [];
    _transactions = [];
    _isPremium = false;
    _lastRefresh = null;
    _clearError();
    notifyListeners();
  }
}
