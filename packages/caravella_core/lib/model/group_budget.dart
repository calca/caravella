/// What a [GroupBudget]'s amount covers: the whole group, or each calendar
/// month, week or day.
enum BudgetPeriod {
  total,
  monthly,
  weekly,
  daily;

  String toJson() => name;

  /// The period named [value]; null for an unknown or missing one.
  static BudgetPeriod? fromJson(Object? value) {
    for (final p in values) {
      if (p.name == value) return p;
    }
    return null;
  }
}

/// How much a group means to spend: [amount] (in the group currency) for
/// each [period]. Set in the group's settings and synced with it.
class GroupBudget {
  final double amount;
  final BudgetPeriod period;

  const GroupBudget({required this.amount, required this.period});

  Map<String, dynamic> toJson() => {
    'amount': amount,
    'period': period.toJson(),
  };

  /// The budget in [json], or null when there is none (or it is unreadable:
  /// no positive amount, or a period this version doesn't know).
  static GroupBudget? fromJson(Object? json) {
    if (json is! Map) return null;
    final amount = json['amount'];
    final period = BudgetPeriod.fromJson(json['period']);
    if (amount is! num || amount <= 0 || period == null) return null;
    return GroupBudget(amount: amount.toDouble(), period: period);
  }

  @override
  bool operator ==(Object other) =>
      other is GroupBudget && other.amount == amount && other.period == period;

  @override
  int get hashCode => Object.hash(amount, period);

  @override
  String toString() => 'GroupBudget($amount / ${period.name})';
}
