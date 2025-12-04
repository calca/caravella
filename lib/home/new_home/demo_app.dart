import 'package:flutter/material.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'new_home_page.dart';

/// Demo app for testing the new home page independently.
/// 
/// To run this demo:
/// flutter run lib/home/new_home/demo_app.dart
void main() {
  runApp(const NewHomePageDemoApp());
}

class NewHomePageDemoApp extends StatelessWidget {
  const NewHomePageDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'New Home Page Demo',
      debugShowCheckedModeBanner: false,
      theme: CaravellaThemes.light,
      darkTheme: CaravellaThemes.dark,
      themeMode: ThemeMode.light,
      home: const NewHomePage(),
    );
  }
}
