/// Bank requisition model for PSD2 OAuth flow
class BankRequisition {
  final String id;
  final String userId;
  final String? institutionId;
  final String? redirectUrl;
  final String status;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final List<String>? accountIds;

  const BankRequisition({
    required this.id,
    required this.userId,
    this.institutionId,
    this.redirectUrl,
    required this.status,
    required this.createdAt,
    this.expiresAt,
    this.accountIds,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'institution_id': institutionId,
        'redirect_url': redirectUrl,
        'status': status,
        'created_at': createdAt.toIso8601String(),
        'expires_at': expiresAt?.toIso8601String(),
        'account_ids': accountIds,
      };

  factory BankRequisition.fromJson(Map<String, dynamic> json) =>
      BankRequisition(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        institutionId: json['institution_id'] as String?,
        redirectUrl: json['redirect_url'] as String?,
        status: json['status'] as String? ?? 'pending',
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : DateTime.now(),
        expiresAt: json['expires_at'] != null
            ? DateTime.parse(json['expires_at'] as String)
            : null,
        accountIds: json['account_ids'] != null
            ? List<String>.from(json['account_ids'] as List)
            : null,
      );

  BankRequisition copyWith({
    String? id,
    String? userId,
    String? institutionId,
    String? redirectUrl,
    String? status,
    DateTime? createdAt,
    DateTime? expiresAt,
    List<String>? accountIds,
  }) =>
      BankRequisition(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        institutionId: institutionId ?? this.institutionId,
        redirectUrl: redirectUrl ?? this.redirectUrl,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        expiresAt: expiresAt ?? this.expiresAt,
        accountIds: accountIds ?? this.accountIds,
      );

  bool get isExpired =>
      expiresAt != null && DateTime.now().isAfter(expiresAt!);
  bool get isPending => status == 'pending';
  bool get isActive => status == 'active';
  bool get isFailed => status == 'failed';
}
