import 'package:flutter/material.dart';
import 'package:caravella_core/caravella_core.dart';
import 'expense_form_state.dart';
import 'expense_form_validator.dart';

/// Controller for expense form that manages all TextEditingControllers,
/// FocusNodes, and state updates
class ExpenseFormController extends ChangeNotifier {
  // Text editing controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  // Focus nodes
  final FocusNode nameFocus = FocusNode();
  final FocusNode amountFocus = FocusNode();
  final FocusNode locationFocus = FocusNode();
  final FocusNode noteFocus = FocusNode();

  // Keys for scroll coordination
  final GlobalKey amountFieldKey = GlobalKey();
  final GlobalKey nameFieldKey = GlobalKey();
  final GlobalKey locationFieldKey = GlobalKey();
  final GlobalKey noteFieldKey = GlobalKey();

  // Current state
  ExpenseFormState _state;
  List<ExpenseCategory> _categories;
  bool _isInitializing = true;

  ExpenseFormController({
    required ExpenseFormState initialState,
    required List<ExpenseCategory> categories,
  })  : _state = initialState,
        _categories = List.from(categories) {
    _initializeFromState();
    _setupListeners();
  }

  // Getters
  ExpenseFormState get state => _state;
  List<ExpenseCategory> get categories => _categories;
  bool get isInitializing => _isInitializing;
  bool get isFormValid =>
      ExpenseFormValidator.isFormValid(_state, _categories);

  // Field validation getters
  bool get isAmountValid => ExpenseFormValidator.isAmountValid(_state.amount);
  bool get isPaidByValid => ExpenseFormValidator.isPaidByValid(_state.paidBy);
  bool isCategoryValid(bool noCategoriesExist) =>
      ExpenseFormValidator.isCategoryValid(
        _state.category,
        noCategoriesExist ? [] : _categories,
      );
  bool get isNameValid => _state.name.trim().isNotEmpty;

  // Touch state getters
  bool get amountTouched => _state.amountTouched;
  bool get paidByTouched => _state.paidByTouched;
  bool get categoryTouched => _state.categoryTouched;

  // Expansion state
  bool get isExpanded => _state.isExpanded;

  // Parse amount helper
  double? parseLocalizedAmount(String input) =>
      ExpenseFormValidator.parseAmount(input);

  // Initialize controllers from state
  void _initializeFromState() {
    nameController.text = _state.name;
    amountController.text =
        _state.amount != null && _state.amount! > 0
            ? _state.amount.toString()
            : '';
    noteController.text = _state.note;
  }

  // Setup listeners for text changes
  void _setupListeners() {
    nameController.addListener(_onNameChanged);
    amountController.addListener(_onAmountChanged);
    noteController.addListener(_onNoteChanged);

    amountFocus.addListener(_onAmountFocusChanged);
  }

  void _onNameChanged() {
    if (_isInitializing) return;
    _updateState(_state.copyWith(
      name: nameController.text,
      isDirty: true,
    ));
  }

  void _onAmountChanged() {
    if (_isInitializing) return;
    final amount = ExpenseFormValidator.parseAmount(amountController.text);
    _updateState(_state.copyWith(
      amount: amount,
      isDirty: true,
    ));
  }

  void _onNoteChanged() {
    if (_isInitializing) return;
    _updateState(_state.copyWith(
      note: noteController.text,
      isDirty: true,
    ));
  }

  void _onAmountFocusChanged() {
    if (amountFocus.hasFocus && !_state.amountTouched) {
      _updateState(_state.copyWith(amountTouched: true));
    }
  }

  // State update methods
  void _updateState(ExpenseFormState newState) {
    _state = newState;
    notifyListeners();
  }

  void updateCategory(ExpenseCategory? category) {
    _updateState(_state.copyWith(
      category: category,
      categoryTouched: true,
      isDirty: !_isInitializing,
    ));
  }

  void updatePaidBy(ExpenseParticipant? paidBy) {
    _updateState(_state.copyWith(
      paidBy: paidBy,
      paidByTouched: true,
      isDirty: !_isInitializing,
    ));
  }

  void updateDate(DateTime date) {
    _updateState(_state.copyWith(
      date: date,
      isDirty: !_isInitializing,
    ));
  }

  void updateLocation(ExpenseLocation? location) {
    _updateState(_state.copyWith(
      location: location,
      isDirty: !_isInitializing,
    ));
  }

  void setLocationRetrieving(bool isRetrieving) {
    _updateState(_state.copyWith(isRetrievingLocation: isRetrieving));
  }

  void updateAssignedTo(List<ExpenseParticipant> assignedTo) {
    _updateState(_state.copyWith(
      assignedTo: assignedTo,
      isDirty: !_isInitializing,
    ));
  }

  void addAttachment(String path) {
    final newAttachments = List<String>.from(_state.attachments)..add(path);
    _updateState(_state.copyWith(
      attachments: newAttachments,
      isDirty: !_isInitializing,
    ));
  }

  void removeAttachment(int index) {
    final newAttachments = List<String>.from(_state.attachments)
      ..removeAt(index);
    _updateState(_state.copyWith(
      attachments: newAttachments,
      isDirty: !_isInitializing,
    ));
  }

  void addCategory(ExpenseCategory category) {
    _categories.add(category);
    _updateState(_state.copyWith(
      category: category,
      isDirty: !_isInitializing,
    ));
  }

  void expandForm() {
    _updateState(_state.copyWith(isExpanded: true));
  }

  void finishInitialization() {
    _isInitializing = false;
    _updateState(_state.copyWith(isDirty: false));
  }

  void markDirty() {
    if (!_isInitializing) {
      _updateState(_state.copyWith(isDirty: true));
    }
  }

  // Reset form state
  void reset({
    required List<ExpenseParticipant> participants,
    required List<ExpenseCategory> categories,
  }) {
    _categories = List.from(categories);
    _state = ExpenseFormState.initial(
      participants: participants,
      categories: categories,
    );
    _initializeFromState();
    _isInitializing = false;
    notifyListeners();
  }

  // Load existing expense
  void loadExpense(ExpenseDetails expense) {
    _state = ExpenseFormState.fromExpense(expense, _categories);
    _initializeFromState();
    notifyListeners();
  }

  @override
  void dispose() {
    nameController.removeListener(_onNameChanged);
    amountController.removeListener(_onAmountChanged);
    noteController.removeListener(_onNoteChanged);
    amountFocus.removeListener(_onAmountFocusChanged);

    nameController.dispose();
    amountController.dispose();
    noteController.dispose();

    nameFocus.dispose();
    amountFocus.dispose();
    locationFocus.dispose();
    noteFocus.dispose();

    super.dispose();
  }
}
