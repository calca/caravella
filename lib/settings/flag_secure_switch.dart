import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'flag_secure_notifier.dart';
import 'flag_secure_android.dart';

class FlagSecureSwitch extends StatelessWidget {
  const FlagSecureSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FlagSecureNotifier>(
      builder: (context, notifier, _) {
        return SwitchListTile.adaptive(
          title: const Text('Proteggi schermata (FLAG_SECURE)'),
          subtitle: const Text('Impedisce screenshot e registrazione schermo'),
          value: notifier.enabled,
          onChanged: (val) async {
            await notifier.setEnabled(val);
            await FlagSecureAndroid.setFlagSecure(val);
          },
        );
      },
    );
  }
}
