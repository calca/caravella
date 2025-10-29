# Services Directory

This directory contains all core services organized by category for better maintainability.

## Directory Structure

### 📝 `logging/`
**Purpose**: Logging and debugging services

- `logger_service.dart` - Centralized logging service with different log levels (debug, info, warning, error)

**When to use**: Replace `print()` statements with structured logging throughout the app.

---

### 🔗 `shortcuts/`
**Purpose**: Android app shortcuts (Quick Actions) management

- `app_shortcuts_service.dart` - Core service for managing Android shortcuts via MethodChannel
- `platform_shortcuts_manager.dart` - Platform-aware wrapper that delegates to the appropriate service
- `shortcuts_navigation_service.dart` - Navigation service for deep linking from shortcuts with callback pattern

**When to use**: Update shortcuts when expense groups change, handle shortcut taps for deep linking.

---

### 💾 `storage/`
**Purpose**: Data persistence and preferences management

- `preferences_service.dart` - SharedPreferences wrapper with typed access for locale, theme, security settings, user preferences, etc.

**When to use**: Save and retrieve user settings, app state, and simple key-value data.

---

### 👤 `user/`
**Purpose**: User feedback and interaction services

- `rating_service.dart` - In-app store rating request management with smart throttling (shows after 10th expense, then monthly)

**When to use**: Prompt users for app ratings at appropriate moments without being intrusive.

---

## Usage

All services are exported through the main barrel file:

```dart
import 'package:caravella_core/caravella_core.dart';

// Logging
LoggerService.info('User action completed');
LoggerService.warning('Unusual condition', name: 'MyFeature');

// Preferences
await PreferencesService.setLocale('it');
final theme = await PreferencesService.getThemeMode();

// Shortcuts (typically called from app layer)
await PlatformShortcutsManager.updateShortcuts();

// Rating
await RatingService.checkAndPromptForRating();
```

## Adding New Services

When adding a new service:

1. **Choose the appropriate category** or create a new one if needed
2. **Place the service in the correct subdirectory**
3. **Update `caravella_core.dart`** to export the new service
4. **Add documentation** to this README

### Example: Adding a new analytics service

```bash
# Create the file
touch packages/caravella_core/lib/services/analytics/analytics_service.dart

# Update exports in caravella_core.dart
export 'services/analytics/analytics_service.dart';

# Update this README with the new category
```

## Service Categories

| Category | Purpose | Examples |
|----------|---------|----------|
| `logging/` | Debugging and monitoring | Logger |
| `shortcuts/` | Platform shortcuts | Android Quick Actions |
| `storage/` | Data persistence | SharedPreferences wrapper |
| `user/` | User interaction | In-app reviews, feedback |

---

**Maintainer Notes**:
- Keep services focused on a single responsibility
- Use dependency injection where possible
- Document all public APIs
- Write unit tests for each service
