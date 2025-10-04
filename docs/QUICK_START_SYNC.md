# Quick Start: Multi-Device Sync

Get started with multi-device sync in 5 minutes!

## Prerequisites

- Flutter SDK (latest stable)
- Supabase account (free tier works)
- Physical devices or emulators with camera support

## Step 1: Supabase Setup (2 minutes)

1. Go to [https://supabase.com](https://supabase.com) and sign up
2. Create a new project
3. Wait for project initialization (~30 seconds)
4. Go to **Settings** → **API**
5. Copy:
   - Project URL (e.g., `https://xxxxx.supabase.co`)
   - Anon public key (starts with `eyJ...`)

**That's it!** No tables, no schema, no configuration needed.

## Step 2: Install Dependencies (30 seconds)

Dependencies are already in `pubspec.yaml`:

```bash
flutter pub get
```

## Step 3: Build with Credentials (1 minute)

Replace `YOUR_URL` and `YOUR_KEY` with your Supabase credentials:

```bash
flutter run \
  --dart-define=SUPABASE_URL=YOUR_URL \
  --dart-define=SUPABASE_ANON_KEY=YOUR_KEY
```

## Step 4: Test It! (2 minutes)

### On Device A (Share):

1. Open the app
2. Create an expense group (or use existing)
3. Tap **⋮** (options menu)
4. Select **"Share via QR"**
5. Tap **"Generate QR Code"**
6. QR code appears with 5-minute countdown

### On Device B (Join):

1. Open the app
2. Tap **⋮** (menu)
3. Select **"Scan QR Code"** (or look for scanner icon)
4. Point camera at QR code on Device A
5. Wait for "Group joined successfully" message

### Verify Sync:

1. On Device A: Add an expense
2. On Device B: The expense appears automatically! 🎉

## Troubleshooting

### "Failed to initialize Supabase"
- Check your URL and key are correct
- Ensure you have internet connection
- Verify Supabase project is active

### QR Scanner doesn't work
- Grant camera permission
- Ensure good lighting
- Try physical device (emulator cameras may not work)

### Sync not working
- Check both devices have internet
- Verify QR code hasn't expired (5 min)
- Check Supabase dashboard for any errors

## What's Happening Behind the Scenes?

1. **QR Generation**:
   - App generates a 256-bit encryption key for the group
   - Key is encrypted using ECDH (like Signal/WhatsApp)
   - QR contains encrypted key + public key info
   - QR expires after 5 minutes

2. **QR Scanning**:
   - Device B scans and decrypts the group key
   - Key is stored in platform secure storage
   - Both devices now have the same encryption key

3. **Sync**:
   - Each device connects to Supabase Realtime channel
   - When you add/edit/delete expense:
     - Data is encrypted with the group key
     - Encrypted data sent to Supabase
     - Other devices receive and decrypt
   - Server never sees unencrypted data

## Security Notes

✅ **Safe**:
- All data is end-to-end encrypted
- Server never sees your unencrypted data
- Keys stored in Keychain (iOS) or KeyStore (Android)
- QR codes expire automatically

⚠️ **Be Careful**:
- Only scan QR codes from your own devices
- Don't share QR codes over insecure channels
- If device is stolen, data may be accessible (if unlocked)

## Development Tips

### Environment Variables in VS Code

Add to `.vscode/launch.json`:

```json
{
  "configurations": [
    {
      "name": "Dev with Sync",
      "request": "launch",
      "type": "dart",
      "args": [
        "--dart-define=SUPABASE_URL=https://xxx.supabase.co",
        "--dart-define=SUPABASE_ANON_KEY=xxx"
      ]
    }
  ]
}
```

### Testing on Emulators

**Android Emulator**:
- Works great with camera
- Can share between multiple emulators
- May need to enable camera in AVD settings

**iOS Simulator**:
- Camera not available
- Test on physical device
- Or use QR image file for testing

### Working Without Supabase

The app works perfectly without Supabase:
- Just run: `flutter run` (no dart-define)
- All features work except multi-device sync
- Perfect for testing core functionality

## Next Steps

1. ✅ **Test sync** between two devices
2. 📖 **Read docs**: [User Guide](MULTI_DEVICE_SYNC_GUIDE.md)
3. 🔧 **Customize**: Change QR expiration, add features
4. 🚀 **Deploy**: Configure for production

## Production Checklist

Before releasing to users:

- [ ] Set up production Supabase project
- [ ] Use environment-specific configs (dev/staging/prod)
- [ ] Test with physical devices
- [ ] Verify QR scanning in various lighting
- [ ] Test offline behavior
- [ ] Review security documentation
- [ ] Add usage instructions for users
- [ ] Monitor Supabase usage/costs

## Cost Estimate

**Supabase Free Tier Limits**:
- 500 MB database (not used for sync)
- 2GB bandwidth/month
- 200,000 realtime messages/month

**Typical Usage** (1 user, 5 groups, active use):
- ~1,000 messages/month
- ~10MB bandwidth/month
- **Well within free tier!**

**At Scale** (1000 users):
- Consider paid plan (~$25/month)
- Still very affordable
- Can optimize with batching

## Getting Help

- 📖 [Full Documentation](MULTI_DEVICE_SYNC_GUIDE.md)
- 🏗️ [Architecture Details](SYNC_ARCHITECTURE.md)
- 💻 [Code Examples](../lib/sync/INTEGRATION_EXAMPLE.dart)
- 🐛 [Report Issues](https://github.com/calca/caravella/issues)

## Common Questions

**Q: Do I need Supabase?**  
A: No! The app works perfectly without it. Sync is optional.

**Q: Can I use my own server?**  
A: Not yet, but the architecture supports it. Future enhancement.

**Q: Is it really end-to-end encrypted?**  
A: Yes! Server never sees unencrypted data or encryption keys.

**Q: What if I lose my phone?**  
A: Data is safe on other synced devices. No remote access possible.

**Q: Can I sync across iOS and Android?**  
A: Yes! The protocol is platform-independent.

**Q: How many devices can I use?**  
A: No hard limit, but 5 or fewer recommended for performance.

## Success Criteria

You're ready to ship when:

- ✅ QR generation works reliably
- ✅ QR scanning works in various lighting
- ✅ Sync happens within 1-2 seconds
- ✅ Works offline and recovers when online
- ✅ No crashes or errors in testing
- ✅ Users understand how to use it

---

**Happy Syncing! 🚀**

Need help? Open an issue or check the full documentation.
