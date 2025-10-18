import 'package:flutter/foundation.dart';
import '../models/bank_account.dart';
import '../models/bank_transaction.dart';
import '../services/banking_service.dart';
import '../services/premium_service.dart';
import '../services/local_banking_storage.dart';

/// State notifier for banking features (Local-First)
/// 
/// Manages the state of connected bank accounts and transactions with
/// LOCAL ENCRYPTED STORAGE. All data is stored on device only.
/// 
/// Integrates with:
/// - BankingService for API calls (stateless proxy to GoCardless)
/// - PremiumService for subscription validation
/// - LocalBankingStorage for encrypted local data persistence
class BankingNotifier extends ChangeNotifier {
  final BankingService? _bankingService;
  final PremiumService _premiumService;
  final LocalBankingStorage _localStorage;

  List<BankAccount> _accounts = [];
  List<BankTransaction> _transactions = [];
  bool _isPremium = false;
  bool _isLoading = false;
  String? _error;
  DateTime? _lastRefresh;

  BankingNotifier({
    BankingService? bankingService,
    PremiumService? premiumService,
    LocalBankingStorage? localStorage,
  })  : _bankingService = bankingService,
        _premiumService = premiumService ?? PremiumService(),
        _localStorage = localStorage ?? LocalBankingStorage();

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

  /// Initialize banking features - check premium status and load local data
  Future<void> initialize() async {
    _setLoading(true);
    try {
      final premiumResult = await _premiumService.checkPremiumStatus();
      _isPremium = premiumResult.isActive;

      if (_isPremium) {
        // Load data from local encrypted storage
        await _loadLocalData();
      }

      _clearError();
    } catch (e) {
      _setError('Failed to initialize banking: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load accounts and transactions from local storage
  Future<void> _loadLocalData() async {
    try {
      _accounts = await _localStorage.getAccounts();
      _transactions = await _localStorage.getTransactions();
      _lastRefresh = await _localStorage.getLastRefreshDate();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load local banking data: $e');
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

  /// Fetch transactions from bank and store locally (encrypted)
  /// 
  /// This method:
  /// 1. Checks 24-hour rate limit from local storage
  /// 2. Calls Edge Function proxy to fetch from GoCardless
  /// 3. Encrypts and saves data LOCALLY (never on backend)
  /// 4. Updates last refresh timestamp
  Future<bool> fetchTransactions({
    required String userId,
    required String requisitionId,
  }) async {
    if (_bankingService == null) {
      _setError('Banking service not configured');
      return false;
    }

    // Check rate limit from local storage
    final canRefreshNow = await _localStorage.canRefresh();
    if (!canRefreshNow) {
      final hoursLeft = await _localStorage.hoursUntilRefresh();
      _setError(
        'Please wait $hoursLeft hours before refreshing again',
      );
      return false;
    }

    _setLoading(true);
    try {
      // Fetch from Edge Function proxy (stateless, no backend storage)
      final result = await _bankingService!.fetchTransactions(
        userId: userId,
        requisitionId: requisitionId,
      );

      if (result.isSuccess) {
        final newTransactions = result.data ?? [];
        
        // Save encrypted locally (never on backend!)
        await _localStorage.appendTransactions(newTransactions);
        await _localStorage.setLastRefreshDate();
        
        // Update in-memory state
        _transactions = await _localStorage.getTransactions();
        _lastRefresh = await _localStorage.getLastRefreshDate();
        
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
        await _loadLocalData();
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
  /// This clears local encrypted storage completely
  Future<void> clear() async {
    await _localStorage.clearAll();
    _accounts = [];
    _transactions = [];
    _isPremium = false;
    _lastRefresh = null;
    _clearError();
    notifyListeners();
  }

  /// Complete data wipe including encryption key
  Future<void> deleteAllData() async {
    await _localStorage.deleteEncryptionKey();
    await clear();
  }
}
