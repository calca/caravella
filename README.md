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

## 🎉 What's New in v1.2.0

- **Interactive Maps**: Visualize your expenses on OpenStreetMap with location search and automatic GPS capture
- **Dynamic App Colors**: Material 3 theming adapts to your device wallpaper for a personalized experience
- **Smart Quick Actions**: Launch your favorite expense groups directly from your Android home screen
- **Enhanced Loading**: Beautiful skeleton animations make the app feel smoother and more responsive
- **Automatic Updates**: Stay up-to-date with weekly update checks and one-tap installations

## 🛠️ Tech Stack & Architecture

- **Framework**: Flutter 3.x with Material 3
- **UI**: Material Design 3 with dynamic color support
- **State Management**: `provider` for centralized and reactive state management
- **Storage**: Local file storage using `path_provider` for private, on-device data persistence
- **Maps**: OpenStreetMap integration via `flutter_map` with Nominatim geocoding
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

## 📦 Download & Installation

### Android
- **GitHub Releases**: [Download APK](https://github.com/calca/caravella/releases)
- **Google Play Store**: Coming soon
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
