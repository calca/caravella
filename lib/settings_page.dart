import 'package:flutter/material.dart';
import 'app_localizations.dart';

class SettingsPage extends StatelessWidget {
  final AppLocalizations localizations;
  const SettingsPage({super.key, required this.localizations});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(localizations.get('settings'))),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(localizations.get('about'), style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Text('Caravella v0.0.3', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            Text('Developed by calca', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 24),
            Text(localizations.get('settings_hint') ?? '', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
