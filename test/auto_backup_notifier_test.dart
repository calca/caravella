import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core/services/backup_service.dart';

/// Android backup switch: the app's own preference (read by the native
/// backup agent) is the source of truth; the last backup time comes from
/// the platform channel.
void main() {
  const channel = MethodChannel('io.caravella.egm/backup');
  late List<MethodCall> calls;
  late int lastBackupMs;

  void mockChannel({bool fail = false}) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          if (fail) throw PlatformException(code: 'ERROR');
          switch (call.method) {
            case 'isBackupEnabled':
              return true;
            case 'triggerBackup':
              return true;
            case 'lastBackupTime':
              return lastBackupMs;
          }
          return null;
        });
  }

  Future<AutoBackupNotifier> load() async {
    final notifier = AutoBackupNotifier();
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return notifier;
  }

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    BackupService.debugForceAndroid = true;
    AutoBackupNotifier.debugIsIOS = false;
    SharedPreferences.setMockInitialValues({});
    calls = [];
    lastBackupMs = 0;
    mockChannel();
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    BackupService.debugForceAndroid = null;
    AutoBackupNotifier.debugIsIOS = null;
  });

  test('is on by default, like Android backup', () async {
    final notifier = await load();
    expect(notifier.enabled, isTrue);
  });

  test('turning it off is saved and stays off after reopening', () async {
    final notifier = await load();
    await notifier.setEnabled(false);
    expect(notifier.enabled, isFalse);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('auto_backup_enabled'), isFalse);

    // The platform still reports backup as allowed: the preference wins.
    final reopened = await load();
    expect(reopened.enabled, isFalse);
  });

  test('turning it on asks Android for a backup', () async {
    SharedPreferences.setMockInitialValues({'auto_backup_enabled': false});
    final notifier = await load();
    calls.clear();

    await notifier.setEnabled(true);

    expect(notifier.enabled, isTrue);
    expect(calls.map((c) => c.method), contains('triggerBackup'));
  });

  test('reads the last backup time', () async {
    lastBackupMs = DateTime(2026, 10, 19, 21, 30).millisecondsSinceEpoch;
    final notifier = await load();
    expect(notifier.lastBackup, DateTime(2026, 10, 19, 21, 30));
  });

  test('no backup yet means no time', () async {
    final notifier = await load();
    expect(notifier.lastBackup, isNull);
  });

  test('a failing platform call when turning on keeps the state', () async {
    SharedPreferences.setMockInitialValues({'auto_backup_enabled': false});
    final notifier = await load();
    mockChannel(fail: true);

    var notified = false;
    notifier.addListener(() => notified = true);
    await notifier.setEnabled(true);

    expect(notifier.enabled, isFalse);
    expect(notified, isTrue);
  });
}
