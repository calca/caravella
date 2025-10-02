# Voice Input Feature - Architecture & Flow

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        User Interface Layer                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌────────────────────────────────────────────────────────┐    │
│  │        ExpenseFormComponent                             │    │
│  │  ┌─────────────────────────────────────────────────┐   │    │
│  │  │  VoiceInputButton Widget                         │   │    │
│  │  │  - Shows microphone icon                         │   │    │
│  │  │  - Animates during listening                     │   │    │
│  │  │  - Shows processing state                        │   │    │
│  │  └─────────────────────────────────────────────────┘   │    │
│  │                       │                                  │    │
│  │                       ▼                                  │    │
│  │  ┌─────────────────────────────────────────────────┐   │    │
│  │  │  _handleVoiceInput()                             │   │    │
│  │  │  - Receives parsed data                          │   │    │
│  │  │  - Prefills form fields                          │   │    │
│  │  │  - Manages focus                                 │   │    │
│  │  └─────────────────────────────────────────────────┘   │    │
│  └────────────────────────────────────────────────────────┘    │
│                                                                   │
└───────────────────────────────┬───────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────┐
│                        Service Layer                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌────────────────────────────────────────────────────────┐    │
│  │        VoiceInputService                                │    │
│  │                                                          │    │
│  │  ┌──────────────────────────────────────────────────┐  │    │
│  │  │  Speech Recognition Methods                       │  │    │
│  │  │  - isAvailable()                                  │  │    │
│  │  │  - startListening()                               │  │    │
│  │  │  - stopListening()                                │  │    │
│  │  └──────────────────────────────────────────────────┘  │    │
│  │                                                          │    │
│  │  ┌──────────────────────────────────────────────────┐  │    │
│  │  │  Static Parsing Method                            │  │    │
│  │  │  - parseExpenseFromText()                         │  │    │
│  │  │    • Extract amount with regex                    │  │    │
│  │  │    • Extract description with context keywords    │  │    │
│  │  │    • Detect category from keywords                │  │    │
│  │  └──────────────────────────────────────────────────┘  │    │
│  └────────────────────────────────────────────────────────┘    │
│                                                                   │
└───────────────────────────────┬───────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Native Platform Layer                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌─────────────────────────┐     ┌─────────────────────────┐   │
│  │  Android                │     │  iOS                     │   │
│  │  ┌──────────────────┐   │     │  ┌──────────────────┐   │   │
│  │  │ SpeechRecognizer │   │     │  │ Speech Framework │   │   │
│  │  └──────────────────┘   │     │  └──────────────────┘   │   │
│  │  - RecognizerIntent     │     │  - SFSpeechRecognizer    │   │
│  │  - ACTION_RECOGNIZE     │     │  - SFSpeechAudioBuffer   │   │
│  └─────────────────────────┘     └─────────────────────────┘   │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

## Data Flow

```
1. User Action
   │
   ├─► Taps Microphone Button
   │
   ▼
2. Permission Check
   │
   ├─► Check if microphone permission granted
   │   ├─► If NO: Request permission
   │   └─► If YES: Continue
   │
   ▼
3. Speech Recognition Init
   │
   ├─► VoiceInputService.isAvailable()
   │   └─► Initialize native speech recognizer
   │
   ▼
4. Start Listening
   │
   ├─► VoiceInputService.startListening()
   │   ├─► Start native speech recognition
   │   ├─► Show "Listening..." UI
   │   └─► Animate microphone icon
   │
   ▼
5. User Speaks
   │
   ├─► "cinquanta euro per cena al ristorante"
   │   or
   ├─► "fifty dollars for dinner at restaurant"
   │
   ▼
6. Voice to Text (Native)
   │
   ├─► Platform converts speech to text
   │   └─► Returns recognized text
   │
   ▼
7. Parse Text
   │
   ├─► VoiceInputService.parseExpenseFromText()
   │   │
   │   ├─► Extract Amount
   │   │   ├─► Find numbers: 50, 25.50, 35,75
   │   │   └─► Recognize currency: euro, $, £
   │   │
   │   ├─► Extract Description
   │   │   ├─► Find context: "per", "for", "di", "of"
   │   │   └─► Extract text after context word
   │   │
   │   └─► Detect Category
   │       ├─► Match keywords to categories
   │       └─► food, transport, accommodation, etc.
   │
   ▼
8. Return Structured Data
   │
   └─► {
         "amount": 50.0,
         "name": "cena al ristorante",
         "category": "food"
       }
   │
   ▼
9. Update Form
   │
   ├─► ExpenseFormComponent._handleVoiceInput()
   │   ├─► Set amount field: 50.0
   │   ├─► Set name field: "cena al ristorante"
   │   └─► Set category: food
   │
   ▼
10. User Review
    │
    ├─► User can adjust fields if needed
    │   └─► Save expense
```

