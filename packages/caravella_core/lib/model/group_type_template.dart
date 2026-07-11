import 'package:uuid/uuid.dart';

class GroupTypeTemplate {
  final String id;
  final String name;
  final int iconCodePoint;
  final List<String> defaultCategories;
  final DateTime createdAt;

  GroupTypeTemplate({
    required this.name,
    required this.iconCodePoint,
    required this.defaultCategories,
    String? id,
    DateTime? createdAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  factory GroupTypeTemplate.fromJson(Map<String, dynamic> json) {
    return GroupTypeTemplate(
      id: json['id'] as String?,
      name: (json['name'] as String? ?? '').trim(),
      iconCodePoint: (json['iconCodePoint'] as num?)?.toInt() ?? 0,
      defaultCategories:
          (json['defaultCategories'] as List<dynamic>? ?? const [])
              .map((item) => item.toString().trim())
              .where((item) => item.isNotEmpty)
              .toList(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'iconCodePoint': iconCodePoint,
    'defaultCategories': defaultCategories,
    'createdAt': createdAt.toIso8601String(),
  };

  GroupTypeTemplate copyWith({
    String? id,
    String? name,
    int? iconCodePoint,
    List<String>? defaultCategories,
    DateTime? createdAt,
  }) {
    return GroupTypeTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      defaultCategories: defaultCategories ?? this.defaultCategories,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
