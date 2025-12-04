/// Status for a group item indicating the balance state
enum GroupStatus {
  positive, // You're owed money
  negative, // You owe money
  settled,  // All balanced
}

/// Model for group items displayed in the active groups list.
class GroupItem {
  /// Unique identifier for the group
  final String id;
  
  /// Name of the group
  final String name;
  
  /// Last activity timestamp
  final DateTime lastActivity;
  
  /// Balance amount (positive or negative)
  final double amount;
  
  /// Status indicating balance state
  final GroupStatus status;
  
  /// Optional emoji for the group
  final String? emoji;

  const GroupItem({
    required this.id,
    required this.name,
    required this.lastActivity,
    required this.amount,
    required this.status,
    this.emoji,
  });

  factory GroupItem.fromJson(Map<String, dynamic> json) {
    return GroupItem(
      id: json['id'] as String,
      name: json['name'] as String,
      lastActivity: DateTime.parse(json['lastActivity'] as String),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      status: GroupStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => GroupStatus.settled,
      ),
      emoji: json['emoji'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'lastActivity': lastActivity.toIso8601String(),
      'amount': amount,
      'status': status.name,
      'emoji': emoji,
    };
  }

  GroupItem copyWith({
    String? id,
    String? name,
    DateTime? lastActivity,
    double? amount,
    GroupStatus? status,
    String? emoji,
  }) {
    return GroupItem(
      id: id ?? this.id,
      name: name ?? this.name,
      lastActivity: lastActivity ?? this.lastActivity,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      emoji: emoji ?? this.emoji,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GroupItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          lastActivity == other.lastActivity &&
          amount == other.amount &&
          status == other.status &&
          emoji == other.emoji;

  @override
  int get hashCode => Object.hash(id, name, lastActivity, amount, status, emoji);
}
