import 'package:uuid/uuid.dart';

class Participant {
  final String id; // UDID per il partecipante
  final String name;
  final DateTime createdAt;

  Participant({
    required this.name,
    String? id, // opzionale, generato se mancante
    DateTime? createdAt, // opzionale, default a now
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
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

  Participant copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
  }) {
    return Participant(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Participant &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Participant{id: $id, name: $name}';
}
