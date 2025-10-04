/// Example integration of multi-device sync into main.dart
/// 
/// This file demonstrates how to initialize the sync system in your app.
/// Copy the relevant sections to your main.dart file.

import 'package:flutter/material.dart';
import 'sync/sync_initializer.dart';
import 'sync/models/supabase_config.dart';
import 'data/services/logger_service.dart';

/// Example main function with sync initialization
void mainWithSync() {
  WidgetsFlutterBinding.ensureInitialized();

  // ... your existing initialization code ...

  // Initialize multi-device sync (optional)
  // This should be called after WidgetsFlutterBinding.ensureInitialized()
  // but before runApp()
  _initializeSync().then((_) {
    runApp(const YourApp());
  });
}

/// Initialize sync system
/// This will attempt to read Supabase credentials from environment variables
/// If not found, sync will be disabled and the app will work normally
Future<void> _initializeSync() async {
  try {
    // Option 1: Use environment variables (recommended)
    // Build with: flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
    await SyncInitializer.initialize();

    // Option 2: Provide explicit configuration
    // final config = SupabaseConfig(
    //   url: 'https://your-project.supabase.co',
    //   anonKey: 'your-anon-key',
    // );
    // await SyncInitializer.initialize(config: config);

    if (SyncInitializer.isInitialized) {
      LoggerService.info('Multi-device sync is available');
    } else {
      LoggerService.info('Multi-device sync is disabled (no configuration)');
    }
  } catch (e) {
    LoggerService.error('Failed to initialize sync: $e');
    // App continues to work without sync
  }
}

/// Example app widget
class YourApp extends StatelessWidget {
  const YourApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Caravella',
      // ... rest of your app configuration
      home: const HomePage(),
    );
  }
}

/// Example home page with sync features
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Groups'),
        actions: [
          // Add a button to scan QR codes for joining groups
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () {
              // Navigate to QR scanner page
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (ctx) => const GroupJoinQrPage(),
              //   ),
              // );
            },
          ),
        ],
      ),
      // ... rest of your home page
    );
  }
}

/// Example of how to add QR sharing to a group detail page
/// Add this to your existing ExpenseGroupDetailPage or similar
void showQrShareOption(BuildContext context, String groupId) {
  // This is already integrated in the OptionsSheet
  // Just ensure onShareQr callback is provided when creating OptionsSheet
  
  // Example:
  // showModalBottomSheet(
  //   context: context,
  //   builder: (ctx) => OptionsSheet(
  //     trip: group,
  //     onShareQr: () {
  //       Navigator.of(ctx).pop();
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (ctx) => GroupShareQrPage(group: group),
  //         ),
  //       );
  //     },
  //     // ... other callbacks
  //   ),
  // );
}

/// Example of listening to sync events
/// Add this to a group detail page or similar
void listenToSyncEvents(String groupId) {
  // final syncCoordinator = GroupSyncCoordinator();
  // final subscription = syncCoordinator.syncEvents.listen((event) {
  //   if (event.groupId == groupId) {
  //     switch (event.type) {
  //       case SyncEventType.expenseAdded:
  //         // Refresh group data
  //         _refreshGroup();
  //         break;
  //       case SyncEventType.expenseUpdated:
  //         // Refresh group data
  //         _refreshGroup();
  //         break;
  //       case SyncEventType.expenseDeleted:
  //         // Refresh group data
  //         _refreshGroup();
  //         break;
  //       // Handle other event types...
  //     }
  //   }
  // });
  // 
  // // Don't forget to cancel subscription when widget is disposed
  // // subscription.cancel();
}

/// Notes on integration:
/// 
/// 1. The sync system is OPTIONAL - if Supabase credentials are not provided,
///    the app works normally with local-only storage.
/// 
/// 2. Permissions are already added to AndroidManifest.xml and Info.plist,
///    no additional permission handling needed.
/// 
/// 3. The OptionsSheet in ExpenseGroupDetailPage already has the QR share
///    button integrated - just ensure the callback is provided.
/// 
/// 4. For testing, you can use environment variables:
///    flutter run --dart-define=SUPABASE_URL=https://xxx.supabase.co \
///                --dart-define=SUPABASE_ANON_KEY=xxx
/// 
/// 5. Security: All data is end-to-end encrypted. The server never sees
///    unencrypted data or encryption keys.
