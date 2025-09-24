import 'package:uuid/uuid.dart';

class ExpenseParticipant {
  final String id; // UDID per il partecipante
  final String name;
  final DateTime createdAt;

  ExpenseParticipant({
    required this.name,
    String? id, // opzionale, generato se mancante
    DateTime? createdAt, // opzionale, default a now
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  factory ExpenseParticipant.fromJson(Map<String, dynamic> json) {
    return ExpenseParticipant(
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

  ExpenseParticipant copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
  }) {
    return ExpenseParticipant(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseParticipant &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Participant{id: $id, name: $name}';
}
