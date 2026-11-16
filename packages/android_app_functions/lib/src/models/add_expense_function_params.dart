/// What an AI agent's "add an expense" link carries when the user opens it:
/// the group, and the category and note the agent suggested.
///
/// The expense itself is not in it: with an amount the native App Function
/// saves it at once, so a link is only made when there is none, and the app
/// opens the group for the user to add it.
class AddExpenseFunctionParams {
  /// ID of the target expense group.
  final String groupId;

  /// Optional category name.
  final String? categoryName;

  /// Optional free-text note.
  final String? note;

  const AddExpenseFunctionParams({
    required this.groupId,
    this.categoryName,
    this.note,
  });

  factory AddExpenseFunctionParams.fromMap(Map<dynamic, dynamic> map) {
    return AddExpenseFunctionParams(
      groupId: map['groupId'] as String,
      categoryName: map['categoryName'] as String?,
      note: map['note'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'groupId': groupId,
    if (categoryName != null) 'categoryName': categoryName,
    if (note != null) 'note': note,
  };
}
