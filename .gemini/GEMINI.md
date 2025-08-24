# Caravella Flutter App

Caravella is a modern Flutter application for managing group expenses, travel costs, and participants with local persistence and Material 3 UX. Ideal for group trips, roommates, events, or any situation where multiple people share expenses. Designed to be simple, intuitive, multi-platform (Android/iOS/web/desktop), and easily extensible.

**ALWAYS reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.**

## Working Effectively

### Prerequisites
- **Install Flutter SDK (latest stable channel)** (CI now tracks latest stable):
  ```bash
  # Option 1: Use Flutter Version Manager (recommended)
  # git clone https://github.com/fvm/fvm.git
  # fvm install stable
  # fvm use stable
  
  # Option 2: Direct download (if FVM not available)
  # (Oppure scarica l'ultima stable manualmente dal sito Flutter)
  export PATH="$PWD/flutter/bin:$PATH"
  
  # Verify installation
  flutter --version
  flutter doctor
  ```

### Exact Commands from CI Pipeline
**These commands are validated to work in the CI environment (latest stable):**
### Exact Commands from CI Pipeline
**These commands are validated to work in the CI environment:**

- **Install dependencies**:
  ```bash
  flutter pub get
  ```
  
- **Code analysis** (required before commit):
  ```bash
  flutter analyze
  ```

- **Run tests** (currently minimal but functional):
  ```bash
  flutter test
  ```
  Takes ~2-3 minutes. NEVER CANCEL. Set timeout to 5+ minutes.

- **Build APK** - Production staging (validated in CI):
  ```bash
  flutter build apk --flavor staging --release --dart-define=FLAVOR=staging
  ```
  Build takes 8-12 minutes. NEVER CANCEL. Set timeout to 20+ minutes.

- **Build APK** - Other flavors:
  ```bash
  # Development build
  flutter build apk --flavor dev --dart-define=FLAVOR=dev
  
  # Production build
  flutter build apk --flavor prod --release --dart-define=FLAVOR=prod
  ```

### Additional Setup Commands
### Additional Setup Commands

- **Generate app icons** (for different flavors):
  ```bash
  # Production icons (default configuration)
  flutter pub run flutter_launcher_icons:main
  
  # Note: Staging and dev icon configs exist in pubspec.yaml but 
  # may require additional setup. The main production icons should work.
  ```

- **Analyze code**:
  ```bash
  flutter analyze
  ```

- **Run tests**:
  ```bash
  flutter test
  ```
  Takes ~2-3 minutes. NEVER CANCEL. Set timeout to 5+ minutes.

- **Build APK** (with signing for release):
  ```bash
  # Development build
  flutter build apk --flavor dev --dart-define=FLAVOR=dev
  
  # Staging build  
  flutter build apk --flavor staging --release --dart-define=FLAVOR=staging
  
  # Production build
  flutter build apk --flavor prod --release --dart-define=FLAVOR=prod
  ```
  Build takes 5-10 minutes. NEVER CANCEL. Set timeout to 15+ minutes.

### Run the Application

- **Development mode** (hot reload enabled):
  ```bash
  # Default prod flavor
  flutter run
  
  # Development flavor
  flutter run --flavor dev --dart-define=FLAVOR=dev
  
  # Staging flavor
  flutter run --flavor staging --dart-define=FLAVOR=staging
  ```

- **VS Code debugging**: Use the configured launch configurations in `.vscode/launch.json`:
  - "Run (Dev)" - Development flavor
  - "Run (Staging)" - Staging flavor  
  - "Run (Prod)" - Production flavor

### Platform-Specific Builds
- **Android**: `flutter build apk --flavor [dev|staging|prod]`
- **iOS**: `flutter build ios --flavor [dev|staging|prod]` (requires macOS)
- **Web**: `flutter build web --dart-define=FLAVOR=prod`
- **Linux**: `flutter build linux --dart-define=FLAVOR=prod`
- **Windows**: `flutter build windows --dart-define=FLAVOR=prod`
- **macOS**: `flutter build macos --dart-define=FLAVOR=prod`

## Validation

### Manual Testing Scenarios
**ALWAYS run through at least one complete end-to-end scenario after making changes:**

1. **App Launch Flow**:
   - App launches without crashing on target platform
   - Home page displays correctly with Material 3 design
   - Navigation between pages works smoothly
   - Theme switching (light/dark) works correctly

