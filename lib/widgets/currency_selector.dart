import 'package:flutter/material.dart';

class CurrencySelector extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;
  const CurrencySelector({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: value,
      items: const [
        DropdownMenuItem(value: '€', child: Text('Euro (€)')),
        DropdownMenuItem(value: '\$', child: Text('Dollaro (\$)')),
        DropdownMenuItem(value: '£', child: Text('Sterlina (£)')),
        DropdownMenuItem(value: 'Fr', child: Text('Franco (Fr)')),
        DropdownMenuItem(value: 'zł', child: Text('Złoty (zł)')),
        DropdownMenuItem(value: '¥', child: Text('Yen (¥)')),
      ],
      onChanged: onChanged,
    );
  }
}
