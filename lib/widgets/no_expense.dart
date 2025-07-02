import 'package:flutter/material.dart';

class NoExpense extends StatelessWidget {
  final String semanticLabel;
  const NoExpense({super.key, required this.semanticLabel});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.2,
      child: ColorFiltered(
        colorFilter: ColorFilter.matrix(<double>[
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]),
        child: Image.asset(
          'assets/images/no_expense.png',
          width: 180,
          height: 180,
          fit: BoxFit.contain,
          semanticLabel: semanticLabel,
        ),
      ),
    );
  }
}
