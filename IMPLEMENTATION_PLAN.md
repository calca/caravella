# Piano di Implementazione - Risoluzione Debito Tecnico

## Overview
Questo documento fornisce un piano di azione specifico e implementabile per risolvere il debito tecnico identificato nell'analisi della codebase Caravella.

---

## 🔴 FASE 1: ALTA PRIORITÀ (Sprint 1-2)

### 1. Decomposizione Widget Grandi

#### Target: `ExpenseFormComponent` (844 linee → ~200 linee ciascun componente)

**File da creare:**

```dart
// lib/manager/expense/expense_form/expense_form_basic_section.dart
class ExpenseFormBasicSection extends StatelessWidget {
  // Nome, Importo, Categoria, Pagato da
}

// lib/manager/expense/expense_form/expense_form_advanced_section.dart  
class ExpenseFormAdvancedSection extends StatelessWidget {
  // Data, Posizione, Note
}

// lib/manager/expense/expense_form/expense_form_validation.dart
class ExpenseFormValidation {
  static String? validateAmount(String? value) { }
  static String? validateName(String? value) { }
  static bool isFormValid(ExpenseFormState state) { }
}

// lib/manager/expense/expense_form/expense_form_state.dart
class ExpenseFormState extends ChangeNotifier {
  // Gestione stato centralizzata del form
}
```

**Refactor `ExpenseFormComponent`:**
```dart
class ExpenseFormComponent extends StatefulWidget {
  // ... properties rimangono uguali
}

class _ExpenseFormComponentState extends State<ExpenseFormComponent> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ExpenseFormState(widget.initialExpense),
      child: Consumer<ExpenseFormState>(
        builder: (context, state, child) {
          return Column(
            children: [
              ExpenseFormBasicSection(),
              if (widget.fullEdit || widget.initialExpense != null)
                ExpenseFormAdvancedSection(),
              ExpenseFormActionsSection(),
            ],
          );
        },
      ),
    );
  }
}
```

**Effort**: 4-5 giorni  
**Files affected**: 5-6 nuovi file, 1 refactor maggiore

---

#### Target: `ExpenseGroupDetailPage` (751 linee → ~150-200 linee per sezione)

**File da creare:**

```dart
// lib/manager/details/widgets/expense_group_header.dart
class ExpenseGroupHeader extends StatelessWidget {
  // Titolo, immagine, statistiche base
}

// lib/manager/details/widgets/expense_group_tabs.dart
class ExpenseGroupTabs extends StatelessWidget {
  // Tab navigation (Spese, Statistiche, Pareggi)
}

// lib/manager/details/widgets/expense_group_actions.dart
class ExpenseGroupActions extends StatelessWidget {
  // FloatingActionButton, Menu azioni
}
```

**Effort**: 3-4 giorni

---

### 2. Centralizzazione SharedPreferences

**File da creare:**

```dart
// lib/data/services/preferences_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static SharedPreferences? _instance;
  
  static Future<SharedPreferences> get _prefs async {
    _instance ??= await SharedPreferences.getInstance();
    return _instance!;
  }
  
  // Locale
  static Future<String> getLocale() async {
    final prefs = await _prefs;
    return prefs.getString('selected_locale') ?? 'it';
  }
  
  static Future<void> setLocale(String locale) async {
    final prefs = await _prefs;
    await prefs.setString('selected_locale', locale);
  }
  
  // Theme
  static Future<String> getThemeMode() async {
    final prefs = await _prefs;
    return prefs.getString('theme_mode') ?? 'system';
  }
  
  static Future<void> setThemeMode(String mode) async {
    final prefs = await _prefs;
    await prefs.setString('theme_mode', mode);
  }
  
  // Flag Secure
  static Future<bool> getFlagSecureEnabled() async {
    final prefs = await _prefs;
    return prefs.getBool('flag_secure_enabled') ?? true;
  }
  
  static Future<void> setFlagSecureEnabled(bool enabled) async {
    final prefs = await _prefs;
    await prefs.setBool('flag_secure_enabled', enabled);
  }
  
  // User Name
  static Future<String?> getUserName() async {
    final prefs = await _prefs;
    return prefs.getString('user_name');
  }
  
  static Future<void> setUserName(String? name) async {
    final prefs = await _prefs;
    if (name != null) {
      await prefs.setString('user_name', name);
    } else {
      await prefs.remove('user_name');
    }
  }
}
```

**File da modificare:**

```dart
// lib/main.dart - Sostituire:
Future<void> _loadLocale() async {
  final prefs = await SharedPreferences.getInstance();
  final savedLocale = prefs.getString('selected_locale');
  setState(() {
    _locale = savedLocale ?? 'it';
  });
}

// Con:
Future<void> _loadLocale() async {
  final savedLocale = await PreferencesService.getLocale();
  setState(() {
    _locale = savedLocale;
  });
}
```

