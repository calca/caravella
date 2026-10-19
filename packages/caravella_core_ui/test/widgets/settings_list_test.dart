import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('settings page: profile card, groups and tiles', (tester) async {
    var opened = 0, edited = 0;
    bool? toggled;
    await tester.pumpWidget(
      MaterialApp(
        home: SettingsScaffold(
          eyebrow: 'Caravella',
          title: 'Settings',
          children: [
            SettingsProfileCard(
              leading: const CircleAvatar(child: Text('A')),
              title: 'Anna',
              subtitle: 'Your name',
              actionLabel: 'Edit',
              onTap: () => edited++,
            ),
            SettingsGroup(
              label: 'Data',
              children: [
                SettingsTile(
                  icon: Icons.sync_rounded,
                  title: 'Sync',
                  subtitle: 'Between devices',
                  onTap: () => opened++,
                ),
                SettingsTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Protect screen',
                  switchValue: false,
                  onSwitch: (v) => toggled = v,
                ),
                SettingsTile(
                  icon: Icons.delete_outline,
                  title: 'Delete',
                  destructive: true,
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('DATA'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right_rounded), findsNWidgets(2));

    await tester.tap(find.text('Anna'));
    await tester.tap(find.text('Sync'));
    await tester.tap(find.text('Protect screen'));
    expect(edited, 1);
    expect(opened, 1);
    expect(toggled, isTrue);

    expect(
      tester.getSemantics(find.bySemanticsLabel(RegExp('Protect screen'))),
      isSemantics(hasToggledState: true, isToggled: false, hasTapAction: true),
    );
    expect(find.bySemanticsLabel('Anna, Your name, Edit'), findsOneWidget);
  });
}
