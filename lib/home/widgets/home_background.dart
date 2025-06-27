import 'package:flutter/material.dart';

class HomeBackground extends StatelessWidget {
  const HomeBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 700),
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: child,
      ),
      child: ColorFiltered(
        colorFilter: const ColorFilter.matrix(<double>[
          0.2126, 0.7152, 0.0722, 0, 0, // R
          0.2126, 0.7152, 0.0722, 0, 0, // G
          0.2126, 0.7152, 0.0722, 0, 0, // B
          0, 0, 0, 1, 0, // A
        ]),
        child: Opacity(
          opacity: 0.1,
          child: Image.asset(
            'assets/images/home/backgrounds/mountains.jpg',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
