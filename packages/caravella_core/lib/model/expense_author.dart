/// Snapshot of "who" performed an action (create/update) on an expense.
///
/// Captured at the time of the action — [deviceName]/[userName] are not
/// re-read later, so historical attribution stays correct even if the
/// device is renamed or the user changes their name afterwards.
class ExpenseAuthor {
  final String deviceId;
  final String? deviceName;
  final String? userName;

  const ExpenseAuthor({
    required this.deviceId,
    this.deviceName,
    this.userName,
  });

  /// The best human-readable label for this author: the personal name if
  /// set, otherwise the device name, otherwise `null` (nothing usable to
  /// display — callers should omit the attribution line entirely).
  String? get displayName {
    if (userName != null && userName!.isNotEmpty) return userName;
    if (deviceName != null && deviceName!.isNotEmpty) return deviceName;
    return null;
  }

  factory ExpenseAuthor.fromJson(Map<String, dynamic> json) {
    return ExpenseAuthor(
      deviceId: json['deviceId'] as String,
      deviceName: json['deviceName'] as String?,
      userName: json['userName'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'deviceId': deviceId,
    if (deviceName != null) 'deviceName': deviceName,
    if (userName != null) 'userName': userName,
  };

  ExpenseAuthor copyWith({
    String? deviceId,
    String? deviceName,
    String? userName,
  }) {
    return ExpenseAuthor(
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
      userName: userName ?? this.userName,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseAuthor &&
          runtimeType == other.runtimeType &&
          deviceId == other.deviceId &&
          deviceName == other.deviceName &&
          userName == other.userName;

  @override
  int get hashCode => deviceId.hashCode ^ deviceName.hashCode ^ userName.hashCode;
}
