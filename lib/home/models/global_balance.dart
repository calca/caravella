/// Model for global balance displayed on the home page dashboard.
class GlobalBalance {
  /// Total balance (positive if owed to you, negative if you owe)
  final double total;
  
  /// Amount owed to you by others
  final double owedToYou;
  
  /// Amount you owe to others
  final double youOwe;

  const GlobalBalance({
    required this.total,
    required this.owedToYou,
    required this.youOwe,
  });

  factory GlobalBalance.fromJson(Map<String, dynamic> json) {
    return GlobalBalance(
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      owedToYou: (json['owedToYou'] as num?)?.toDouble() ?? 0.0,
      youOwe: (json['youOwe'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'owedToYou': owedToYou,
      'youOwe': youOwe,
    };
  }

  GlobalBalance copyWith({
    double? total,
    double? owedToYou,
    double? youOwe,
  }) {
    return GlobalBalance(
      total: total ?? this.total,
      owedToYou: owedToYou ?? this.owedToYou,
      youOwe: youOwe ?? this.youOwe,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GlobalBalance &&
          runtimeType == other.runtimeType &&
          total == other.total &&
          owedToYou == other.owedToYou &&
          youOwe == other.youOwe;

  @override
  int get hashCode => Object.hash(total, owedToYou, youOwe);
}
