# Multi-Device Sync Setup Guide

This guide explains how to set up and use multi-device synchronization for Caravella expense groups.

## Prerequisites

1. **Supabase Project**: You need a Supabase project set up
2. **Multiple Devices**: At least two devices (physical or emulators) to test sync

## Supabase Setup

### 1. Create a Supabase Project

1. Go to [https://supabase.com](https://supabase.com)
2. Create a new project
3. Note your project URL and anon key

### 2. Enable Realtime

In your Supabase dashboard:
1. Go to **Database** > **Replication**
2. Enable replication for the tables you want to sync (optional - we use broadcast instead)
3. Go to **Project Settings** > **API**
4. Copy your project URL and anon key

### 3. Configure the App

There are two ways to configure Supabase credentials:

#### Option A: Environment Variables (Recommended for Development)

Build the app with environment variables:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

#### Option B: Code Configuration (For Testing)

Create a config file:

```dart
// lib/config/supabase_config_dev.dart
const supabaseUrl = 'https://your-project.supabase.co';
const supabaseAnonKey = 'your-anon-key';
```

**⚠️ DO NOT commit this file to version control!**

Add to `.gitignore`:
```
lib/config/supabase_config_dev.dart
```

## Using Multi-Device Sync

### Step 1: Share a Group (Device A)

1. Open an expense group
2. Tap the **Options** button (three dots)
3. Select **Share via QR**
4. Tap **Generate QR Code**
5. A QR code will be displayed with a 5-minute expiration timer

### Step 2: Join a Group (Device B)

1. Open Caravella on your second device
2. Tap the **Scan QR** button on the home screen (or in settings)
3. Point your camera at the QR code on Device A
4. The app will process the QR code and decrypt the group key
5. You'll be automatically added to the group

### Step 3: Enable Sync

After joining:
1. Both devices are now synced to the same group
2. Any changes made on either device will automatically sync to the other
3. Look for the sync status indicator (cloud icon) to see sync state

## How It Works

### Security Model

1. **End-to-End Encryption**: Each group has a unique 256-bit AES encryption key
2. **Secure Key Exchange**: QR codes use ECDH key exchange to securely share the group key
3. **Zero-Knowledge Server**: The Supabase server never sees unencrypted data
4. **Secure Storage**: Encryption keys are stored in platform secure storage (Keychain/KeyStore)

### Sync Process

1. **Local Changes**: When you add/edit/delete an expense:
   - The change is saved locally
   - The data is encrypted with the group key
   - An encrypted sync event is broadcast to the Supabase channel

2. **Remote Changes**: When another device makes a change:
   - Your device receives the encrypted sync event
   - The data is decrypted using the group key
   - The change is applied to your local storage
   - The UI updates automatically

### Conflict Resolution

- **Last Write Wins**: If two devices modify the same data simultaneously, the last change wins
- **Sequence Numbers**: Each event has a sequence number to prevent duplicates
- **Timestamp-Based**: Changes are ordered by timestamp

## Monitoring Sync Status

### Sync Status Indicators

The app shows sync status with a cloud icon:

- 🟢 **Green Cloud**: Successfully synced
- 🟡 **Yellow Cloud**: Syncing in progress
- 🔴 **Red Cloud**: Sync error
- ⚫ **Gray Cloud**: Sync disabled

### Viewing Sync Details

To see detailed sync information:
1. Go to **Settings** > **Advanced** > **Sync Status**
2. View active channels, sync events, and error logs

## Troubleshooting

### QR Code Won't Scan

**Problem**: QR scanner shows error or doesn't detect code

**Solutions**:
- Ensure camera permission is granted
- Check lighting - QR codes need good contrast
- Try adjusting distance to QR code (15-30cm optimal)
- Verify QR code hasn't expired (5-minute timeout)

### Sync Not Working

**Problem**: Changes on one device don't appear on another

**Solutions**:
1. Check internet connection on both devices
2. Verify Supabase credentials are correct
3. Ensure both devices have joined the same group
4. Check sync status indicator for errors
5. Try disabling and re-enabling sync

### Decryption Errors

**Problem**: "Failed to decrypt" or similar errors

**Solutions**:
1. Rescan the QR code (it may have expired)
2. Ensure both devices scanned from the same QR code generation
3. Check that the group hasn't been re-encrypted
4. As last resort, delete the group and rejoin

### Performance Issues

**Problem**: Sync is slow or using too much battery

**Solutions**:
1. Reduce sync frequency in settings (if available)
2. Close unused groups (unsubscribe from channels)
3. Check network quality - poor connections cause retries
4. Update to the latest app version

## Best Practices

### Security

1. **Only Share with Your Devices**: Only scan QR codes on devices you own
2. **Screen Security**: Use flag_secure when displaying QR codes in public
3. **Revoke Access**: Remove old devices from sync (future feature)
4. **Keep Updated**: Always use the latest app version for security patches

### Performance

1. **Active Groups**: Only keep active groups synced
2. **Archive Old Groups**: Archive inactive groups to reduce sync overhead
3. **Network Usage**: Sync works best on WiFi
4. **Battery Optimization**: Disable sync when battery is low

### Data Management

1. **Backup Regularly**: Export groups as backup even with sync enabled
2. **Test Sync**: Test with small changes first
3. **Monitor Storage**: Encrypted data takes slightly more space
4. **Clean Up**: Delete test groups to keep storage clean

## Advanced Topics

### Custom QR Expiration

To generate a QR code with custom expiration:

```dart
final qrService = QrGenerationService();
final payload = await qrService.generateQrPayload(
  groupId,
  expirationSeconds: 600, // 10 minutes instead of 5
);
```

### Manual Sync Trigger

To manually trigger a sync:

```dart
final syncCoordinator = GroupSyncCoordinator();
await syncCoordinator.syncGroupMetadataUpdated(groupId, group);
```

### Listening to Sync Events

To react to sync events in your UI:

```dart
final syncCoordinator = GroupSyncCoordinator();
syncCoordinator.syncEvents.listen((event) {
  print('Sync event: ${event.type} for group ${event.groupId}');
  // Update UI, show notification, etc.
});
```

## FAQs

**Q: Is my data safe?**
A: Yes! All data is end-to-end encrypted. The server only sees encrypted data and never has access to your encryption keys.

**Q: Can I sync across iOS and Android?**
A: Yes! The sync protocol is platform-independent.

**Q: How many devices can I sync?**
A: There's no hard limit, but for best performance, we recommend 5 or fewer devices per group.

**Q: What happens if I lose my device?**
A: Data is stored locally on each device. If you lose a device, your data is safe on other synced devices. Future versions will include device management.

**Q: Does sync work offline?**
A: No, sync requires an internet connection. Changes made offline will sync when you're back online.

**Q: Can I disable sync for a group?**
A: Yes, go to group options and disable sync. The group will remain local-only.

**Q: What's the cost of Supabase?**
A: Supabase has a generous free tier. Most personal use cases will stay within the free tier limits.

## Support

For issues or questions:
1. Check the [GitHub Issues](https://github.com/calca/caravella/issues)
2. Read the [Sync Module README](../lib/sync/README.md)
3. Contact support through the app settings

## Privacy & Data Policy

- All data is encrypted end-to-end
- Supabase server never sees unencrypted data
- Encryption keys are stored in platform secure storage
- No telemetry or analytics on sync operations
- You control which devices have access to your data

## Next Steps

1. ✅ Set up Supabase project
2. ✅ Configure app with credentials
3. ✅ Test QR code generation and scanning
4. ✅ Verify sync works between devices
5. ⬜ Enable sync for production groups
6. ⬜ Set up device management (coming soon)
7. ⬜ Configure backup strategy
