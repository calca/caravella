# Voice Input Quick Reference

## Quick Start

### For Users
1. Open expense form (tap + button)
2. Tap the microphone button 🎤
3. Allow microphone permission if prompted
4. Speak your expense (e.g., "50 euro per cena")
5. Review auto-filled fields
6. Tap "Salva" to save

### For Developers
See the detailed documentation files:
- **VOICE_INPUT_FEATURE.md** - Feature overview and usage
- **IMPLEMENTATION_SUMMARY.md** - Implementation details
- **ARCHITECTURE_FLOW.md** - System architecture and data flow
- **UI_MOCKUP.md** - UI design and visual specifications

## Code Locations

### Core Implementation
```
lib/services/voice_input_service.dart          - Service layer
lib/manager/expense/expense_form/
  voice_input_button.dart                       - UI widget
lib/manager/expense/expense_form_component.dart - Integration
```

### Tests
```
test/voice_input_service_test.dart              - Unit tests
```

### Configuration
```
pubspec.yaml                                    - Dependencies
android/app/src/main/AndroidManifest.xml        - Android permissions
ios/Runner/Info.plist                           - iOS permissions
```

### Localization
```
lib/l10n/app_it.arb                             - Italian strings
lib/l10n/app_en.arb                             - English strings
```

## Key Classes & Methods

### VoiceInputService
```dart
// Check if available
Future<bool> isAvailable()

// Start listening
Future<void> startListening({
  required Function(String) onResult,
  required Function(String) onError,
  String? localeId,
})

// Stop listening
Future<void> stopListening()

// Parse voice text (static)
static Map<String, dynamic> parseExpenseFromText(String text)
```

### VoiceInputButton
```dart
VoiceInputButton({
  required Function(Map<String, dynamic>) onVoiceResult,
  String? localeId,
})
```

### ExpenseFormComponent Integration
```dart
Widget _buildVoiceInputSection()
void _handleVoiceInput(Map<String, dynamic> parsedData)
```

## Voice Pattern Examples

### Italian
```dart
"50 euro per cena"           → amount: 50, name: "cena"
"35,75 euro di benzina"      → amount: 35.75, name: "benzina"
"100 euro per hotel"         → amount: 100, name: "hotel"
"25 euro a pranzo"           → amount: 25, name: "pranzo"
```

### English
```dart
"50 dollars for dinner"      → amount: 50, name: "dinner"
"25.50 for gas"              → amount: 25.50, name: "gas"
"100 for hotel"              → amount: 100, name: "hotel"
"20 at restaurant"           → amount: 20, name: "restaurant"
```

## Regex Patterns

### Amount Extraction
```dart
r'(\d+(?:[.,]\d{1,2})?)\s*(?:euro|eur|€|dollar|usd|\$|pound|£)?'
```

### Description (Italian)
```dart
r'(?:per|di|a)\s+(.+?)(?:\s+al|\s+alla|\s+in|\s+da|$)'
```

### Description (English)
```dart
r'(?:for|of|at)\s+(.+?)(?:\s+at|\s+in|\s+from|$)'
```

## Category Keywords

```dart
'food': [
  'cena', 'pranzo', 'colazione', 'ristorante',
  'dinner', 'lunch', 'breakfast', 'restaurant', 'cibo', 'food'
]

'transport': [
  'benzina', 'gas', 'taxi', 'treno', 'train',
  'autobus', 'bus', 'metro', 'aereo', 'flight'
]

'accommodation': [
  'hotel', 'albergo', 'airbnb', 'ostello', 'hostel', 'affitto', 'rent'
]

'entertainment': [
  'cinema', 'teatro', 'theater', 'museum', 'museo', 'concerto', 'concert'
]

'shopping': [
  'shopping', 'acquisti', 'negozio', 'shop', 'store'
]
```

## Testing Commands

### Run Unit Tests
```bash
flutter test test/voice_input_service_test.dart
```

### Run All Tests
```bash
flutter test
```

### Run with Coverage
```bash
flutter test --coverage
```

## Common Issues & Solutions

### Issue: Voice button not showing
**Solution**: Check if `widget.initialExpense != null` (voice input hidden in edit mode)

