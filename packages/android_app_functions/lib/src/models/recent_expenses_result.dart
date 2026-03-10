/// A single expense summary returned by the recent-expenses App Function.
class ExpenseSummary {
  final String id;
  final String categoryName;

  /// The expense amount.  May be `null` for pending or draft expenses that have
  /// not yet had an amount assigned.
  final double? amount;
  final String paidByName;
  final DateTime date;
  final String? note;
  final String? name;

  const ExpenseSummary({
    required this.id,
    required this.categoryName,
    this.amount,
    required this.paidByName,
    required this.date,
    this.note,
    this.name,
  });

  factory ExpenseSummary.fromMap(Map<dynamic, dynamic> map) {
    return ExpenseSummary(
      id: map['id'] as String,
      categoryName: map['categoryName'] as String,
      amount: map['amount'] != null ? (map['amount'] as num).toDouble() : null,
      paidByName: map['paidByName'] as String,
      date: DateTime.parse(map['date'] as String),
      note: map['note'] as String?,
      name: map['name'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'categoryName': categoryName,
    if (amount != null) 'amount': amount,
    'paidByName': paidByName,
    'date': date.toIso8601String(),
    if (note != null) 'note': note,
    if (name != null) 'name': name,
  };
}

/// The most recent expenses for an expense group (up to [count] items).
class RecentExpensesResult {
  final String groupId;
  final String groupTitle;
  final String currency;
  final List<ExpenseSummary> expenses;

  const RecentExpensesResult({
    required this.groupId,
    required this.groupTitle,
    required this.currency,
    required this.expenses,
  });

  factory RecentExpensesResult.fromMap(Map<dynamic, dynamic> map) {
    final rawExpenses = map['expenses'] as List<dynamic>? ?? [];
    return RecentExpensesResult(
      groupId: map['groupId'] as String,
      groupTitle: map['groupTitle'] as String,
      currency: map['currency'] as String,
      expenses: rawExpenses
          .map((e) => ExpenseSummary.fromMap(e as Map<dynamic, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() => {
    'groupId': groupId,
    'groupTitle': groupTitle,
    'currency': currency,
    'expenses': expenses.map((e) => e.toMap()).toList(),
  };
}
