# Voice Input Feature for Expenses

## Overview

The voice input feature allows users to add expenses by speaking them out loud. The app automatically recognizes the amount, description, and category from the voice input.

## How It Works

### User Interface
- A microphone button is displayed in the expense form (visible only when adding a new expense, not when editing)
- When tapped, the button animates to show it's listening
- After speaking, the app processes the input and automatically fills the form fields

### Voice Recognition
- Uses the native speech recognition APIs from Android and iOS
- Supports multiple languages (Italian and English initially)
- Works offline on most modern devices

### Parsing Algorithm
The voice input is parsed using regular expressions to extract:

1. **Amount**: Looks for numbers with optional currency symbols or keywords
   - Examples: "50 euro", "€50", "$50", "50 dollars", "50.50 euros"
   
2. **Description**: Extracts the expense name using context keywords
   - Italian: "per", "di", "a"
   - English: "for", "of", "at"
   - Examples: "per cena", "for dinner", "di benzina"

3. **Category**: Attempts to match keywords to predefined categories
   - Food: cena, pranzo, colazione, ristorante, dinner, lunch, etc.
   - Transport: benzina, gas, taxi, treno, train, etc.
   - Accommodation: hotel, albergo, airbnb, etc.
   - Entertainment: cinema, teatro, museo, etc.
   - Shopping: shopping, acquisti, negozio, etc.

## Usage Examples

### Italian
- "50 euro per cena al ristorante" → Amount: 50, Name: "cena al ristorante", Category: food
- "35,75 euro di benzina" → Amount: 35.75, Name: "benzina", Category: transport
- "100 euro per hotel" → Amount: 100, Name: "hotel", Category: accommodation

### English
- "50 dollars for dinner at restaurant" → Amount: 50, Name: "dinner at restaurant", Category: food
- "25.50 for gas" → Amount: 25.50, Name: "gas", Category: transport
- "100 for hotel" → Amount: 100, Name: "hotel", Category: accommodation

## Permissions

### Android
- `RECORD_AUDIO`: Required for microphone access
- The permission is requested at runtime when the user first taps the voice button

### iOS
- `NSMicrophoneUsageDescription`: Required for microphone access
- `NSSpeechRecognitionUsageDescription`: Required for speech recognition

## Implementation Details

### Files Added
1. `lib/services/voice_input_service.dart`: Core service handling speech recognition and parsing
2. `lib/manager/expense/expense_form/voice_input_button.dart`: UI component for the voice button
3. `test/voice_input_service_test.dart`: Unit tests for parsing logic

### Files Modified
1. `lib/manager/expense/expense_form_component.dart`: Integrated voice button into expense form
2. `pubspec.yaml`: Added `speech_to_text` dependency
3. `android/app/src/main/AndroidManifest.xml`: Added microphone permission
4. `ios/Runner/Info.plist`: Added microphone and speech recognition permissions
5. `lib/l10n/app_it.arb` & `lib/l10n/app_en.arb`: Added localization strings

### Dependencies
- `speech_to_text: ^7.0.0`: Flutter plugin for speech recognition

## Testing

Run the unit tests with:
```bash
flutter test test/voice_input_service_test.dart
```

The tests cover:
- Amount parsing with various formats
- Description extraction in Italian and English
- Category detection from keywords
- Edge cases (empty text, no numbers, etc.)

## Future Improvements

Potential enhancements:
1. Support for more languages (Spanish, Portuguese, Chinese)
2. Custom category keyword mapping per user
3. Voice feedback/confirmation
4. Support for multiple expenses in one voice command
5. Learning from user corrections to improve parsing
6. Participant detection ("paid by John")
7. Date/time recognition ("yesterday", "last week")

## Accessibility

The voice input feature enhances accessibility by:
- Providing an alternative input method for users with mobility challenges
- Being faster for users who prefer speaking over typing
- Working with screen readers and other assistive technologies

## Privacy

- Voice data is processed locally on the device using native APIs
- No voice data is sent to external servers
- Voice recognition only activates when the user explicitly taps the button
- The microphone permission can be revoked at any time in system settings
