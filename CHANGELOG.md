# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.2.0] - 2025-12-03

### Added
- Theme-aware color palette for expense groups that adapts colors based on light/dark mode
- OpenStreetMap integration for visualizing expense locations on an interactive map
- Map view button in expense group overview to display all expenses with locations on a map
- OpenStreetMap location search for expense form with autocomplete and nearby places suggestions
- Location picker with interactive map selection and reverse geocoding to resolve addresses
- Compact location indicator in expense form showing auto-captured GPS location with visual feedback
- Auto-location toggle setting for automatic GPS retrieval when adding new expenses
- Setting to enable/disable automatic location capture with manual override option
- Dynamic color support with Material 3 integration for personalized app theming (Android 12+, limited iOS support)
- Settings toggle to enable colors derived from device wallpaper with graceful fallback to default themes
- Android Quick Actions (App Shortcuts) for quick access to expense groups from launcher (Android only)
- Dynamic icons for Android Quick Launch shortcuts with group initials and background colors or images
- F-Droid metadata and distribution support
- Comprehensive F-Droid submission documentation
- Context menu (long-press) for expense groups in history page with pin/unpin, archive/unarchive, and delete actions
- Material 3 expressive swipe behavior for history page with Gmail-style dismissible actions
- Smooth skeleton loader animation for carousel during cold start with shimmer effect
- Fade-in animation for carousel cards when data loads
- In-app store rating feature with smart triggers (after 10 expenses, then monthly)
- Period selector with interactive calendar and duration presets (3, 7, 15, 30 days)
- Long-press on participant card now opens a bottom sheet with message preview before sending
- Google Play Store automatic update checks with flexible update support (Android only)
- Weekly automatic update check that shows recommendation sheet when new version is available
- Manual update check button in "What's New" page with immediate update capability
- Build variant support for Play Store and F-Droid distributions using factory pattern

### Changed
- Dark theme map tiles now use CartoDB Dark Matter for improved visibility of points of interest
- Current location button in map search now shows loading indicator while fetching GPS position
- Expense group colors now use palette indices for consistent appearance across light and dark themes
- Restructured project into multi-package architecture with core, core-ui, and app separation for improved maintainability
- Enhanced skeleton loader with smooth scale and fade-in animations for more polished loading experience
- Improved new group creation flow with immediate skeleton display and automatic navigation to newly created group
- Improved app metadata for distribution platforms
- Replaced CircularProgressIndicator with CarouselSkeletonLoader in home cards section for better UX
- Refactored PreferencesService architecture with singleton pattern and separated preference categories
- Improved PreferencesService API with synchronous read operations where possible
- Organized preference keys and defaults into centralized abstract classes
- Android Quick Launch shortcut icons now dynamically display group initials with theme colors or group images
- Consolidated currency formatting using CurrencyDisplay widget throughout the app for consistency
- Currency display now uses locale-aware decimal separators respecting user's regional settings
- Applied consistent TabBar styling across History, Stats, and Overview pages for unified experience
- Replaced icon button with text button in expense form for improved accessibility and clarity

### Fixed
- Auto-location setting not saving when modified alone in expense group settings
- Android map rendering issues by adding INTERNET permission and OpenStreetMap domain to security configuration

## [1.0.45] - 2025-10-16

### Fixed
- Completed translations for all supported languages (Spanish, Portuguese, Chinese)
- Added 3 missing translation keys in Spanish
- Added 81 missing translation keys in Portuguese
- Added 135 missing translation keys in Chinese
- Removed 60 obsolete translation keys from Chinese
- All languages now have complete parity with English (511 keys each)

## [1.0.44] - 2025-01-09

### Changed
- Refactored save button enable logic tests for improved readability and consistency

## [1.0.38] - 2025-01-07

### Added
- "What's New" page accessible from version number in settings
- Localized changelog support (English, Italian, Spanish, Portuguese, Chinese)

### Changed
- Optimized user interface for Material 3

### Fixed
- Minor fixes for app stability

## [1.0.0] - Initial Release

### Added
- Group expense management for trips and shared costs
- Participant management with detailed tracking
- Expense tracking with categories and assignments
- Smart calculations for debt settlement
- Location context for expenses
- Photo attachments for groups and expenses
- Data export to CSV and JSON formats
- Complete backup and restore functionality
- Privacy-first local storage (no cloud sync)
- Multi-language support (English, Italian, Spanish, Portuguese, Chinese)
- Material 3 design with dark/light theme support
- Cross-platform support (Android, iOS, Web, Desktop)

[Unreleased]: https://github.com/calca/caravella/compare/v1.2.0...HEAD
[1.2.0]: https://github.com/calca/caravella/compare/v1.0.45...v1.2.0
[1.0.45]: https://github.com/calca/caravella/compare/v1.0.44...v1.0.45
[1.0.44]: https://github.com/calca/caravella/compare/v1.0.38...v1.0.44
[1.0.38]: https://github.com/calca/caravella/compare/v1.0.0...v1.0.38
[1.0.0]: https://github.com/calca/caravella/releases/tag/v1.0.0
