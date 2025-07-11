import 'package:flutter/material.dart';
import 'tabs/current_settings_tab.dart';
import 'tabs/info_tab.dart';
import '../widgets/caravella_app_bar.dart';
import '../app_localizations.dart';
import '../state/locale_notifier.dart';

class SettingsPage extends StatelessWidget {
  final void Function(String)? onLocaleChanged;
  const SettingsPage({super.key, this.onLocaleChanged});

  @override
  Widget build(BuildContext context) {
    final locale = LocaleNotifier.of(context)?.locale ?? 'it';
    final loc = AppLocalizations(locale);

    return Scaffold(
      appBar: const CaravellaAppBar(),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              tabs: [
                Tab(text: loc.get('settings_tab')),
                Tab(text: loc.get('info_tab')),
              ],
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withAlpha((0.6 * 255).toInt()),
              indicatorColor: Theme.of(context).colorScheme.primary,
            ),
            Expanded(
              child: TabBarView(
                children: [
                  CurrentSettingsTab(onLocaleChanged: onLocaleChanged),
                  const InfoTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
