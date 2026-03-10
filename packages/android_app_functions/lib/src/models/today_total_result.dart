/// Total amount spent today for an expense group.
class TodayTotalResult {
  /// ID of the expense group.
  final String groupId;

  /// Display name of the expense group.
  final String groupTitle;

  /// Sum of all expenses whose date matches today's date.
  final double todayTotal;

  /// Currency symbol (e.g. '€').
  final String currency;

  const TodayTotalResult({
    required this.groupId,
    required this.groupTitle,
    required this.todayTotal,
    required this.currency,
  });

  factory TodayTotalResult.fromMap(Map<dynamic, dynamic> map) {
    return TodayTotalResult(
      groupId: map['groupId'] as String,
      groupTitle: map['groupTitle'] as String,
      todayTotal: (map['todayTotal'] as num).toDouble(),
      currency: map['currency'] as String,
    );
  }

  Map<String, dynamic> toMap() => {
    'groupId': groupId,
    'groupTitle': groupTitle,
    'todayTotal': todayTotal,
    'currency': currency,
  };
}
