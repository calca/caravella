import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../data/model/expense_category.dart';
import '../../../data/model/expense_details.dart';
import '../../../data/model/expense_participant.dart';
import '../../../data/model/expense_location.dart';

/// Centralized state management for ExpenseFormComponent
class ExpenseFormState extends ChangeNotifier {
  // Form data
  ExpenseCategory? _category;
  double? _amount;
  ExpenseParticipant? _paidBy;
  DateTime? _date;
  ExpenseLocation? _location;
  
  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  
  // Focus nodes
  final FocusNode nameFocus = FocusNode();
  final FocusNode amountFocus = FocusNode();
  final FocusNode locationFocus = FocusNode();
  final FocusNode noteFocus = FocusNode();
  
  // Form state tracking
  bool _isDirty = false;
  bool _initializing = true;
  late List<ExpenseCategory> _categories;
  
  // Validation state
  bool _amountTouched = false;
  bool _paidByTouched = false;
  bool _categoryTouched = false;
  
  // UI state
  bool _isExpanded = false;
  
  // Getters
  ExpenseCategory? get category => _category;
  double? get amount => _amount;
  ExpenseParticipant? get paidBy => _paidBy;
  DateTime? get date => _date;
  ExpenseLocation? get location => _location;
  List<ExpenseCategory> get categories => _categories;
  bool get isDirty => _isDirty;
  bool get initializing => _initializing;
  bool get isExpanded => _isExpanded;
  
  // Validation getters
  bool get amountTouched => _amountTouched;
  bool get paidByTouched => _paidByTouched;
  bool get categoryTouched => _categoryTouched;
  bool get isAmountValid => _amount != null && _amount! > 0;
  bool get isPaidByValid => _paidBy != null;
  bool get isCategoryValid => _categories.isEmpty || _category != null;
  
  // Constructor
  ExpenseFormState({
    ExpenseDetails? initialExpense,
    required List<ExpenseCategory> categories,
    required List<ExpenseParticipant> participants,
  }) {
    _categories = List.from(categories);
    _initializeFromExpense(initialExpense, participants);
  }
  
  void _initializeFromExpense(ExpenseDetails? expense, List<ExpenseParticipant> participants) {
    if (expense != null) {
      nameController.text = expense.name;
      amountController.text = expense.amount.toString();
      noteController.text = expense.note ?? '';
      _amount = expense.amount;
      _date = expense.date;
      _location = expense.location;
      
      // Find matching category
      if (_categories.isNotEmpty) {
        _category = _categories.firstWhere(
          (c) => c.id == expense.category.id,
          orElse: () => _categories.first,
        );
      }
      
      // Find matching participant
      _paidBy = participants.firstWhere(
        (p) => p.id == expense.paidBy.id,
        orElse: () => participants.isNotEmpty ? participants.first : ExpenseParticipant(name: ''),
      );
      
      _isDirty = false;
    } else {
      // Initialize with defaults
      _paidBy = participants.isNotEmpty ? participants.first : null;
      _category = _categories.isNotEmpty ? _categories.first : null;
    }
    
    _initializing = false;
  }
  
  // Setters with dirty tracking
  void setCategory(ExpenseCategory? category) {
    if (_category == category) return;
    _category = category;
    _categoryTouched = true;
    if (!_initializing) _isDirty = true;
    notifyListeners();
  }
  
  void setAmount(double? amount) {
    if (_amount == amount) return;
    _amount = amount;
    _amountTouched = true;
    if (!_initializing) _isDirty = true;
    notifyListeners();
  }
  
  void setPaidBy(ExpenseParticipant? paidBy) {
    if (_paidBy == paidBy) return;
    _paidBy = paidBy;
    _paidByTouched = true;
    if (!_initializing) _isDirty = true;
    notifyListeners();
  }
  
  void setDate(DateTime? date) {
    if (_date == date) return;
    _date = date;
    if (!_initializing) _isDirty = true;
    notifyListeners();
  }
  
  void setLocation(ExpenseLocation? location) {
    if (_location == location) return;
    _location = location;
    if (!_initializing) _isDirty = true;
    notifyListeners();
  }
  
  void setExpanded(bool expanded) {
    if (_isExpanded == expanded) return;
    _isExpanded = expanded;
    if (!_initializing) _isDirty = true;
    notifyListeners();
  }
  
  void updateCategories(List<ExpenseCategory> newCategories) {
    _categories = List.from(newCategories);
    notifyListeners();
  }
  
  void addCategory(ExpenseCategory category) {
    _categories.add(category);
    notifyListeners();
  }
  
  void markDirty() {
    if (!_initializing) {
      _isDirty = true;
      notifyListeners();
    }
  }
  
  void clearDirty() {
    _isDirty = false;
    notifyListeners();
  }
  
  bool isFormValid() {
    final nameValue = nameController.text.trim();
    return nameValue.isNotEmpty && isAmountValid && isPaidByValid && isCategoryValid;
  }
  
  @override
  void dispose() {
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