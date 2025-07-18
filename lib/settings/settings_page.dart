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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: const CaravellaAppBar(),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TabBar(
                  tabs: [
                    Tab(text: loc.get('settings_tab')),
                    Tab(text: loc.get('info_tab')),
                  ],
                  labelColor: colorScheme.onSurface,
                  unselectedLabelColor: colorScheme.onSurface.withOpacity(0.2),
                  indicator: BoxDecoration(
                    color: colorScheme.primaryFixedDim.withOpacity(0.30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelStyle: textTheme.labelLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                  unselectedLabelStyle: textTheme.labelLarge,
                  overlayColor: MaterialStateProperty.all(
                      colorScheme.primaryFixed.withOpacity(0.08)),
                  dividerColor: Colors.transparent,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.shadow.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TabBarView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      CurrentSettingsTab(onLocaleChanged: onLocaleChanged),
                      const InfoTab(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
