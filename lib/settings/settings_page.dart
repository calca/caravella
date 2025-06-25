import 'package:flutter/material.dart';
import 'tabs/current_settings_tab.dart';
import 'tabs/info_tab.dart';
import '../widgets/caravella_app_bar.dart';

class SettingsPage extends StatelessWidget {
  final void Function(String)? onLocaleChanged;
  const SettingsPage({super.key, this.onLocaleChanged});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CaravellaAppBar(),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'Impostazioni'),
                Tab(text: 'Info'),
              ],
              labelColor: Colors.black,
              indicatorColor: Colors.blue,
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
