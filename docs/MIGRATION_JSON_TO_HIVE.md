# Migration Guide: JSON to Hive Storage

## Overview

This guide explains how to migrate your Caravella data from JSON file storage to Hive storage.

## Important Notes

⚠️ **Data is not automatically migrated between storage backends.** You must manually export and re-import your data when switching backends.

## Migration Steps

### Option 1: Using Export/Import Feature (Recommended)

If the app has an export/import feature:

1. **Before Switching:**
   - Open the app with the current storage backend (JSON)
   - Export all your trips/groups using the app's export feature
   - Save the exported file(s) to a safe location

2. **Switch Backend:**
   - Build and install the app with `STORAGE_BACKEND=hive`
   
3. **After Switching:**
   - Open the app with the new backend
   - Use the import feature to restore your data

### Option 2: Manual File Copy (For Developers)

If you need to preserve the exact data structure:

1. **Locate JSON File:**
   - Android: `data/data/io.caravella.egm/app_flutter/expense_group_storage.json`
   - iOS: `Library/Application Support/expense_group_storage.json`

2. **Keep Backup:**
   ```bash
   # Using adb for Android
   adb pull /data/data/io.caravella.egm/app_flutter/expense_group_storage.json backup.json
   ```

3. **Programmatic Migration:**
   You can create a one-time migration script in your app:

   ```dart
   import 'dart:io';
   import 'dart:convert';
   import 'package:path_provider/path_provider.dart';
   import 'package:io_caravella_egm/data/model/expense_group.dart';
   import 'package:io_caravella_egm/data/hive_expense_group_repository.dart';
   import 'package:io_caravella_egm/data/services/hive_initialization_service.dart';

   Future<void> migrateJsonToHive() async {
     // Initialize Hive
     await HiveInitializationService.initialize();
     
     // Read JSON file
     final dir = await getApplicationDocumentsDirectory();
     final jsonFile = File('${dir.path}/expense_group_storage.json');
     
     if (!await jsonFile.exists()) {
       print('No JSON file to migrate');
       return;
     }
     
     // Parse JSON
     final contents = await jsonFile.readAsString();
     final List<dynamic> jsonData = json.decode(contents);
     final groups = jsonData.map((j) => ExpenseGroup.fromJson(j)).toList();
     
     // Save to Hive
     final hiveRepo = HiveExpenseGroupRepository();
     for (final group in groups) {
       await hiveRepo.saveGroup(group);
       print('Migrated group: ${group.title}');
     }
     
     await hiveRepo.close();
     print('Migration complete! Migrated ${groups.length} groups.');
   }
   ```

## Testing the Migration

After migration:

1. Open the app with the new backend
2. Verify all your trips/groups are present
3. Check that all expenses, participants, and categories are intact
4. Test creating new trips/expenses
5. Test updating existing data

## Rollback

If you need to rollback to JSON storage:

1. Rebuild the app with `STORAGE_BACKEND=file` (or omit the parameter)
2. Reinstall the app
3. Your original JSON data should still be present if you didn't delete it

## Performance Expectations

After migrating to Hive, you should notice:

- **Faster app startup** (especially with many trips)
- **Quicker trip loading** when browsing
- **Smoother scrolling** in lists with many items
- **Faster search and filtering** operations

The improvement is more noticeable with:
- 10+ trips
- Trips with 50+ expenses
- Frequent data access patterns

## Troubleshooting

### Data Missing After Migration

**Issue:** The app shows no data after switching to Hive.

**Solution:**
1. The backends don't share data. This is expected.
2. Follow the migration steps above to transfer your data.
3. Check that you built with `STORAGE_BACKEND=hive`.

### Migration Script Fails

**Issue:** The programmatic migration throws errors.

**Solution:**
1. Ensure Hive is properly initialized before migration.
2. Check that all type adapters are registered.
3. Verify the JSON file is not corrupted.
4. Run the migration in a try-catch and log errors.

### App Crashes After Migration

**Issue:** App crashes when opening with Hive backend.

**Solution:**
1. Check that `STORAGE_BACKEND=hive` was passed during build.
2. Verify `HiveInitializationService.initialize()` is called in `AppInitialization`.
3. Check device storage permissions.
4. Look at logs for specific Hive errors.

## Storage Locations

### JSON Storage
- **Android:** `{AppDocumentsDir}/expense_group_storage.json`
- **iOS:** `{AppDocumentsDir}/expense_group_storage.json`
- **Format:** Human-readable JSON text file

### Hive Storage
- **Android:** `{HiveDir}/expense_groups.hive`
- **iOS:** `{HiveDir}/expense_groups.hive`
- **Format:** Binary format (not human-readable)

## Cleanup Old Data

After confirming the migration was successful, you can optionally delete the old JSON file:

```dart
final dir = await getApplicationDocumentsDirectory();
final jsonFile = File('${dir.path}/expense_group_storage.json');
if (await jsonFile.exists()) {
  await jsonFile.delete();
}
```

## Support

If you encounter issues during migration:
1. Check the logs for detailed error messages
2. Verify your data is backed up before switching
3. Report issues at: https://github.com/calca/caravella/issues

## Future Considerations

- Consider implementing automatic migration in a future release
- Add a "Storage Health Check" feature to verify data integrity
- Provide in-app storage backend selection (with migration prompt)
