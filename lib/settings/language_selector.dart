import 'package:flutter/material.dart';

class LanguageSelector extends StatelessWidget {
  final String locale;
  final ValueChanged<String> onChanged;
  const LanguageSelector({super.key, required this.locale, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 32,
      right: 24,
      child: DropdownButton<String>(
        value: locale,
        underline: const SizedBox(),
        dropdownColor: Colors.white,
        style: const TextStyle(color: Colors.black),
        items: const [
          DropdownMenuItem(value: 'en', child: Text('EN', style: TextStyle(color: Colors.black))),
          DropdownMenuItem(value: 'it', child: Text('ITA', style: TextStyle(color: Colors.black))),
        ],
        onChanged: (value) {
          if (value != null) {
            onChanged(value);
          }
        },
      ),
    );
  }
}
