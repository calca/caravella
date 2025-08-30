# Caravella - Group Expense & Travel Manager

**Caravella** is a modern, multi-platform Flutter application designed to simplify expense management for groups, trips, and events. Built with Material 3, it offers an intuitive and clean user experience for tracking shared costs, managing participants, and settling debts.

Whether you're on a group trip, sharing an apartment with roommates, or organizing an event, Caravella helps you keep everything organized and transparent. All data is stored locally on your device, ensuring privacy and offline availability.

## ✨ Key Features

- **Group Management**: Create and manage distinct groups for trips, events, or shared living arrangements. Add members and track expenses collectively.
- **Expense Tracking**: Easily add new expenses, assign categories, specify who paid, and select which members participated in the cost.
- **Material 3 UI**: A beautiful and modern user interface with support for dynamic colors and a native-feeling light/dark mode.
- **Dashboard**: A central home page that provides a quick overview of the current pinned group, total expenses, and quick access to details.
- **Detailed Summaries**: Get a clear breakdown of who owes what to whom, ensuring transparent and fair settlements.
- **Data Persistence**: All your data is saved locally on your device using file-based storage, so it's always available, even offline.
- **Backup & Restore**: Securely export all your app data to a single file and import it later, perfect for backups or migrating to a new device.
- **CSV Export**: Export the expense list for any group into a CSV file, which can be easily shared or used in other applications.
- **Multi-Language Support**: The app is localized for English, Italian, and Spanish.
- **Cross-Platform**: Built with Flutter, Caravella is designed to run smoothly on Android, iOS, Web, and Desktop from a single codebase.

## 🛠️ Tech Stack & Architecture

- **Framework**: Flutter
- **UI**: Material 3
- **State Management**: `provider` for centralized and reactive state management.
- **Storage**: Local file storage using `path_provider` for private, on-device data persistence.
- **Architecture**: The app follows a clean architecture with a separation of concerns between UI, state management, and data services.
- **Flavors**: Configured for different build environments (dev, staging, prod).

## 🚀 Getting Started

1.  **Install Dependencies**
    ```sh
    flutter pub get
    ```

2.  **Generate App Icons**
    ```sh
    flutter pub run flutter_launcher_icons:main
    ```

3.  **Run the App**
    ```sh
    flutter run
    ```

    ## Package & CI notes

    - The project's Dart package name has been updated to `io_caravella_egm` (see `pubspec.yaml`).
    - CI artifact names were updated to use the `io_caravella_egm` prefix.

## 📄 License

This project is licensed under the MIT License. See the `LICENSE` file for details.
