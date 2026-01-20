# Caravella: an Expense Tracker

<p align="center">
  <img src="store/assets/caravella-icon-store.png" alt="Caravella Icon" width="150"/>
</p>

<p align="center">
  <strong>Modern group expense management for trips, shared costs, and participants</strong>
</p>

**Caravella** is a modern, multi-platform Flutter application designed to simplify expense management for groups, trips, and events. Built with Material 3, it offers an intuitive and clean user experience for tracking shared costs, managing participants, and settling debts.

Whether you're on a group trip, sharing an apartment with roommates, or organizing an event, Caravella helps you keep everything organized and transparent. All data is stored locally on your device, ensuring privacy and offline availability.

## ✨ Key Features

### Core Functionality
- **Group Management**: Create and manage multiple expense groups for different trips or shared living situations
- **Expense Tracking**: Add, edit, and categorize expenses with detailed participant assignments
- **Smart Calculations**: Automatic calculation of who owes what to whom
- **Participant Management**: Easy addition and management of group members
- **Data Export**: Export your data to CSV or JSON formats for external analysis
- **Backup & Restore**: Complete data backup and restore functionality

### Location & Maps
- **Interactive Maps**: Visualize all expenses with locations on an OpenStreetMap view
- **Location Search**: Find and attach locations to expenses with autocomplete suggestions
- **Auto-Location Capture**: Automatic GPS retrieval when adding new expenses (optional, can be toggled)
- **Reverse Geocoding**: Automatically resolve addresses from coordinates

### Visual & Personalization
- **Photo Attachments**: Add photos to group backgrounds and expense records
- **Theme-Aware Colors**: Expense group colors that adapt to light/dark mode
- **Dynamic Color Support**: Material 3 colors derived from device wallpaper (Android 12+)
- **Material Design 3**: Modern interface with smooth animations and transitions

### Multi-Device Sync (Optional) 🆕
- **QR Code Sharing**: Share expense groups across your devices using secure QR code-based key exchange
- **End-to-End Encryption**: AES-256-GCM encryption ensures your data is always private
- **Realtime Sync**: Changes propagate to all devices within 1-2 seconds
- **Offline Support**: Changes queue locally and sync automatically when connection restored
- **FREE Tier**: Sync 1 group with up to 2 participants at no cost
- **Account Numbers**: Simple, auto-generated identifiers (no email/password required)
- **Device Management**: View and revoke device access to your synced groups

### Updates & Convenience
- **Auto-Update Checks**: Weekly automatic update notifications (Play Store builds)
- **In-App Rating**: Smart prompts to rate the app at appropriate moments
- **Android Quick Actions**: Launch specific expense groups directly from your home screen
- **What's New Page**: View changelog and recent improvements directly in the app
- **Context Menus**: Long-press actions for quick group management (pin, archive, delete)

### Privacy & Localization
- **Privacy First**: All data stored locally on your device - no cloud sync required
- **Multi-language**: Available in English, Italian, Spanish, Portuguese, and Chinese
- **GDPR Compliant**: Full compliance with privacy regulations
- **Cross-Platform**: Built with Flutter, designed to run smoothly on Android smartphones, iOS, Web, and Desktop

### Perfect For:
- Group trips and vacations
- Shared household expenses
- Event planning and cost sharing
- Business trip expense tracking
- Roommate expense management

## 📱 Screenshots

<p align="center">
  <img src="store/screenshot/01 - Welcome - EN.png" alt="Welcome Screen" width="200"/>
  <img src="store/screenshot/02 - HomePage.png" alt="Home Page" width="200"/>
  <img src="store/screenshot/03 - HomePage - Add.png" alt="Add Group" width="200"/>
  <img src="store/screenshot/04 - Group - Expenses - Home.png" alt="Group Expenses Home" width="200"/>
</p>

<p align="center">
  <img src="store/screenshot/05 - Group - Expenses - Add.png" alt="Add Expense" width="200"/>
  <img src="store/screenshot/06 - Group - Expenses.png" alt="Group Expenses" width="200"/>
  <img src="store/screenshot/07 - Group - Partecipants.png" alt="Participants" width="200"/>
  <img src="store/screenshot/08 - Group - Stats.png" alt="Group Statistics" width="200"/>