### Issue: Permission denied
**Solution**: User needs to grant microphone permission in system settings

### Issue: Recognition not working
**Solution**: 
1. Check device has Google Speech Services (Android) or Speech framework (iOS)
2. Check internet connection (may be needed for first-time model download)
3. Check microphone is not being used by another app

### Issue: Parsing returns empty
**Solution**: 
- Ensure text contains numbers
- Check if text uses supported keywords
- User can manually type if parsing fails

### Issue: Category not detected
**Solution**: Add more keywords to categoryKeywords map in VoiceInputService

## Debug Mode

Add these to VoiceInputService for debugging:

```dart
// Enable debug logging
onError: (error) {
  debugPrint('Speech recognition error: $error');
  debugPrint('Error details: ${error.errorMsg}');
}

// Log recognized text
onResult: (result) {
  debugPrint('Recognized: ${result.recognizedWords}');
  debugPrint('Confidence: ${result.confidence}');
  if (result.finalResult) {
    final parsed = VoiceInputService.parseExpenseFromText(
      result.recognizedWords
    );
    debugPrint('Parsed: $parsed');
  }
}
```

## Performance Tips

### Initialization
- Service initializes lazily on first use
- Check `isAvailable()` returns quickly after first call
- Keep single instance of VoiceInputService per form

### Memory
- Service auto-cleans up on widget dispose
- Animation controller properly disposed
- No memory leaks from speech recognition

### Battery
- Listening stops automatically after recognition
- No background listening (only active when button pressed)
- Platform APIs handle power management

## Accessibility

### Screen Reader Support
```dart
Semantics(
  button: true,
  label: gloc.voice_input_button,
  hint: gloc.voice_input_tap_to_speak,
  child: VoiceInputButton(...)
)
```

### Keyboard Navigation
- Button is focusable with tab key
- Can be activated with Enter or Space
- Focus indicator visible in high contrast mode

## Localization

### Add New Language
1. Add strings to `lib/l10n/app_xx.arb`:
```json
{
  "voice_input_button": "...",
  "voice_input_listening": "...",
  "voice_input_hint": "..."
}
```

2. Update locale mapping in VoiceInputButton:
```dart
final localeId = locale == 'it' ? 'it_IT' 
               : locale == 'es' ? 'es_ES'
               : 'en_US';
```

3. Add keywords to VoiceInputService.parseExpenseFromText()

## CI/CD Integration

### GitHub Actions
The CI already includes:
- `flutter pub get` - Installs speech_to_text package
- `flutter analyze` - Checks for code issues
- `flutter test` - Runs unit tests including voice tests
- `flutter build apk` - Builds APK with permissions

### Build Verification
```bash
# Check permissions in manifest
grep -A 2 "RECORD_AUDIO" android/app/src/main/AndroidManifest.xml

# Check dependency installed
grep "speech_to_text" pubspec.yaml
```

## Version Compatibility

### Minimum Requirements
- Flutter: >=3.0.0
- Dart: >=3.9.0
- Android: SDK 21+ (Android 5.0 Lollipop)
- iOS: 10.0+

### Tested Platforms
- Android: 10, 11, 12, 13, 14
- iOS: 14, 15, 16, 17

## Contributing

### Adding New Features
1. Update VoiceInputService for backend logic
2. Update VoiceInputButton for UI changes
3. Add tests in voice_input_service_test.dart
4. Update localization files
5. Update documentation

### Code Style
- Follow existing Flutter/Dart conventions
- Use Material 3 design patterns
- Add comments for complex logic
- Keep methods focused and small

## Support

### Documentation
- Read VOICE_INPUT_FEATURE.md for feature details
- Read IMPLEMENTATION_SUMMARY.md for technical overview
- Read ARCHITECTURE_FLOW.md for system design
- Read UI_MOCKUP.md for visual specs

### Debugging
- Enable Flutter DevTools for UI inspection
- Use `debugPrint()` for logging
- Check platform logs:
  - Android: `adb logcat | grep flutter`
  - iOS: Xcode console

### Contact
- GitHub Issues: Report bugs or suggest features
- Pull Requests: Contribute improvements
