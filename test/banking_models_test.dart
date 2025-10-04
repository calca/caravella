import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/banking/models/bank_account.dart';
import 'package:io_caravella_egm/banking/models/bank_transaction.dart';
import 'package:io_caravella_egm/banking/models/bank_requisition.dart';

void main() {
  group('Banking Models', () {
    group('BankAccount', () {
      test('creates account with required fields', () {
        final account = BankAccount(
          id: 'test-id',
          accountId: 'account-123',
          currency: 'EUR',
        );

        expect(account.id, 'test-id');
        expect(account.accountId, 'account-123');
        expect(account.currency, 'EUR');
        expect(account.isActive, true);
      });

      test('serializes to JSON correctly', () {
        final account = BankAccount(
          id: 'test-id',
          accountId: 'account-123',
          iban: 'DE89370400440532013000',
          accountName: 'Test Account',
          currency: 'EUR',
          institutionId: 'TESTBANK_TEST',
          lastSync: DateTime(2024, 1, 1),
          isActive: true,
        );

        final json = account.toJson();

        expect(json['id'], 'test-id');
        expect(json['account_id'], 'account-123');
        expect(json['iban'], 'DE89370400440532013000');
        expect(json['account_name'], 'Test Account');
        expect(json['currency'], 'EUR');
        expect(json['institution_id'], 'TESTBANK_TEST');
        expect(json['last_sync'], '2024-01-01T00:00:00.000');
        expect(json['is_active'], true);
      });

      test('deserializes from JSON correctly', () {
        final json = {
          'id': 'test-id',
          'account_id': 'account-123',
          'iban': 'DE89370400440532013000',
          'account_name': 'Test Account',
          'currency': 'EUR',
          'institution_id': 'TESTBANK_TEST',
          'last_sync': '2024-01-01T00:00:00.000',
          'is_active': true,
        };

        final account = BankAccount.fromJson(json);

        expect(account.id, 'test-id');
        expect(account.accountId, 'account-123');
        expect(account.iban, 'DE89370400440532013000');
        expect(account.accountName, 'Test Account');
        expect(account.currency, 'EUR');
        expect(account.institutionId, 'TESTBANK_TEST');
        expect(account.lastSync, DateTime(2024, 1, 1));
        expect(account.isActive, true);
      });

      test('copyWith creates modified copy', () {
        final account = BankAccount(
          id: 'test-id',
          accountId: 'account-123',
          currency: 'EUR',
          isActive: true,
        );

        final modified = account.copyWith(
          isActive: false,
          accountName: 'Updated Name',
        );

        expect(modified.id, 'test-id');
        expect(modified.accountId, 'account-123');
        expect(modified.isActive, false);
        expect(modified.accountName, 'Updated Name');
      });
    });

    group('BankTransaction', () {
      test('creates transaction with required fields', () {
        final transaction = BankTransaction(
          id: 'tx-123',
          accountId: 'account-123',
          amount: 50.0,
          currency: 'EUR',
          date: DateTime(2024, 1, 15),
          createdAt: DateTime(2024, 1, 15),
        );

        expect(transaction.id, 'tx-123');
        expect(transaction.accountId, 'account-123');
        expect(transaction.amount, 50.0);
        expect(transaction.currency, 'EUR');
        expect(transaction.date, DateTime(2024, 1, 15));
      });

      test('serializes to JSON correctly', () {
        final transaction = BankTransaction(
          id: 'tx-123',
          accountId: 'account-123',
          amount: -25.50,
          currency: 'EUR',
          date: DateTime(2024, 1, 15),
          description: 'Coffee Shop',
          creditorName: 'Cafe ABC',
          debtorName: 'John Doe',
          transactionId: 'tx-ext-456',
          createdAt: DateTime(2024, 1, 15, 10, 30),
        );

        final json = transaction.toJson();

        expect(json['id'], 'tx-123');
        expect(json['account_id'], 'account-123');
        expect(json['amount'], -25.50);
        expect(json['currency'], 'EUR');
        expect(json['date'], '2024-01-15T00:00:00.000');
        expect(json['description'], 'Coffee Shop');
        expect(json['creditor_name'], 'Cafe ABC');
        expect(json['debtor_name'], 'John Doe');
        expect(json['transaction_id'], 'tx-ext-456');
      });

      test('deserializes from JSON correctly', () {
        final json = {
          'id': 'tx-123',
          'account_id': 'account-123',
          'amount': 100.50,
          'currency': 'EUR',
          'date': '2024-01-15T00:00:00.000',
          'description': 'Salary',
          'created_at': '2024-01-15T10:30:00.000',
        };

        final transaction = BankTransaction.fromJson(json);

        expect(transaction.id, 'tx-123');
        expect(transaction.accountId, 'account-123');
        expect(transaction.amount, 100.50);
        expect(transaction.currency, 'EUR');
        expect(transaction.description, 'Salary');
      });

      test('handles integer amounts correctly', () {
        final json = {
          'id': 'tx-123',
          'account_id': 'account-123',
          'amount': 100, // Integer, not double
          'currency': 'EUR',
          'date': '2024-01-15T00:00:00.000',
          'created_at': '2024-01-15T10:30:00.000',
        };

        final transaction = BankTransaction.fromJson(json);

        expect(transaction.amount, 100.0);
        expect(transaction.amount.runtimeType, double);
      });
    });

    group('BankRequisition', () {
      test('creates requisition with required fields', () {
        final requisition = BankRequisition(
          id: 'req-123',
          userId: 'user-456',
          status: 'pending',
          createdAt: DateTime(2024, 1, 1),
        );

        expect(requisition.id, 'req-123');
        expect(requisition.userId, 'user-456');
        expect(requisition.status, 'pending');
        expect(requisition.isPending, true);
      });

      test('serializes to JSON correctly', () {
        final requisition = BankRequisition(
          id: 'req-123',
          userId: 'user-456',
          institutionId: 'TESTBANK_TEST',
          redirectUrl: 'https://app.com/callback',
          status: 'active',
          createdAt: DateTime(2024, 1, 1),
          expiresAt: DateTime(2024, 4, 1),
          accountIds: ['acc-1', 'acc-2'],
        );

        final json = requisition.toJson();

        expect(json['id'], 'req-123');
        expect(json['user_id'], 'user-456');
        expect(json['institution_id'], 'TESTBANK_TEST');
        expect(json['redirect_url'], 'https://app.com/callback');
        expect(json['status'], 'active');
        expect(json['account_ids'], ['acc-1', 'acc-2']);
      });

      test('deserializes from JSON correctly', () {
        final json = {
          'id': 'req-123',
          'user_id': 'user-456',
          'institution_id': 'TESTBANK_TEST',
          'status': 'active',
          'created_at': '2024-01-01T00:00:00.000',
          'expires_at': '2024-04-01T00:00:00.000',
          'account_ids': ['acc-1', 'acc-2'],
        };

        final requisition = BankRequisition.fromJson(json);

        expect(requisition.id, 'req-123');
        expect(requisition.userId, 'user-456');
        expect(requisition.status, 'active');
        expect(requisition.accountIds, ['acc-1', 'acc-2']);
      });

      test('status checks work correctly', () {
        final pending = BankRequisition(
          id: 'req-1',
          userId: 'user-1',
          status: 'pending',
          createdAt: DateTime.now(),
        );
        expect(pending.isPending, true);
        expect(pending.isActive, false);

        final active = BankRequisition(
          id: 'req-2',
          userId: 'user-1',
          status: 'active',
          createdAt: DateTime.now(),
        );
        expect(active.isActive, true);
        expect(active.isPending, false);

        final failed = BankRequisition(
          id: 'req-3',
          userId: 'user-1',
          status: 'failed',
          createdAt: DateTime.now(),
        );
        expect(failed.isFailed, true);
      });

      test('expiration check works correctly', () {
        final expired = BankRequisition(
          id: 'req-1',
          userId: 'user-1',
          status: 'pending',
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().subtract(const Duration(days: 1)),
        );
        expect(expired.isExpired, true);

        final valid = BankRequisition(
          id: 'req-2',
          userId: 'user-1',
          status: 'pending',
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(days: 90)),
        );
        expect(valid.isExpired, false);

        final noExpiry = BankRequisition(
          id: 'req-3',
          userId: 'user-1',
          status: 'pending',
          createdAt: DateTime.now(),
        );
        expect(noExpiry.isExpired, false);
      });
    });
  });
}
