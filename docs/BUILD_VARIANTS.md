# Build Configuration Guide

## Play Store Updates Package

Il progetto ora supporta build con e senza funzionalità di aggiornamento Google Play Store, usando un package separato e flag di compilazione.

### Struttura

```
org_app_split/
├── lib/
│   └── updates/
│       ├── update_service_interface.dart  # Interfaccia astratta
│       ├── update_service_noop.dart       # Implementazione vuota (F-Droid)
│       ├── update_service_playstore.dart  # Implementazione Play Store
│       ├── update_service_factory.dart    # Factory per creare istanze
│       ├── updates.dart                   # Export principale
│       ├── update_check_widget.dart       # Widget UI
│       └── update_check_helper.dart       # Helper functions
└── packages/
    └── play_store_updates/               # Package separato
        ├── lib/
        │   ├── src/
        │   │   ├── app_update_service.dart
        │   │   ├── app_update_notifier.dart
        │   │   └── logger_adapter.dart
        │   └── play_store_updates.dart
        └── pubspec.yaml
```

### Build con Play Store Support (default per staging/prod)

```bash
# Con flag esplicito
flutter build apk --dart-define=ENABLE_PLAY_UPDATES=true --dart-define=FLAVOR=prod --flavor prod --release

# Oppure aggiungi ai launch configs in .vscode/launch.json
```

### Build senza Play Store Support (F-Droid)

```bash
# Senza il flag, usa implementazione no-op
flutter build apk --dart-define=FLAVOR=prod --flavor prod --release
```

### Configurazione VS Code

Aggiorna `.vscode/launch.json`:

```json
{
  "name": "org_app_split (prod - Play Store)",
  "request": "launch",
  "type": "dart",
  "args": [
    "--dart-define=FLAVOR=prod",
    "--dart-define=ENABLE_PLAY_UPDATES=true"
  ]
},
{
  "name": "org_app_split (prod - F-Droid)",
  "request": "launch",
  "type": "dart",
  "args": [
    "--dart-define=FLAVOR=prod"
  ]
}
```

### Come Funziona

1. **UpdateServiceFactory** crea l'istanza appropriata basata sul flag `ENABLE_PLAY_UPDATES`
2. Se `ENABLE_PLAY_UPDATES=true`:
   - Usa `PlayStoreUpdateService` che wrappa il package `play_store_updates`
   - Funzionalità completa di aggiornamento Google Play
3. Se `ENABLE_PLAY_UPDATES=false` o non specificato:
   - Usa `NoOpUpdateService` che non fa nulla
   - Nessuna dipendenza da Google Play Services
   - Ideale per F-Droid

### Testing

```bash
# Test senza Play updates (dovrebbe compilare senza errori)
flutter build apk --dart-define=FLAVOR=dev --flavor dev

# Test con Play updates
flutter build apk --dart-define=ENABLE_PLAY_UPDATES=true --dart-define=FLAVOR=dev --flavor dev
```

### Vantaggi

- ✅ Build F-Droid senza dipendenze Google
- ✅ Stesso codice sorgente per entrambe le versioni
- ✅ Nessun codice Play Store incluso nelle build F-Droid
- ✅ Type-safe tramite interfacce comuni
- ✅ Zero overhead quando disabilitato

### Note Implementative

- Il widget `UpdateCheckWidget` mostra sempre l'opzione ma è disabilitata quando non su Android
- La funzione `checkAndShowUpdateIfNeeded()` viene chiamata all'avvio ma non fa nulla se gli updates sono disabilitati
- Il logger adapter permette al package di usare il sistema di logging dell'app principale

## Android Home Widget

Il progetto supporta l'esclusione del widget Android tramite un flag di compilazione.

### Build con Widget Android (default)

```bash
# Il widget è abilitato di default, non serve specificare il flag
flutter build apk --dart-define=FLAVOR=prod --flavor prod --release
```

### Build senza Widget Android (CI/GitHub Workflows)

```bash
# Disabilita il widget Android
flutter build apk --dart-define=ENABLE_ANDROID_WIDGET=false --dart-define=FLAVOR=prod --flavor prod --release
```

### Come Funziona

1. **AppConfig.enableAndroidWidget** legge il flag `ENABLE_ANDROID_WIDGET` (default: `true`)
2. **PlatformHomeWidgetManager** controlla il flag prima di eseguire qualsiasi operazione widget
3. **Android nativo**: il `build.gradle.kts` legge il flag dalla property Gradle o dalla variabile d'ambiente `ENABLE_ANDROID_WIDGET` e:
   - Genera una risorsa booleana `@bool/enable_android_widget`
   - Il `AndroidManifest.xml` usa `android:enabled="@bool/enable_android_widget"` su receiver e activity del widget
4. Se `ENABLE_ANDROID_WIDGET=false`:
   - Il widget non viene inizializzato lato Flutter
   - Il receiver e l'activity nativa sono disabilitati nel manifest
   - Il widget non appare nel picker di widget Android
