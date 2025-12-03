# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Media attachments support for expenses with image, PDF, and video file types (max 5 per expense)
- Attachment picker with camera, gallery, and file selection options
- Full-screen attachment viewer with swipe navigation, delete and share actions
- PDF preview with full document rendering and scrolling support
- Video playback with player controls (play, pause, seek, volume)
- Horizontal thumbnail gallery for viewing and managing expense attachments
- Image compression for attachments (max 1920px, 85% quality JPEG) to optimize storage
- Automatic file cleanup when deleting expenses or expense groups
- Organized attachment storage by expense group ID for better file management

### Technical
- **Platform Abstraction Services**: Added service abstractions in `caravella_core` for better testability:
  - `FilePickerService`: Abstraction for `image_picker` and `file_picker` dependencies
  - `ImageCompressionService`: Abstraction for image compression logic
  - `LocationServiceAbstraction`: Abstraction for `geolocator` and `geocoding` dependencies
- Implementations moved to `lib/manager/expense/services/` with platform-specific code isolated
- `LocationService` refactored to use `LocationServiceAbstraction` for improved testability
- Added comprehensive unit tests for all service abstractions (29 tests, 100% pass rate)
- **AttachmentInputWidget Refactoring**: Reduced complexity from 406 to 215 lines by extracting components:
  - `AttachmentSlot`: Reusable slot widget for empty/filled states (182 lines)
  - `AttachmentStateManager`: Business logic and state management (147 lines)
  - Improved testability with ChangeNotifier pattern and service injection
  - Added 8 unit tests for state manager with 100% pass rate
- **AttachmentViewerPage Refactoring**: Simplified from 378 to 178 lines (53% reduction) by extracting specialized viewers:
  - `PdfViewerPage`: Standalone PDF document viewer with loading and error states (95 lines)
  - `VideoPlayerPage`: Video player with controls using Chewie (107 lines)
  - `ImageViewerPage`: Image viewer with pinch-to-zoom support (46 lines)
  - `AttachmentViewerController`: State management for viewer navigation and deletion (44 lines)
  - Main page now acts as coordinator/orchestrator delegating to specialized viewers
  - Improved code reusability and maintainability with separated concerns
- **Validation and Error Handling Consolidation**: Centralized validation and error handling for consistency:
  - `ExpenseValidationService`: Pure validation functions for amounts, names, participants, categories (113 lines)
  - `ExpenseErrorHandler`: Centralized error messaging using AppToast for all expense operations (169 lines)
  - Validation logic extracted from controllers and made independently testable
  - Consistent error messaging across attachment, location, and form validation flows
  - ExpenseFormController migrated to use ExpenseValidationService
  - AttachmentInputWidget migrated to use ExpenseErrorHandler
- **Location Subsystem Reorganization**: Eliminated circular dependencies and improved architecture:
  - `LocationRepository`: Abstract interface for location operations (29 lines)
  - `LocationRepositoryImpl`: Coordinates LocationService and NominatimSearchService (139 lines)
  - `LocationConstants`: Consolidated constants from multiple files (25 lines)
- **ExpenseFormComponent Refactoring**: Dramatically improved maintainability by consolidating parameters and extracting lifecycle logic:
  - `ExpenseFormConfig`: Configuration object consolidating 43 constructor parameters into structured config (160 lines)
  - `ExpenseFormLifecycleManager`: Lifecycle management with auto-location, category handling, and resource cleanup (161 lines)
  - `ExpenseFormOrchestrator`: Business logic coordination for save/delete flows and form callbacks (132 lines)
  - Constructor reduced from 43 parameters to 1 config object (98% reduction in parameters)
  - Factory methods (`.create()` and `.edit()`) for common use cases with backward compatibility
  - Legacy constructor (`.legacy()`) maintains full backward compatibility with existing code
  - Improved testability with separated concerns and clear responsibility boundaries
  - `LocationService` simplified from 149 to 68 lines (54% reduction) using repository pattern
  - Linear dependency chain: Widgets → LocationService → LocationRepository → Platform services
  - Error handling migrated to ExpenseErrorHandler for consistency
  - Removed circular dependencies between widgets and services

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
