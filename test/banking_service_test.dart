import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/banking/state/banking_notifier.dart';
import 'package:io_caravella_egm/banking/services/banking_service.dart';
import 'package:io_caravella_egm/banking/services/premium_service.dart';
import 'package:io_caravella_egm/banking/services/local_banking_storage.dart';

void main() {
  group('BankingNotifier', () {
    late BankingNotifier notifier;

    setUp(() {
      notifier = BankingNotifier();
    });

    tearDown(() {
      notifier.dispose();
    });

    test('initializes with empty state', () {
      expect(notifier.accounts, isEmpty);
      expect(notifier.transactions, isEmpty);
      expect(notifier.isPremium, false);
      expect(notifier.isLoading, false);
      expect(notifier.error, isNull);
      expect(notifier.lastRefresh, isNull);
      expect(notifier.hasAccounts, false);
      expect(notifier.hasTransactions, false);
    });

    test('canRefresh returns true when lastRefresh is null', () {
      expect(notifier.lastRefresh, isNull);
      expect(notifier.canRefresh, true);
      expect(notifier.hoursUntilRefresh, 0);
    });

    test('clear resets all state', () async {
      await notifier.clear();

      expect(notifier.accounts, isEmpty);
      expect(notifier.transactions, isEmpty);
      expect(notifier.isPremium, false);
      expect(notifier.lastRefresh, isNull);
      expect(notifier.error, isNull);
    });

    test('createBankLink returns null without banking service', () async {
      final result = await notifier.createBankLink(
        userId: 'test-user',
        institutionId: 'test-bank',
        redirectUrl: 'https://test.com',
      );

      expect(result, isNull);
      expect(notifier.error, isNotNull);
      expect(notifier.error, contains('not configured'));
    });

    test('fetchTransactions returns false without banking service', () async {
      final success = await notifier.fetchTransactions(
        userId: 'test-user',
        requisitionId: 'test-req',
      );

      expect(success, false);
      expect(notifier.error, isNotNull);
      expect(notifier.error, contains('not configured'));
    });

    test('initialize calls premium service', () async {
      // Create notifier with mock services
      final notifier = BankingNotifier(
        premiumService: PremiumService(),
      );

      expect(notifier.isLoading, false);

      // Initialize (will fail gracefully with stub service)
      await notifier.initialize();

      // Should complete without throwing
      expect(notifier.isLoading, false);

      notifier.dispose();
    });

    test('hoursUntilRefresh returns 0 when lastRefresh is null', () {
      expect(notifier.hoursUntilRefresh, 0);
    });

    test('hasAccounts returns false when accounts list is empty', () {
      expect(notifier.hasAccounts, false);
    });

    test('hasTransactions returns false when transactions list is empty', () {
      expect(notifier.hasTransactions, false);
    });
  });

  group('BankingService', () {
    test('createBankLink returns not implemented error', () async {
      final service = BankingService(
        supabaseUrl: 'https://test.supabase.co',
        supabaseAnonKey: 'test-key',
      );

      final result = await service.createBankLink(
        userId: 'test-user',
        institutionId: 'test-bank',
        redirectUrl: 'https://test.com',
      );

      expect(result.isFailure, true);
      expect(result.isSuccess, false);
      expect(result.data, isNull);
      expect(result.error, isNotNull);
      expect(result.error!.code, 'NOT_IMPLEMENTED');
      expect(
        result.error!.message,
        contains('bank_proxy Edge Function'),
      );

      service.dispose();
    });

    test('fetchTransactions returns not implemented error', () async {
      final service = BankingService(
        supabaseUrl: 'https://test.supabase.co',
        supabaseAnonKey: 'test-key',
      );

      final result = await service.fetchTransactions(
        userId: 'test-user',
        requisitionId: 'test-req',
      );

      expect(result.isFailure, true);
      expect(result.error!.code, 'NOT_IMPLEMENTED');

      service.dispose();
    });
  });

  group('PremiumService', () {
    test('checkPremiumStatus returns not implemented error', () async {
      final service = PremiumService();

      final result = await service.checkPremiumStatus();

      expect(result.isPremium, false);
      expect(result.isActive, false);
      expect(result.error, isNotNull);
      expect(result.error, contains('RevenueCat SDK setup'));
    });

    test('presentPaywall returns false (stub)', () async {
      final service = PremiumService();

      final result = await service.presentPaywall();

      expect(result, false);
    });

    test('restorePurchases returns not premium', () async {
      final service = PremiumService();

      final result = await service.restorePurchases();

      expect(result.isPremium, false);
      expect(result.error, isNotNull);
    });
  });

  group('BankingResult', () {
    test('success result has data and no error', () {
      final result = BankingResult.success('test-data');

      expect(result.isSuccess, true);
      expect(result.isFailure, false);
      expect(result.data, 'test-data');
      expect(result.error, isNull);
    });

    test('failure result has error and no data', () {
      final error = BankingError(code: 'TEST_ERROR', message: 'Test message');
      final result = BankingResult<String>.failure(error);

      expect(result.isFailure, true);
      expect(result.isSuccess, false);
      expect(result.data, isNull);
      expect(result.error, error);
    });
  });

  group('BankingError', () {
    test('creates error with code and message', () {
      final error = BankingError(
        code: 'TEST_ERROR',
        message: 'Test error message',
      );

      expect(error.code, 'TEST_ERROR');
      expect(error.message, 'Test error message');
      expect(error.details, isNull);
    });

    test('toString includes code and message', () {
      final error = BankingError(
        code: 'TEST_ERROR',
        message: 'Test error message',
      );

      expect(error.toString(), 'BankingError(TEST_ERROR): Test error message');
    });

    test('can include details', () {
      final error = BankingError(
        code: 'TEST_ERROR',
        message: 'Test error message',
        details: {'key': 'value'},
      );

      expect(error.details, {'key': 'value'});
    });
  });

  group('PremiumResult', () {
    test('creates result with premium status', () {
      final result = PremiumResult(
        isPremium: true,
        expirationDate: DateTime(2025, 12, 31),
      );

      expect(result.isPremium, true);
      expect(result.isActive, true);
      expect(result.expirationDate, DateTime(2025, 12, 31));
      expect(result.error, isNull);
    });

    test('isActive returns false when expired', () {
      final result = PremiumResult(
        isPremium: true,
        expirationDate: DateTime(2020, 1, 1),
      );

      expect(result.isPremium, true);
      expect(result.isActive, false);
    });

    test('isActive returns true when no expiration date', () {
      final result = PremiumResult(
        isPremium: true,
      );

      expect(result.isPremium, true);
      expect(result.isActive, true);
    });

    test('can include error message', () {
      final result = PremiumResult(
        isPremium: false,
        error: 'Setup required',
      );

      expect(result.isPremium, false);
      expect(result.isActive, false);
      expect(result.error, 'Setup required');
    });
  });
}