## State Machine - Voice Button

```
┌─────────────┐
│    IDLE     │
│ (mic icon)  │
└──────┬──────┘
       │
       │ User taps button
       │
       ▼
┌─────────────┐
│ LISTENING   │
│ (pulsing    │◄───┐
│  mic icon)  │    │
└──────┬──────┘    │
       │           │
       │ Speech    │ User taps again
       │ finalized │ (cancel)
       │           │
       ▼           │
┌─────────────┐    │
│ PROCESSING  │    │
│ (spinner)   │────┘
└──────┬──────┘
       │
       │ Parsing complete
       │
       ▼
┌─────────────┐
│   SUCCESS   │
│ (form fills)│
└──────┬──────┘
       │
       │ Auto-return
       │
       ▼
┌─────────────┐
│    IDLE     │
└─────────────┘
```

## Error Handling Flow

```
Error Scenarios:
│
├─► Permission Denied
│   └─► Show SnackBar: "Microphone permission denied"
│       └─► Return to IDLE state
│
├─► Speech Recognition Not Available
│   └─► Hide voice button (feature not shown)
│
├─► Recognition Error
│   └─► Show SnackBar: "Voice recognition error"
│       └─► Return to IDLE state
│
├─► No Speech Detected
│   └─► Timeout after 10 seconds
│       └─► Return to IDLE state
│
└─► Parsing Returns Empty
    └─► Form fields remain unchanged
        └─► User can try again or type manually
```

## Component Interaction Diagram

```
┌──────────────────────────────────────────────────────────────┐
│                  ExpenseFormComponent                         │
│                                                                │
│  ┌─────────────────────────────────────────────────────┐    │
│  │ Build Method                                         │    │
│  │ - _buildVoiceInputSection()                          │    │
│  │   • Shows VoiceInputButton                           │    │
│  │   • Only visible for new expenses                    │    │
│  │   • Hidden in edit mode                              │    │
│  └─────────────────────────┬────────────────────────────┘    │
│                             │                                  │
│                             │ callback                         │
│                             ▼                                  │
│  ┌─────────────────────────────────────────────────────┐    │
│  │ _handleVoiceInput(Map<String, dynamic> parsedData)   │    │
│  │ - setState(() { ... })                               │    │
│  │ - Update _amount, _nameController, _category         │    │
│  │ - Focus appropriate field                            │    │
│  │ - Show success feedback                              │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                                │
└──────────────────────────────────────────────────────────────┘
         │                                      ▲
         │ onVoiceResult                        │
         │ callback                             │ parsed data
         ▼                                      │
┌──────────────────────────────────────────────┴───────────────┐
│                  VoiceInputButton                             │
│                                                                │
│  - Manages button state (idle/listening/processing)           │
│  - Handles animation controller                               │
│  - Calls VoiceInputService.startListening()                   │
│  - Receives text result                                       │
│  - Calls VoiceInputService.parseExpenseFromText()             │
│  - Invokes onVoiceResult callback with parsed data            │
│                                                                │
└────────────────────────────┬───────────────────────────────────┘
                             │
                             │ uses
                             ▼
┌──────────────────────────────────────────────────────────────┐
│                  VoiceInputService                            │
│                                                                │
│  Instance Methods:                                             │
│  - isAvailable(): Future<bool>                                │
│  - startListening(...): Future<void>                          │
│  - stopListening(): Future<void>                              │
│                                                                │
│  Static Method:                                                │
│  - parseExpenseFromText(String): Map<String, dynamic>         │
│                                                                │
└────────────────────────────┬───────────────────────────────────┘
                             │
                             │ wraps
                             ▼
┌──────────────────────────────────────────────────────────────┐
│              speech_to_text Package                           │
│                                                                │
│  - SpeechToText class                                         │
│  - initialize()                                               │
│  - listen()                                                   │
│  - stop()                                                     │
│  - Wraps native platform code                                 │
│                                                                │
└──────────────────────────────────────────────────────────────┘
```

## Localization Flow