2. **Core Group Management**:
   - Create a new group/trip with name and participants
   - Add at least 2-3 participants to the group
   - Navigate to group details and verify data persistence
   - Edit group information and verify changes saved

3. **Expense Management**:
   - Add expenses with different categories and amounts
   - Assign expenses to different participants
   - View expense summary and verify calculations
   - Test expense editing and deletion

4. **Data Operations**:
   - Export group data to CSV and verify file creation
   - Test backup functionality (data export)
   - Test restore functionality (data import)
   - Verify data persistence after app restart

5. **Settings and Preferences**:
   - Change theme (light/dark/system) and verify persistence
   - Switch language (IT/EN) and verify UI updates
   - Test flag secure setting (Android)
   - Verify app version display in settings

6. **Multi-flavor Testing** (when working with flavors):
   - Verify correct app name for each flavor (Caravella, Caravella - Staging, Caravella - Dev)
   - Check app icon displays correctly for flavor
   - Verify flavor-specific configurations work
   - Test that different flavors can be installed simultaneously

### Automated Testing
- Run `flutter test` to execute unit and widget tests
- Main test files:
  - `test/smoke_test.dart` - Basic app launch test
  - `test/widget_test.dart` - Currently empty but available for expansion

### Pre-commit Validation
**ALWAYS run these commands before committing changes or the CI will fail:**
```bash
flutter analyze
flutter test
```

## Build and CI Information

### CI Pipeline (.github/workflows/flutter.yml)
- Runs on Ubuntu latest
- Uses Flutter 3.35.1 stable
- **Build timeout**: 15+ minutes for APK builds. NEVER CANCEL.
- **Test timeout**: 5+ minutes for test execution. NEVER CANCEL.
- Supports signed APK generation for staging and production
- Automatic version bumping on releases

### Build Artifacts
- **Debug builds**: Located in `build/app/outputs/flutter-apk/`
- **APK naming**: `app-[flavor]-[debug|release].apk`
- **Signed APKs**: Require keystore configuration in `android/key.properties`

## Project Structure and Key Files

### Main Directories
- `lib/` — Main source code (pages, modules, widgets, storage, state)
  - `lib/main.dart` — App entry point with flavor support
  - `lib/config/` — App configuration and environment settings
  - `lib/state/` — State management with Provider
  - `lib/widgets/` — Reusable UI components
  - `lib/home/` — Home page implementation
  - `lib/settings/` — Settings and preferences
  - `lib/themes/` — Material 3 theme configuration
- `assets/` — Images, icons, fonts
  - `assets/icons/caravella-icon.png` — Main app icon
  - `assets/fonts/` — Montserrat font family
- `test/` — Unit and widget tests
- `android/`, `ios/`, `web/`, `linux/`, `windows/`, `macos/` — Platform-specific code

### Configuration Files
- `pubspec.yaml` — Dependencies, assets, version (v1.0.26+28)
- `analysis_options.yaml` — Dart linting rules (uses flutter_lints)
- `.vscode/launch.json` — VS Code debug configurations with flavors
- `android/app/build.gradle.kts` — Android build configuration with flavors
- `android/app/src/main/AndroidManifest.xml` — Android permissions and config

### Common File Patterns
- **State management**: Provider pattern, check files in `lib/state/`
- **Themes**: Material 3 implementation in `lib/themes/`
- **Storage**: Local JSON file persistence using `path_provider`

## Dependencies and Packages

### Key Dependencies
- `provider` ^6.1.1 — State management
- `path_provider` ^2.1.5 — Local file storage
- `package_info_plus` ^8.3.0 — App version info
- `shared_preferences` ^2.5.3 — User preferences
- `fl_chart` ^1.0.0 — Data visualization
- `share_plus` ^11.0.0 — File sharing (CSV export)
- `file_picker` ^10.2.0 — File import/export
- `url_launcher` ^6.3.1 — External links

### Development Dependencies
- `flutter_lints` ^6.0.0 — Code analysis
- `flutter_launcher_icons` ^0.14.4 — Icon generation

## Troubleshooting

