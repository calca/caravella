import 'package:uuid/uuid.dart';
import 'expense_details.dart';
import 'expense_participant.dart';
import 'expense_category.dart';
import 'expense_group_type.dart';

class ExpenseGroup {
  final String id; // UDID per il gruppo di spese
  final String title;
  final List<ExpenseDetails> expenses;
  final List<ExpenseParticipant> participants;
  final DateTime? startDate;
  final DateTime? endDate;
  final String currency; // Nuovo campo
  final List<ExpenseCategory> categories;
  final DateTime timestamp; // Nuovo campo timestamp
  final bool pinned; // Nuovo campo per pinnare il gruppo
  final bool archived; // Nuovo campo per archiviare il gruppo
  final String? file; // Nuovo campo opzionale per il path del file
  final int? color; // Nuovo campo opzionale per il colore (Color.value)
  final ExpenseGroupType? groupType; // Tipologia del gruppo (viaggio, personale, famiglia, altro)
  final bool autoLocationEnabled; // Nuovo campo per abilitare auto-location per gruppo

  ExpenseGroup({
    required this.title,
    required this.expenses,
    required this.participants,
    this.startDate,
    this.endDate,
    required this.currency, // Nuovo campo obbligatorio
    this.categories = const [], // Default empty list
    DateTime? timestamp, // opzionale, default a now
    String? id, // opzionale, generato se mancante
    this.pinned = false, // Default a false
    this.archived = false, // Default a false
    this.file, // Opzionale, path del file
    this.color, // Opzionale, colore del gruppo
    this.groupType, // Opzionale, tipologia del gruppo
    this.autoLocationEnabled = false, // Default a false
  }) : timestamp = timestamp ?? DateTime.now(),
       id = id ?? const Uuid().v4();

  factory ExpenseGroup.fromJson(Map<String, dynamic> json) {
    return ExpenseGroup(
      id: json['id'],
      title: json['title'],
      expenses:
          (json['expenses'] as List<dynamic>?)
              ?.map((e) => ExpenseDetails.fromJson(e))
              .toList() ??
          [],
      participants:
          (json['participants'] as List<dynamic>?)
              ?.map(
                (p) => ExpenseParticipant.fromJson(p as Map<String, dynamic>),
              )
              .toList() ??
          [],
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      currency: json['currency'] ?? '€', // Default a euro se mancante
      categories:
          (json['categories'] as List<dynamic>?)
              ?.map((c) => ExpenseCategory.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      pinned: json['pinned'] ?? false, // Legge il valore pinnato
      archived: json['archived'] ?? false, // Legge il valore archiviato
      file: json['file'], // Legge il valore del file
      color: json['color'], // Legge il valore del colore
      groupType: ExpenseGroupType.fromJson(json['groupType']), // Legge la tipologia
      autoLocationEnabled:
          json['autoLocationEnabled'] ?? false, // Legge il valore auto-location
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'expenses': expenses.map((e) => e.toJson()).toList(),
    'participants': participants.map((p) => p.toJson()).toList(),
    'startDate': startDate?.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'currency': currency,
    'categories': categories.map((c) => c.toJson()).toList(),
    'timestamp': timestamp.toIso8601String(),
    'pinned': pinned, // Salva il valore pinnato
    'archived': archived, // Salva il valore archiviato
    'file': file, // Salva il valore del file
    'color': color, // Salva il valore del colore
    'groupType': groupType?.toJson(), // Salva la tipologia
    'autoLocationEnabled': autoLocationEnabled, // Salva il valore auto-location
  };

  ExpenseGroup copyWith({
    String? id,
    String? title,
    List<ExpenseDetails>? expenses,
    List<ExpenseParticipant>? participants,
    DateTime? startDate,
    DateTime? endDate,
    String? currency,
    List<ExpenseCategory>? categories,
    DateTime? timestamp,
    bool? pinned,
    bool? archived,
    // Special handling for nullable fields that need to support explicit null
    Object? file = _notProvided,
    Object? color = _notProvided,
    Object? groupType = _notProvided,
    bool? autoLocationEnabled,
  }) {
    return ExpenseGroup(
      id: id ?? this.id,
      title: title ?? this.title,
      expenses: expenses ?? this.expenses,
      participants: participants ?? this.participants,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      currency: currency ?? this.currency,
      categories: categories ?? this.categories,
      timestamp: timestamp ?? this.timestamp,
      pinned: pinned ?? this.pinned,
      archived: archived ?? this.archived,
      // Fix: Handle explicit null values correctly for nullable fields
      file: file == _notProvided ? this.file : file as String?,
      color: color == _notProvided ? this.color : color as int?,
      groupType: groupType == _notProvided ? this.groupType : groupType as ExpenseGroupType?,
      autoLocationEnabled: autoLocationEnabled ?? this.autoLocationEnabled,
    );
  }

  // Sentinel value to distinguish between null and not provided
  static const Object _notProvided = Object();

  static ExpenseGroup empty() {
    return ExpenseGroup(
      title: '',
      expenses: const [],
      participants: const <ExpenseParticipant>[],
      startDate: null,
      endDate: null,
      currency: '€',
      categories: const <ExpenseCategory>[],
      timestamp: DateTime.now(),
      id: const Uuid().v4(),
      pinned: false,
      archived: false,
      file: null, // Path del file inizialmente vuoto
      color: null, // Colore inizialmente vuoto
      groupType: null, // Tipologia inizialmente vuota
      autoLocationEnabled: false, // Auto-location disabilitata di default
    );
  }
}
