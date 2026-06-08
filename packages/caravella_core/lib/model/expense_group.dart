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
  final bool notificationEnabled; // Campo per abilitare la notifica persistente
  final ExpenseGroupType?
  groupType; // Tipologia del gruppo (viaggio, personale, famiglia, altro)
  final bool
  autoLocationEnabled; // Nuovo campo per abilitare auto-location per gruppo
  final bool syncEnabled; // Whether this group is shared/synced with other devices

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
    this.notificationEnabled = false, // Default a false
    this.groupType, // Opzionale, tipologia del gruppo
    this.autoLocationEnabled = false, // Default a false
    this.syncEnabled = false, // Default a false
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
      notificationEnabled:
          json['notificationEnabled'] ??
          false, // Legge il valore della notifica
      groupType: ExpenseGroupType.fromJson(
        json['groupType'],
      ), // Legge la tipologia
      autoLocationEnabled:
          json['autoLocationEnabled'] ?? false, // Legge il valore auto-location
      syncEnabled: json['syncEnabled'] ?? false, // Legge il valore sync
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
    'notificationEnabled':
        notificationEnabled, // Salva il valore della notifica
    'groupType': groupType?.toJson(), // Salva la tipologia
    'autoLocationEnabled': autoLocationEnabled, // Salva il valore auto-location
    'syncEnabled': syncEnabled, // Salva il valore sync
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
    bool? notificationEnabled,
    // Special handling for nullable fields that need to support explicit null
    Object? file = _notProvided,
    Object? color = _notProvided,
    Object? groupType = _notProvided,
    bool? autoLocationEnabled,
    bool? syncEnabled,
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
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      // Fix: Handle explicit null values correctly for nullable fields
      file: file == _notProvided ? this.file : file as String?,
      color: color == _notProvided ? this.color : color as int?,
      groupType: groupType == _notProvided
          ? this.groupType
          : groupType as ExpenseGroupType?,
      autoLocationEnabled: autoLocationEnabled ?? this.autoLocationEnabled,
      syncEnabled: syncEnabled ?? this.syncEnabled,
    );
  }

  // Sentinel value to distinguish between null and not provided
  static const Object _notProvided = Object();

  /// Calcola il totale delle spese del gruppo
  double getTotalExpenses() {
    return expenses.fold<double>(
      0,
      (sum, expense) => sum + (expense.amount ?? 0),
    );
  }

  /// Calcola la media giornaliera delle spese (totale / giorni distinti con spese).
  /// Restituisce 0.0 se non ci sono spese.
  double getDailyAverage() {
    if (expenses.isEmpty) return 0.0;
    final days = expenses
        .map((e) => DateTime(e.date.year, e.date.month, e.date.day))
        .toSet()
        .length;
    return days == 0 ? 0.0 : getTotalExpenses() / days;
  }

  /// Calcola la media mensile delle spese (totale / mesi dal primo all'ultimo).
  /// Restituisce 0.0 se non ci sono spese.
  double getMonthlyAverage() {
    if (expenses.isEmpty) return 0.0;
    final dates = expenses.map((e) => e.date).toList()..sort();
    final first = dates.first;
    final last = dates.last;
    int months = (last.year - first.year) * 12 + (last.month - first.month) + 1;
    if (months <= 0) months = 1;
    return getTotalExpenses() / months;
  }

  /// Restituisce il totale per ogni categoria del gruppo.
  /// La mappa ha come chiave la categoria e come valore il totale delle spese.
  Map<ExpenseCategory, double> getCategoryTotals() {
    final totals = <ExpenseCategory, double>{};
    for (final category in categories) {
      totals[category] = expenses
          .where((e) => e.category.id == category.id)
          .fold<double>(0.0, (sum, e) => sum + (e.amount ?? 0.0));
    }
    return totals;
  }

  /// Restituisce il totale pagato per ogni partecipante (keyed by participant id).
  Map<String, double> getParticipantTotals() {
    final totals = <String, double>{};
    for (final p in participants) {
      totals[p.id] = 0.0;
    }
    for (final e in expenses) {
      totals[e.paidBy.id] = (totals[e.paidBy.id] ?? 0.0) + (e.amount ?? 0.0);
    }
    return totals;
  }

  /// Returns the number of expenses paid by each participant (keyed by participant id).
  Map<String, int> getParticipantActivityCounts() {
    final counts = <String, int>{};
    for (final e in expenses) {
      final id = e.paidBy.id;
      counts[id] = (counts[id] ?? 0) + 1;
    }
    return counts;
  }

  /// Returns the total amount of expenses not associated with any group category.
  double getUncategorizedTotal() {
    final categoryIds = {for (final c in categories) c.id};
    return expenses
        .where((e) => !categoryIds.contains(e.category.id))
        .fold<double>(0.0, (sum, e) => sum + (e.amount ?? 0.0));
  }

  /// Returns the total amount spent today (local date).
  /// Accepts an optional [reference] date (defaults to [DateTime.now()]) to aid testability.
  double getTodaySpendingSync([DateTime? reference]) {
    if (expenses.isEmpty) return 0.0;
    final now = reference ?? DateTime.now();
    return expenses
        .where(
          (e) =>
              e.date.year == now.year &&
              e.date.month == now.month &&
              e.date.day == now.day,
        )
        .fold<double>(0.0, (sum, e) => sum + (e.amount ?? 0.0));
  }

  /// Returns the average amount spent per participant.
  /// Returns 0.0 if there are no participants.
  double getAveragePerParticipant() {
    if (participants.isEmpty) return 0.0;
    return getTotalExpenses() / participants.length;
  }

  /// Returns the effective statistics date range for the group.
  ///
  /// - If [startDate] and [endDate] are both set, uses them capped at today.
  /// - Otherwise falls back to [first expense date … today].
  /// - If there are no expenses and no dates, defaults to the current month.
  ///
  /// Accepts an optional [now] reference (defaults to [DateTime.now()]) to aid testability.
  ({DateTime start, DateTime end}) getEffectiveDateRange([DateTime? now]) {
    final ref = now ?? DateTime.now();
    final today = DateTime(ref.year, ref.month, ref.day);
    if (startDate != null && endDate != null) {
      final start = DateTime(startDate!.year, startDate!.month, startDate!.day);
      final end = DateTime(endDate!.year, endDate!.month, endDate!.day);
      final effectiveEnd = end.isBefore(today) ? end : today;
      return (start: start, end: effectiveEnd);
    }
    if (expenses.isEmpty) {
      final firstDay = DateTime(today.year, today.month, 1);
      final lastDay = DateTime(today.year, today.month + 1, 0);
      return (start: firstDay, end: lastDay);
    }
    final sorted = [...expenses]..sort((a, b) => a.date.compareTo(b.date));
    final first = sorted.first.date;
    return (
      start: DateTime(first.year, first.month, first.day),
      end: today,
    );
  }

  /// Returns participants sorted by number of expenses paid (descending).
  /// Participants with zero activity are included at the end.
  List<ExpenseParticipantCount> getParticipantsByActivity() {
    final counts = getParticipantActivityCounts();
    final items = <ExpenseParticipantCount>[];
    final seenIds = <String>{};
    for (final entry in counts.entries) {
      final p = participants.firstWhere(
        (p) => p.id == entry.key,
        orElse: () => ExpenseParticipant(id: entry.key, name: ''),
      );
      if (p.name.isNotEmpty) {
        items.add(ExpenseParticipantCount(p, entry.value));
        seenIds.add(p.id);
      }
    }
    for (final p in participants) {
      if (!seenIds.contains(p.id)) {
        items.add(ExpenseParticipantCount(p, 0));
      }
    }
    items.sort((a, b) => b.count.compareTo(a.count));
    return items;
  }

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
      notificationEnabled: false, // Notifica inizialmente disabilitata
      groupType: null, // Tipologia inizialmente vuota
      autoLocationEnabled: false, // Auto-location disabilitata di default
      syncEnabled: false, // Sync disabilitato di default
    );
  }
}

/// Associates an [ExpenseParticipant] with a count of expenses they have paid.
class ExpenseParticipantCount {
  final ExpenseParticipant participant;
  final int count;
  ExpenseParticipantCount(this.participant, this.count);
}
