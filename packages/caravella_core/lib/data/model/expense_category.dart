import 'package:uuid/uuid.dart';

class ExpenseCategory {
  final String id; // UDID per la categoria
  final String name;
  final DateTime createdAt;

  ExpenseCategory({
    required this.name,
    String? id, // opzionale, generato se mancante
    DateTime? createdAt, // opzionale, default a now
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  factory ExpenseCategory.fromJson(Map<String, dynamic> json) {
    return ExpenseCategory(
      id: json['id'],
      name: json['name'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'createdAt': createdAt.toIso8601String(),
      };

  ExpenseCategory copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
  }) {
    return ExpenseCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseCategory &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Category{id: $id, name: $name}';
}
