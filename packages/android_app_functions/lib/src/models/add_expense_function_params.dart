/// Parameters received from an AI agent to add a new expense.
class AddExpenseFunctionParams {
  /// ID of the target expense group.
  final String groupId;

  /// Expense amount (positive value required).
  final double amount;

  /// Optional category name.
  final String? categoryName;

  /// Optional free-text note.
  final String? note;

  const AddExpenseFunctionParams({
    required this.groupId,
    required this.amount,
    this.categoryName,
    this.note,
  });

  factory AddExpenseFunctionParams.fromMap(Map<dynamic, dynamic> map) {
    return AddExpenseFunctionParams(
      groupId: map['groupId'] as String,
      amount: (map['amount'] as num).toDouble(),
      categoryName: map['categoryName'] as String?,
      note: map['note'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'groupId': groupId,
    'amount': amount,
    if (categoryName != null) 'categoryName': categoryName,
    if (note != null) 'note': note,
  };
}
