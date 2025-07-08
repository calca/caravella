import '../../../data/expense_details.dart';

class ExpenseActionResult {
  final ExpenseDetails? updatedExpense;
  final bool deleted;
  ExpenseActionResult({this.updatedExpense, this.deleted = false});
}
