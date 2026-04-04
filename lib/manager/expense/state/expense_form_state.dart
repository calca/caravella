import 'package:caravella_core/caravella_core.dart';

/// Immutable state class for expense form
/// Contains all form field values and computed validation state
class ExpenseFormState {
  // Form field values
  final ExpenseCategory? category;
  final double? amount;
  final ExpenseParticipant? paidBy;
  final DateTime date;
  final ExpenseLocation? location;
  final String name;
  final String note;
  final List<String> attachments;
  final List<ExpenseParticipant> assignedTo;

  // UI state
  final bool isDirty;
  final bool isExpanded;
  final bool isRetrievingLocation;

  // Touched state for validation feedback
  final bool amountTouched;
  final bool paidByTouched;
  final bool categoryTouched;

  const ExpenseFormState({
    this.category,
    this.amount,
    this.paidBy,
    required this.date,
    this.location,
    this.name = '',
    this.note = '',
    this.attachments = const [],
    this.assignedTo = const [],
    this.isDirty = false,
    this.isExpanded = false,
    this.isRetrievingLocation = false,
    this.amountTouched = false,
    this.paidByTouched = false,
    this.categoryTouched = false,
  });

  // Computed validation state
  bool get isNameValid => name.trim().isNotEmpty;
  bool get isAmountValid => amount != null && amount! > 0;
  bool get isPaidByValid => paidBy != null;
  bool isCategoryValid(List<ExpenseCategory> categories) =>
      categories.isEmpty || category != null;

  bool isFormValid(List<ExpenseCategory> categories) =>
      isNameValid &&
      isAmountValid &&
      isPaidByValid &&
      isCategoryValid(categories);

  // Factory for creating initial state
  factory ExpenseFormState.initial({
    required List<ExpenseParticipant> participants,
    required List<ExpenseCategory> categories,
  }) {
    return ExpenseFormState(
      date: DateTime.now(),
      paidBy: participants.isNotEmpty ? participants.first : null,
      category: categories.isNotEmpty ? categories.first : null,
    );
  }

  // Factory for creating state from existing expense
  factory ExpenseFormState.fromExpense(
    ExpenseDetails expense,
    List<ExpenseCategory> categories,
  ) {
    return ExpenseFormState(
      category: categories.firstWhere(
        (c) => c.id == expense.category.id,
        orElse: () => categories.isNotEmpty
            ? categories.first
            : ExpenseCategory(name: '', id: '', createdAt: DateTime(2000)),
      ),
      amount: expense.amount,
      paidBy: expense.paidBy,
      date: expense.date,
      location: expense.location,
      name: expense.name ?? '',
      note: expense.note ?? '',
      attachments: List.from(expense.attachments),
    );
  }

  // CopyWith method for immutable updates
  ExpenseFormState copyWith({
    ExpenseCategory? category,
    double? amount,
    ExpenseParticipant? paidBy,
    DateTime? date,
    ExpenseLocation? location,
    String? name,
    String? note,
    List<String>? attachments,
    List<ExpenseParticipant>? assignedTo,
    bool? isDirty,
    bool? isExpanded,
    bool? isRetrievingLocation,
    bool? amountTouched,
    bool? paidByTouched,
    bool? categoryTouched,
  }) {
    return ExpenseFormState(
      category: category ?? this.category,
      amount: amount ?? this.amount,
      paidBy: paidBy ?? this.paidBy,
      date: date ?? this.date,
      location: location ?? this.location,
      name: name ?? this.name,
      note: note ?? this.note,
      attachments: attachments ?? this.attachments,
      assignedTo: assignedTo ?? this.assignedTo,
      isDirty: isDirty ?? this.isDirty,
      isExpanded: isExpanded ?? this.isExpanded,
      isRetrievingLocation: isRetrievingLocation ?? this.isRetrievingLocation,
      amountTouched: amountTouched ?? this.amountTouched,
      paidByTouched: paidByTouched ?? this.paidByTouched,
      categoryTouched: categoryTouched ?? this.categoryTouched,
    );
  }

  // Convert to ExpenseDetails model
  ExpenseDetails toExpense({String? id}) {
    return ExpenseDetails(
      id: id,
      category: category!,
      name: name.isEmpty ? null : name,
      amount: amount,
      paidBy: paidBy!,
      date: date,
      location: location,
      note: note.isEmpty ? null : note,
      attachments: attachments,
    );
  }
}