### Common Issues
1. **Icon generation fails**: Ensure `assets/icons/caravella-icon.png` exists (verified present)
2. **Build failures**: Clean build cache with `flutter clean && flutter pub get`
3. **Flavor issues**: Always use `--dart-define=FLAVOR=[flavor]` with builds
4. **Signing errors**: Verify `android/key.properties` exists for release builds
5. **Permission issues**: App requires camera and storage permissions (see AndroidManifest.xml)

### Build Cache Management
```bash
# Clean build cache
flutter clean

# Clean and rebuild dependencies
flutter clean && flutter pub get

# Full reset with icon regeneration
flutter clean && flutter pub get && flutter pub run flutter_launcher_icons:main
```

### Platform-Specific Issues
- **Android**: Requires NDK version 27.0.12077973, compile SDK from Flutter
- **Signing**: Production builds require keystore configuration
- **Flavors**: Each flavor has different app ID suffix (.dev, .staging)

## Timing Expectations

- **pub get**: 30-60 seconds
- **flutter analyze**: 10-30 seconds  
- **flutter test**: 2-3 minutes (NEVER CANCEL - set 5+ minute timeout)
- **debug build**: 2-5 minutes
- **release APK build**: 8-12 minutes (NEVER CANCEL - set 20+ minute timeout)
- **icon generation**: 30-60 seconds
- **Hot reload**: <3 seconds
- **Hot restart**: 5-10 seconds

**CRITICAL**: Never cancel builds or long-running commands. Flutter release builds can take 12+ minutes (confirmed from CI), tests can take 3+ minutes. Always set appropriate timeouts and wait for completion.


## Principi generali
- Scrivere sempre codice **manutenibile, leggibile e scalabile**.
- Applicare le **best practice di sicurezza** (validazione input, gestione errori, niente credenziali hardcoded).
- Seguire un approccio **enterprise-grade**, adatto ad applicazioni di **complessità alta**.
- Favorire sempre **riuso e astrazione**: non duplicare codice se può essere estratto in un componente/servizio condiviso.
- Ogni modifica deve rispettare e rinforzare le convenzioni già presenti nel progetto.

## Componenti e UI
- Ogni nuovo widget o componente UI deve:
  - Seguire **unico design system** definito dal progetto (colori, tipografia, spaziature, bordi, ecc.).
  - Essere progettato come **riutilizzabile** e **parametrizzabile**.
  - Essere **compatibile con la preview di Visual Studio Code** (se il linguaggio/framework lo supporta).
- Verificare sempre se esiste già un widget simile prima di crearne uno nuovo.
- Ogni componente deve avere una chiara separazione tra **presentazione (UI)** e **logica (stato/servizi)**.

## Gestione dello stato
- Lo stato deve essere **centralizzato e condiviso** (es. tramite state manager globale o pattern architetturale coerente).
- Evitare gestione dello stato locale non necessaria.
- La sincronizzazione dello stato tra componenti deve seguire i principi di **single source of truth**.

## Servizi e data layer
- Tutti i servizi per l’accesso ai dati devono essere:
  - **Condivisi e riutilizzabili**.
  - Integrati con un **sistema di caching** per ridurre le chiamate ridondanti.
  - Strutturati in modo coerente (pattern repository o simili).
- Gestire sempre gli errori e i fallback nei servizi.
- Non accedere mai direttamente alle API dai widget: usare solo i servizi definiti.

## Sicurezza
- Validare sempre input e output dei servizi.
- Usare protocolli sicuri (https, token, gestione sessioni).
- Evitare injection e vulnerabilità comuni (es. SQLi, XSS).
- Non esporre mai informazioni sensibili lato client.

## Checklist per Copilot prima di generare/modificare codice
1. Esiste già un componente/servizio che può essere riutilizzato?
2. Il codice segue il design system unico del progetto?
3. Lo stato è gestito in modo centralizzato e coerente?
4. I dati passano attraverso un servizio condiviso con caching?
5. La sicurezza è garantita (input, error handling, credenziali)?
6. Il widget è pronto per la preview in Visual Studio Code?
7. La soluzione proposta è scalabile e manutenibile nel lungo periodo?

## Nota finale
Se Copilot deve scegliere tra più soluzioni possibili:
- Preferire sempre quella **più riutilizzabile e modulare**.
- Preferire sempre quella **più sicura**.
- Preferire sempre quella **più allineata alle convenzioni e best practice** già adottate.