**Files da aggiornare:** 11 file (tutti quelli che usano SharedPreferences direttamente)

**Effort**: 1-2 giorni

---

### 3. Rimozione Print Statements e Setup Logging

**File da creare:**

```dart
// lib/data/services/logger_service.dart
import 'dart:developer' as developer;

enum LogLevel { debug, info, warning, error }

class LoggerService {
  static void log(
    String message, {
    LogLevel level = LogLevel.info,
    String? name,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final logName = name ?? 'caravella';
    
    switch (level) {
      case LogLevel.debug:
        developer.log(message, name: '$logName.debug');
        break;
      case LogLevel.info:
        developer.log(message, name: '$logName.info');
        break;
      case LogLevel.warning:
        developer.log(message, name: '$logName.warning');
        break;
      case LogLevel.error:
        developer.log(
          message,
          name: '$logName.error',
          error: error,
          stackTrace: stackTrace,
        );
        break;
    }
  }
  
  static void debug(String message, {String? name}) {
    log(message, level: LogLevel.debug, name: name);
  }
  
  static void info(String message, {String? name}) {
    log(message, level: LogLevel.info, name: name);
  }
  
  static void warning(String message, {String? name}) {
    log(message, level: LogLevel.warning, name: name);
  }
  
  static void error(
    String message, {
    String? name,
    Object? error,
    StackTrace? stackTrace,
  }) {
    log(
      message,
      level: LogLevel.error,
      name: name,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
```

**Files da modificare:**

```dart
// lib/data/storage_performance.dart - Sostituire:
print('$operation: ${duration.inMilliseconds}ms$cacheStatus$sizeInfo');

// Con:
LoggerService.debug(
  '$operation: ${duration.inMilliseconds}ms$cacheStatus$sizeInfo',
  name: 'storage.performance',
);
```

**Effort**: 0.5 giorni

---

### 4. Standardizzazione Error Handling

**File da creare:**

```dart
// lib/data/services/error_handler.dart
import 'package:flutter/material.dart';
import '../widgets/app_toast.dart';
import 'logger_service.dart';

class AppError {
  final String message;
  final String? userMessage;
  final Object? originalError;
  final StackTrace? stackTrace;
  final ErrorType type;
  
  AppError({
    required this.message,
    this.userMessage,
    this.originalError,
    this.stackTrace,
    this.type = ErrorType.general,
  });
}

enum ErrorType {
  network,
  storage,
  validation,
  permission,
  general,
}

class ErrorHandler {
  static void handleError(
    AppError error, {
    BuildContext? context,
    bool showToUser = true,
  }) {
    // Log dell'errore
    LoggerService.error(
      error.message,
      name: 'error.${error.type.name}',
      error: error.originalError,
      stackTrace: error.stackTrace,
    );
    
    // Mostra all'utente se richiesto
    if (showToUser && context != null) {
      final userMessage = error.userMessage ?? _getDefaultMessage(error.type);
      AppToast.showError(context, userMessage);
    }
  }
  
  static String _getDefaultMessage(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return 'Errore di connessione. Riprova più tardi.';
      case ErrorType.storage:
        return 'Errore nel salvataggio dei dati.';
      case ErrorType.validation:
        return 'Dati non validi.';
      case ErrorType.permission:
        return 'Permessi insufficienti.';
      case ErrorType.general:
        return 'Si è verificato un errore.';
    }
  }
  
  static AppError fromException(Object exception, StackTrace stackTrace) {
    if (exception is FileSystemException) {
      return AppError(
        message: 'File system error: ${exception.message}',
        type: ErrorType.storage,
        originalError: exception,
        stackTrace: stackTrace,
      );
    }
    
    // Altri tipi di eccezioni...
    
    return AppError(
      message: exception.toString(),
      originalError: exception,
      stackTrace: stackTrace,
    );
  }
}
```

**Esempio di utilizzo:**

```dart
// Prima:
try {
  await ExpenseGroupStorageV2.saveTrip(group);
} catch (e) {
  print('Error saving: $e');
  if (mounted) {
    AppToast.showError(context, 'Errore durante il salvataggio');
  }
}

// Dopo:
try {
  await ExpenseGroupStorageV2.saveTrip(group);
} catch (e, stackTrace) {
  ErrorHandler.handleError(
    ErrorHandler.fromException(e, stackTrace),
    context: context,
  );
}
```

**Effort**: 2-3 giorni per implementare e refactorare i 153 blocchi di error handling

---

## 🟡 FASE 2: MEDIA PRIORITÀ (Q1 2025)

### 5. Async State Management Improvements

**Problema**: Solo 3 usi di FutureBuilder/StreamBuilder

**Soluzione**: Implementare reactive patterns più avanzati

