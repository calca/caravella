/// Bank transaction model for PSD2 integration
class BankTransaction {
  final String id;
  final String accountId;
  final double amount;
  final String currency;
  final DateTime date;
  final String? description;
  final String? creditorName;
  final String? debtorName;
  final String? transactionId;
  final DateTime createdAt;

  const BankTransaction({
    required this.id,
    required this.accountId,
    required this.amount,
    required this.currency,
    required this.date,
    this.description,
    this.creditorName,
    this.debtorName,
    this.transactionId,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'account_id': accountId,
        'amount': amount,
        'currency': currency,
        'date': date.toIso8601String(),
        'description': description,
        'creditor_name': creditorName,
        'debtor_name': debtorName,
        'transaction_id': transactionId,
        'created_at': createdAt.toIso8601String(),
      };

  factory BankTransaction.fromJson(Map<String, dynamic> json) =>
      BankTransaction(
        id: json['id'] as String,
        accountId: json['account_id'] as String,
        amount: (json['amount'] as num).toDouble(),
        currency: json['currency'] as String? ?? 'EUR',
        date: DateTime.parse(json['date'] as String),
        description: json['description'] as String?,
        creditorName: json['creditor_name'] as String?,
        debtorName: json['debtor_name'] as String?,
        transactionId: json['transaction_id'] as String?,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : DateTime.now(),
      );

  BankTransaction copyWith({
    String? id,
    String? accountId,
    double? amount,
    String? currency,
    DateTime? date,
    String? description,
    String? creditorName,
    String? debtorName,
    String? transactionId,
    DateTime? createdAt,
  }) =>
      BankTransaction(
        id: id ?? this.id,
        accountId: accountId ?? this.accountId,
        amount: amount ?? this.amount,
        currency: currency ?? this.currency,
        date: date ?? this.date,
        description: description ?? this.description,
        creditorName: creditorName ?? this.creditorName,
        debtorName: debtorName ?? this.debtorName,
        transactionId: transactionId ?? this.transactionId,
        createdAt: createdAt ?? this.createdAt,
      );
}