</p>

<p align="center">
  <img src="store/screenshot/09 - Grops History.png" alt="Groups History" width="200"/>
</p>

## 🎉 What's New in v1.4.0

- **Media Attachments**: Add photos, videos, and PDFs to your expenses with full-screen viewer and share capabilities
- **Markdown Export**: Export your expense groups to markdown format with comprehensive statistics and tables
- **Smarter Forms**: Improved group editing with organized tabs and streamlined expense management
- **Better Camera Experience**: Camera now opens with rear camera by default for more natural photo-taking
- **Enhanced Stability**: Improved attachment handling, notification icons, and error feedback throughout the app

## 🛠️ Tech Stack & Architecture

- **Framework**: Flutter 3.x with Material 3
- **UI**: Material Design 3 with dynamic color support
- **State Management**: `provider` for centralized and reactive state management
- **Storage**: Local file storage using `path_provider` for private, on-device data persistence
- **Maps**: OpenStreetMap integration via `flutter_map` with Nominatim geocoding
- **Sync**: Optional multi-device sync with Supabase Realtime and end-to-end encryption (AES-256-GCM)
- **Security**: ECDH X25519 key exchange, platform secure storage (Keychain/KeyStore), QR code-based key sharing
- **Architecture**: Multi-package clean architecture with separation between:
  - `caravella_core`: Business logic, data models, and services
  - `caravella_core_ui`: Reusable UI components and themes
  - `play_store_updates`: Google Play Store update functionality (conditional)
  - Main app: Application-specific UI and features
- **Build Variants**: Factory pattern for Play Store and F-Droid distributions
- **Flavors**: Configured for different build environments (dev, staging, prod)

## 🔒 Privacy & Security

Caravella is designed with privacy as a core principle:

- **Local Storage**: All data is stored locally on your device - no cloud sync required
- **No User Accounts**: No online services or user accounts needed
- **Full Data Control**: You have complete control over your data with export and deletion capabilities
- **Optional Permissions**: Camera and location permissions are only requested when you explicitly use those features
- **GDPR Compliant**: Full compliance with privacy regulations

For complete details, see our [Privacy Policy](store/PRIVACY_POLICY.md) and [Permissions Documentation](store/permissions_documentation.md).

## 🔄 Multi-Device Sync (Optional)

Caravella supports secure multi-device synchronization for expense groups:

1.  **Setup Supabase** (one-time):
    - Create a free account at [https://supabase.com](https://supabase.com)
    - Create a new project and note your project URL and anon key
    - See [Multi-Device Sync Guide](docs/MULTI_DEVICE_SYNC_GUIDE.md) for detailed setup

2.  **Configure Credentials**:
    ```sh
    flutter run \
      --dart-define=SUPABASE_URL=your_url \
      --dart-define=SUPABASE_ANON_KEY=your_key
    ```

3.  **Share Groups via QR Code**:
    - Open a group → Options → Share via QR
    - Scan the QR code on your other device
    - Both devices will sync automatically

**Security**: All data is end-to-end encrypted using AES-256-GCM. The server never sees unencrypted data or encryption keys. See [Sync Module README](lib/sync/README.md) for security details.

## 📦 Download & Installation

### Android
- **GitHub Releases**: [Download APK](https://github.com/calca/caravella/releases)
- **Google Play Store**: https://play.google.com/store/apps/details?id=io.caravella.egm
- **F-Droid**: Coming soon (see [F-Droid Submission Guide](docs/FDROID_SUBMISSION.md) for details)
- **Device Support**: Optimized for smartphones only (tablets not supported)

### iOS
- **App Store**: Coming soon

Visit our [website](https://calca.github.io/caravella) for more information.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## 📞 Contact & Support

- **Project Repository**: https://github.com/calca/caravella
- **Issues**: https://github.com/calca/caravella/issues
- **Website**: https://calca.github.io/caravella
- **Privacy Inquiries**: privacy@caravella.app

## 📄 License

This project is licensed under the MIT License. See the `LICENSE` file for details.
