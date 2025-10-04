/// Bank account model for PSD2 integration
class BankAccount {
  final String id;
  final String accountId;
  final String? iban;
  final String? accountName;
  final String currency;
  final String? institutionId;
  final DateTime? lastSync;
  final bool isActive;

  const BankAccount({
    required this.id,
    required this.accountId,
    this.iban,
    this.accountName,
    required this.currency,
    this.institutionId,
    this.lastSync,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'account_id': accountId,
        'iban': iban,
        'account_name': accountName,
        'currency': currency,
        'institution_id': institutionId,
        'last_sync': lastSync?.toIso8601String(),
        'is_active': isActive,
      };

  factory BankAccount.fromJson(Map<String, dynamic> json) => BankAccount(
        id: json['id'] as String,
        accountId: json['account_id'] as String,
        iban: json['iban'] as String?,
        accountName: json['account_name'] as String?,
        currency: json['currency'] as String? ?? 'EUR',
        institutionId: json['institution_id'] as String?,
        lastSync: json['last_sync'] != null
            ? DateTime.parse(json['last_sync'] as String)
            : null,
        isActive: json['is_active'] as bool? ?? true,
      );

  BankAccount copyWith({
    String? id,
    String? accountId,
    String? iban,
    String? accountName,
    String? currency,
    String? institutionId,
    DateTime? lastSync,
    bool? isActive,
  }) =>
      BankAccount(
        id: id ?? this.id,
        accountId: accountId ?? this.accountId,
        iban: iban ?? this.iban,
        accountName: accountName ?? this.accountName,
        currency: currency ?? this.currency,
        institutionId: institutionId ?? this.institutionId,
        lastSync: lastSync ?? this.lastSync,
        isActive: isActive ?? this.isActive,
      );
}
