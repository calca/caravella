# Migration Guide: JSON to Hive Storage

## Overview

This guide explains how to migrate your Caravella data from JSON file storage to Hive storage.

## ✨ Automatic Migration (Recommended)

**As of the latest version, migration from JSON to Hive is automatic!**

When you build and run the app with `STORAGE_BACKEND=hive`:

1. **On first launch**, the app automatically detects if a JSON file exists
2. **Migrates all data** from JSON to Hive seamlessly
3. **Deletes the old JSON file** after successful migration
4. **Creates a marker file** to prevent duplicate migrations

### What Happens During Automatic Migration:

✅ All expense groups are migrated  
✅ All participants, categories, and expenses are preserved  
✅ Pinned and archived states are maintained  
✅ Original JSON file is deleted only after successful migration  
✅ Migration happens once per installation  
✅ Safe: keeps JSON file as backup if any errors occur

### Building with Automatic Migration:

```bash
# Build with Hive backend - migration happens automatically on first launch
flutter build apk --flavor prod --release --dart-define=FLAVOR=prod --dart-define=STORAGE_BACKEND=hive
```

That's it! No manual steps needed.

## Manual Migration (Legacy Options)

For advanced users or special cases, manual migration is still possible:

### Option 1: Using Export/Import Feature

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

### Option 2: Manual File Copy (For Developers/Advanced Users)

If you need to preserve the exact data structure or want manual control:

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

### Automatic Migration

After building with `STORAGE_BACKEND=hive`:

1. **First launch**: Check logs to see migration progress
2. **Verify data**: All your trips/groups should be present
3. **Check integrity**: All expenses, participants, and categories are intact
4. **Test operations**: Create/update/delete work as expected
5. **Confirm cleanup**: Old JSON file should be gone

### Manual Migration

After manual migration:

1. Open the app with the new backend
2. Verify all your trips/groups are present
3. Check that all expenses, participants, and categories are intact
4. Test creating new trips/expenses
5. Test updating existing data

## Rollback

### From Automatic Migration

If you need to rollback after automatic migration:

⚠️ **Important**: The JSON file is deleted after successful automatic migration. You'll need to:

1. Export your data using the app's export feature (if available)
2. Rebuild with `STORAGE_BACKEND=file` (or omit the parameter)
3. Reinstall the app
4. Import your data back

### From Manual Migration

If you kept a backup of the JSON file:

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

### Automatic Migration Issues

#### Migration Didn't Run

**Issue:** App still shows no data after building with Hive.

**Solution:**
1. Check build command includes `--dart-define=STORAGE_BACKEND=hive`
2. Verify JSON file exists before first launch with Hive
3. Check app logs for migration messages
4. Ensure Hive initialization completed successfully

#### Migration Failed with Errors

**Issue:** Migration started but encountered errors.

**Solution:**
1. Check logs for specific error messages
2. JSON file is kept as backup when errors occur
3. Fix the underlying issue (permissions, corrupted data, etc.)
4. Reset migration: delete `.hive_migration_done` marker file
5. Restart app to retry migration

#### Data Missing After Migration

**Issue:** The app shows no data after migration.

**Solution:**
1. With automatic migration, this shouldn't happen
2. Check migration logs for errors
3. Verify `.hive_migration_done` marker exists
4. Check that Hive database was created successfully
5. If JSON file is still present, migration had errors - check logs

### Manual Migration Issues

#### Data Missing After Manual Migration

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
