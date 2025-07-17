import 'package:flutter/material.dart';
import '../../../widgets/no_expense.dart';

class EmptyExpenses extends StatelessWidget {
  final String semanticLabel;
  const EmptyExpenses({super.key, required this.semanticLabel});

  @override
  Widget build(BuildContext context) {
    return NoExpense(semanticLabel: semanticLabel);
  }
}
