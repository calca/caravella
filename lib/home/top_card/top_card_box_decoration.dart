import 'package:flutter/material.dart';

class TopCardBoxDecoration extends StatelessWidget {
  final Widget child;
  final double opacity;
  const TopCardBoxDecoration({super.key, required this.child, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.45,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.0),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 32,
            spreadRadius: 4,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}