```
┌──────────────────────────────────────────────────────────────┐
│                User's Device Locale                           │
│                  (it_IT or en_US)                             │
└───────────────────────────┬───────────────────────────────────┘
                             │
                             ▼
┌──────────────────────────────────────────────────────────────┐
│              LocaleNotifier.of(context)                       │
│              Returns: 'it' or 'en'                            │
└───────────────────────────┬───────────────────────────────────┘
                             │
                             ├───────────────────┬───────────────┐
                             │                   │               │
                             ▼                   ▼               ▼
                  ┌──────────────────┐  ┌───────────────┐  ┌─────────────┐
                  │ VoiceInputButton │  │ ExpenseForm   │  │ Speech API  │
                  │ UI Strings       │  │ Hint Text     │  │ Locale ID   │
                  └──────────────────┘  └───────────────┘  └─────────────┘
                             │                   │               │
                             ▼                   ▼               ▼
                  ┌──────────────────┐  ┌───────────────┐  ┌─────────────┐
                  │ app_it.arb or    │  │ "Prova a dire"│  │ it_IT or    │
                  │ app_en.arb       │  │ "Try saying"  │  │ en_US       │
                  └──────────────────┘  └───────────────┘  └─────────────┘
```

## Parsing Algorithm - Detailed View

```
Input Text: "50 euro per cena al ristorante"
│
├─► Step 1: Extract Amount
│   │
│   ├─► Apply Regex: (\d+(?:[.,]\d{1,2})?)\s*(?:euro|eur|€|dollar|...)?
│   │   └─► Match found: "50 euro"
│   │
│   └─► Parse number: 50.0
│       Result: amount = 50.0
│
├─► Step 2: Extract Description
│   │
│   ├─► Look for Italian context: (?:per|di|a)\s+(.+?)(?:\s+al|\s+alla|...)
│   │   └─► Match found: "per cena"
│   │
│   ├─► Extract group: "cena"
│   │
│   ├─► Clean up: Remove amount text, normalize spaces
│   │   └─► "cena al ristorante"
│   │
│   └─► Result: name = "cena al ristorante"
│
└─► Step 3: Detect Category
    │
    ├─► Search for food keywords: ['cena', 'pranzo', 'ristorante', ...]
    │   └─► Found: "cena"
    │
    └─► Result: category = "food"

Final Output:
{
  "amount": 50.0,
  "name": "cena al ristorante",
  "category": "food"
}
```

## Permission Request Flow

```
Android:
│
├─► User taps voice button for first time
│
├─► Check permission: ContextCompat.checkSelfPermission()
│   │
│   ├─► GRANTED
│   │   └─► Continue to speech recognition
│   │
│   └─► DENIED
│       ├─► Show system permission dialog
│       │   │
│       │   ├─► User ALLOWS
│       │   │   └─► Continue to speech recognition
│       │   │
│       │   └─► User DENIES
│       │       └─► Show error message
│       │           └─► Return to idle state
│
iOS:
│
├─► User taps voice button for first time
│
├─► Check authorization: SFSpeechRecognizer.authorizationStatus()
│   │
│   ├─► .authorized
│   │   └─► Continue to speech recognition
│   │
│   ├─► .notDetermined
│   │   ├─► Request: SFSpeechRecognizer.requestAuthorization()
│   │   │   │
│   │   │   ├─► User ALLOWS
│   │   │   │   └─► Continue to speech recognition
│   │   │   │
│   │   │   └─► User DENIES
│   │   │       └─► Show error message
│   │   │           └─► Return to idle state
│   │
│   └─► .denied or .restricted
│       └─► Show error message with settings suggestion
│           └─► Hide voice button
```

## Testing Strategy

```
Unit Tests (voice_input_service_test.dart)
│
├─► Amount Parsing Tests
│   ├─► "50 euro" → 50.0 ✓
│   ├─► "25.50 dollars" → 25.50 ✓
│   ├─► "35,75 euro" → 35.75 ✓
│   └─► Edge cases ✓
│
├─► Description Extraction Tests
│   ├─► Italian: "per cena" ✓
│   ├─► English: "for dinner" ✓
│   └─► Complex phrases ✓
│
└─► Category Detection Tests
    ├─► Food keywords ✓
    ├─► Transport keywords ✓
    └─► Other categories ✓

Manual Testing Checklist
│
├─► Platform Testing
│   ├─► Android device
│   ├─► iOS device
│   └─► Different OS versions
│
├─► Functional Testing
│   ├─► Permission grant/deny
│   ├─► Voice recognition accuracy
│   ├─► Form field population
│   └─► Error handling
│
└─► User Experience Testing
    ├─► Animation smoothness
    ├─► Feedback clarity
    └─► Accessibility with screen readers
```
