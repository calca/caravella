import 'package:flutter/material.dart';

class SectionFlat extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SectionFlat({super.key, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty) ...[
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
          ],
          ...children,
        ],
      ),
    );
  }
}