```dart
// lib/state/async_state.dart
enum AsyncState { idle, loading, success, error }

class AsyncValue<T> {
  final AsyncState state;
  final T? data;
  final Object? error;
  final StackTrace? stackTrace;
  
  const AsyncValue._({
    required this.state,
    this.data,
    this.error,
    this.stackTrace,
  });
  
  const AsyncValue.idle() : this._(state: AsyncState.idle);
  const AsyncValue.loading() : this._(state: AsyncState.loading);
  const AsyncValue.success(T data) : this.._(state: AsyncState.success, data: data);
  const AsyncValue.error(Object error, StackTrace stackTrace) 
    : this._(state: AsyncState.error, error: error, stackTrace: stackTrace);
  
  bool get isLoading => state == AsyncState.loading;
  bool get hasError => state == AsyncState.error;
  bool get hasData => state == AsyncState.success && data != null;
  
  Widget when<R>({
    required Widget Function() loading,
    required Widget Function(T data) data,
    required Widget Function(Object error, StackTrace stackTrace) error,
    Widget Function()? idle,
  }) {
    switch (state) {
      case AsyncState.idle:
        return idle?.call() ?? const SizedBox.shrink();
      case AsyncState.loading:
        return loading();
      case AsyncState.success:
        return data(this.data as T);
      case AsyncState.error:
        return error(this.error!, stackTrace!);
    }
  }
}
```

### 6. Performance Optimization

**Cache Layer per Storage:**

```dart
// lib/data/cache/storage_cache.dart
class StorageCache {
  static final Map<String, dynamic> _cache = {};
  static final Map<String, DateTime> _timestamps = {};
  static const Duration _defaultTtl = Duration(minutes: 5);
  
  static T? get<T>(String key) {
    final timestamp = _timestamps[key];
    if (timestamp == null) return null;
    
    if (DateTime.now().difference(timestamp) > _defaultTtl) {
      remove(key);
      return null;
    }
    
    return _cache[key] as T?;
  }
  
  static void set<T>(String key, T value) {
    _cache[key] = value;
    _timestamps[key] = DateTime.now();
  }
  
  static void remove(String key) {
    _cache.remove(key);
    _timestamps.remove(key);
  }
  
  static void clear() {
    _cache.clear();
    _timestamps.clear();
  }
}
```

---

## 📋 Checklist di Implementazione

### Sprint 1 (Settimana 1-2)
- [ ] **Giorno 1-2**: Setup di `PreferencesService`
- [ ] **Giorno 3**: Rimozione print statements + LoggerService
- [ ] **Giorno 4-5**: Inizio decomposizione `ExpenseFormComponent`
- [ ] **Giorno 6-8**: Completamento decomposizione widget
- [ ] **Giorno 9-10**: Setup ErrorHandler e prime integrazioni

### Sprint 2 (Settimana 3-4)  
- [ ] **Giorno 11-13**: Refactoring error handling (priorità alta)
- [ ] **Giorno 14-15**: Decomposizione `ExpenseGroupDetailPage`
- [ ] **Giorno 16-18**: Testing e validazione modifiche
- [ ] **Giorno 19-20**: Performance testing e ottimizzazioni

### Code Review e Quality Gates
- [ ] Tutti i widget > 500 linee sono stati decomposti
- [ ] Zero print statements rimanenti
- [ ] SharedPreferences centralizzato  
- [ ] Error handling consistente
- [ ] Coverage test mantiene >= 80%
- [ ] Performance non degrada
- [ ] Flutter analyze passa senza warning

---

## 🧪 Testing Strategy

### Test per ogni modifica:

1. **PreferencesService**:
```dart
// test/services/preferences_service_test.dart
test('should store and retrieve locale correctly', () async {
  await PreferencesService.setLocale('en');
  final locale = await PreferencesService.getLocale();
  expect(locale, 'en');
});
```

2. **ErrorHandler**:
```dart
// test/services/error_handler_test.dart  
test('should handle storage errors correctly', () {
  final error = AppError(
    message: 'Storage failed',
    type: ErrorType.storage,
  );
  // Verify logging and user feedback
});
```

3. **Widget Decomposition**:
```dart
// test/manager/expense/expense_form_basic_section_test.dart
testWidgets('ExpenseFormBasicSection displays all required fields', (tester) async {
  // Test widget rendering and interaction
});
```

---

## 🚀 Deployment Strategy

### Rollout Graduale:

1. **Fase Alpha** (Sviluppo interno):
   - Implementazione completa feature
   - Testing intensivo su staging

2. **Fase Beta** (Testing limitato):
   - Deploy su ambiente di staging
   - Testing da parte del team

3. **Fase Produzione**:
   - Feature flag per abilitazione graduale
   - Monitoring attivo per regressioni

### Rollback Plan:
- Git tags per ogni milestone
- Feature flags per disabilitare rapidamente
- Database migration scripts reversibili

---

*Piano implementazione v1.0 - 8 Gennaio 2025*