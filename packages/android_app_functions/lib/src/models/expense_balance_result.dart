/// The total balance (sum of all expense amounts) for an expense group.
class ExpenseBalanceResult {
  /// ID of the expense group.
  final String groupId;

  /// Display name of the expense group.
  final String groupTitle;

  /// Sum of all expense amounts in the group.
  final double totalBalance;

  /// Currency symbol (e.g. '€').
  final String currency;

  const ExpenseBalanceResult({
    required this.groupId,
    required this.groupTitle,
    required this.totalBalance,
    required this.currency,
  });

  factory ExpenseBalanceResult.fromMap(Map<dynamic, dynamic> map) {
    return ExpenseBalanceResult(
      groupId: map['groupId'] as String,
      groupTitle: map['groupTitle'] as String,
      totalBalance: (map['totalBalance'] as num).toDouble(),
      currency: map['currency'] as String,
    );
  }

  Map<String, dynamic> toMap() => {
    'groupId': groupId,
    'groupTitle': groupTitle,
    'totalBalance': totalBalance,
    'currency': currency,
  };
}
