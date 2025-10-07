# Voice Input UI Mockup

## Visual Layout Description

### Expense Form with Voice Input (Normal State)

```
┌─────────────────────────────────────────────────────────┐
│  in Viaggio a Roma                                      │  ← Group header
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌───┐  Prova a dire: '50 euro per cena al ristorante'│  ← Voice section
│  │ 🎤│  (gray hint text)                                │
│  └───┘                                                   │
│  ↑ Voice button (idle)                                  │
│                                                          │
│  ┌─────────────────────────────────────────────────┐   │
│  │ € __                                             │   │  ← Amount field
│  └─────────────────────────────────────────────────┘   │
│                                                          │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 📝 Descrizione                                   │   │  ← Name field
│  └─────────────────────────────────────────────────┘   │
│                                                          │
│  ┌───────────────┬─────────────────────────────────┐   │
│  │ 👤 Mario      │ 🏷️ Cibo                         │   │  ← Participant & Category
│  └───────────────┴─────────────────────────────────┘   │
│                                                          │
│  ┌────────┐                                             │
│  │ Salva  │                                             │  ← Action buttons
│  └────────┘                                             │
└─────────────────────────────────────────────────────────┘
```

### Voice Input - Listening State

```
┌─────────────────────────────────────────────────────────┐
│  in Viaggio a Roma                                      │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌───┐  In ascolto...                                  │  ← Voice section
│  │🎤 │  (blue pulsing animation)                        │     (active)
│  └───┘                                                   │
│  ↑ Pulsing microphone                                   │
│                                                          │
│  ┌─────────────────────────────────────────────────┐   │
│  │ € __                                             │   │
│  └─────────────────────────────────────────────────┘   │
│                                                          │
│  [Rest of form remains the same...]                     │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

### Voice Input - Processing State

```
┌─────────────────────────────────────────────────────────┐
│  in Viaggio a Roma                                      │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌───┐  Elaborazione...                                │  ← Voice section
│  │ ⟳ │  (spinner animation)                             │     (processing)
│  └───┘                                                   │
│                                                          │
│  ┌─────────────────────────────────────────────────┐   │
│  │ € __                                             │   │
│  └─────────────────────────────────────────────────┘   │
│                                                          │
│  [Rest of form remains the same...]                     │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

### After Voice Recognition - Form Filled

```
┌─────────────────────────────────────────────────────────┐
│  in Viaggio a Roma                                      │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌───┐  Prova a dire: '50 euro per cena al ristorante'│  ← Voice section
│  │ 🎤│                                                   │     (back to idle)
│  └───┘                                                   │
│                                                          │
│  ┌─────────────────────────────────────────────────┐   │
│  │ € 50.00                                          │   │  ← Auto-filled
│  └─────────────────────────────────────────────────┘   │
│  ✓ Valid                                                │
│                                                          │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 📝 cena al ristorante                           │   │  ← Auto-filled
│  └─────────────────────────────────────────────────┘   │
│                                                          │
│  ┌───────────────┬─────────────────────────────────┐   │
│  │ 👤 Mario      │ 🏷️ Cibo ✓                      │   │  ← Auto-selected
│  └───────────────┴─────────────────────────────────┘   │
│                                                          │
│  ┌────────┐                                             │
│  │ Salva  │ ← Now enabled                               │
│  └────────┘                                             │
│                                                          │
│  ╔════════════════════════════════════════════════╗    │
│  ║ ✓ Spesa aggiunta                               ║    │  ← Success message
│  ╚════════════════════════════════════════════════╝    │     (SnackBar)
└─────────────────────────────────────────────────────────┘
```

## Color Scheme & Visual Feedback

### Button States

#### Idle State
```
┌──────┐
│  🎤  │  ← Gray/neutral background
└──────┘     Black/dark icon
             No animation
```

#### Listening State
```
┌──────┐
│  🎤  │  ← Blue/primary background
└──────┘     White icon
   ↕️         Pulsing animation (opacity 0.5 to 1.0)
```

#### Processing State
```
┌──────┐
│  ⟳   │  ← Gray background
└──────┘     Spinner animation
             Button disabled
```

#### Error State
```
┌──────┐
│  🎤  │  ← Red/error background (briefly)
└──────┘     Then back to idle
```

## Animation Details

### Pulsing Animation (Listening)
```
Frame 0ms:   Opacity 0.5  ●○○○○
Frame 300ms: Opacity 0.7  ○●○○○
Frame 600ms: Opacity 0.9  ○○●○○
Frame 900ms: Opacity 1.0  ○○○●○
Frame 1200ms: Opacity 0.9 ○○○○●
Frame 1500ms: Opacity 0.5 ●○○○○
(Repeat)
```

### Spinner Animation (Processing)
```
Frame 0ms:   ⟳ (0°)
Frame 100ms: ⟳ (45°)
Frame 200ms: ⟳ (90°)
...
(Continuous rotation)
```

## Material 3 Design Integration

### Color Tokens Used
- **Idle**: `surfaceContainerHighest` background, `onSurfaceVariant` icon
- **Listening**: `primaryContainer` background, `onPrimaryContainer` icon
- **Error background**: `errorContainer.withAlpha(0.08)`
- **Hint text**: `onSurfaceVariant`

### Typography
- Hint text: `bodySmall`
- Success message: `bodyMedium`

### Spacing
- Button to hint text: 12dp
- Voice section bottom margin: 12dp
- Icon size: 24dp
- Button minimum size: 48x48dp (Material touch target)

## Responsive Behavior

### Small Screens (<360dp width)
```
┌────────────────────────────────┐
│ ┌─┐ Prova a dire...           │  ← Hint text truncates
│ └─┘ (truncated)                │
└────────────────────────────────┘
```

### Large Screens (>600dp width)
```
┌─────────────────────────────────────────────────┐
│ ┌───┐ Prova a dire: '50 euro per cena          │
│ └───┘ al ristorante'                           │  ← Full hint visible
└─────────────────────────────────────────────────┘
```

## Permission Dialog

### Android Permission Request
```
┌──────────────────────────────────────────────┐
│  Allow Caravella to record audio?            │
│                                               │
│  [🎤]                                         │
│                                               │
│  ┌──────────────┐  ┌──────────────┐         │
│  │   DENY       │  │   ALLOW      │         │
│  └──────────────┘  └──────────────┘         │
└──────────────────────────────────────────────┘
```

### iOS Permission Request
```
┌──────────────────────────────────────────────┐
│  "Caravella" Would Like to Access the        │
│  Microphone                                   │
│                                               │
│  This app needs access to microphone for     │
│  voice input of expenses.                    │
│                                               │
│  ┌─────────────────────────────────────┐    │
│  │         Don't Allow                  │    │
│  └─────────────────────────────────────┘    │
│  ┌─────────────────────────────────────┐    │
│  │         OK                           │    │
│  └─────────────────────────────────────┘    │
└──────────────────────────────────────────────┘
```

## Error Messages (SnackBar)

### Permission Denied
```
╔═══════════════════════════════════════════════╗
║ ⚠️ Permesso microfono negato                  ║
╚═══════════════════════════════════════════════╝
```

### Recognition Error
```
╔═══════════════════════════════════════════════╗
║ ⚠️ Errore nel riconoscimento vocale           ║
╚═══════════════════════════════════════════════╝
```

### Not Available
```
╔═══════════════════════════════════════════════╗
║ ⚠️ Riconoscimento vocale non disponibile      ║
╚═══════════════════════════════════════════════╝
```

## Accessibility

### Screen Reader Behavior

#### Button Label
- Default: "Inserisci con la voce" / "Add by voice"
- Listening: "In ascolto" / "Listening"
- Processing: "Elaborazione" / "Processing"

#### Semantic Tree
```
ExpenseFormComponent
├─ Heading: "in Viaggio a Roma"
├─ Button: "Inserisci con la voce"
│  └─ Tooltip: "Inserisci con la voce"
├─ TextField: "Importo"
├─ TextField: "Descrizione"
├─ Dropdown: "Pagato da"
├─ Dropdown: "Categoria"
└─ Button: "Salva"
```

### High Contrast Mode
- Button borders become more prominent
- Icon contrast increased
- Animation contrast enhanced

### Font Scaling
- Hint text scales with system font size
- Button size remains fixed for touch target
- Icon size scales proportionally up to 32dp max

## Dark Mode Variations

### Light Mode
```
Voice button:
- Idle: Light gray background (#F5F5F5)
- Listening: Light blue background (#E3F2FD)
- Icon: Dark gray (#424242)
```

### Dark Mode
```
Voice button:
- Idle: Dark gray background (#2C2C2C)
- Listening: Dark blue background (#1E3A5F)
- Icon: Light gray (#E0E0E0)
```

## Edge Cases UI

### No Categories Available
```
┌─────────────────────────────────────────────┐
│ Voice input works but category detection    │
│ is skipped (no categories to match)         │
└─────────────────────────────────────────────┘
```

### Edit Mode (Voice Button Hidden)
```
┌─────────────────────────────────────────────┐
│  in Viaggio a Roma                          │
├─────────────────────────────────────────────┤
│  [No voice button shown]                    │
│                                              │
│  ┌───────────────────────────────────────┐ │
│  │ € 50.00                                │ │ ← Editing existing
│  └───────────────────────────────────────┘ │
│  ...                                        │
└─────────────────────────────────────────────┘
```

### Speech Recognition Unavailable
```
┌─────────────────────────────────────────────┐
│  in Viaggio a Roma                          │
├─────────────────────────────────────────────┤
│  [Voice button not rendered at all]         │
│                                              │
│  ┌───────────────────────────────────────┐ │
│  │ € __                                   │ │
│  └───────────────────────────────────────┘ │
│  ...                                        │
└─────────────────────────────────────────────┘
```

## Interaction Flow Timeline

```
Time 0s:    User sees form with voice button
            ┌───┐
            │ 🎤│ [Gray, idle]
            └───┘

Time 0.1s:  User taps button
            ┌───┐
            │ 🎤│ [Ripple effect on tap]
            └───┘

Time 0.2s:  Permission check (if first time)
            [System dialog appears]

Time 0.5s:  Listening starts
            ┌───┐
            │🎤 │ [Blue, pulsing animation begins]
            └───┘
            "In ascolto..."

Time 3.0s:  User speaks: "cinquanta euro per cena"

Time 3.5s:  Recognition completes
            ┌───┐
            │ ⟳ │ [Spinner]
            └───┘
            "Elaborazione..."

Time 3.8s:  Parsing completes, fields update
            Form fields populate with values
            ┌───┐
            │ 🎤│ [Back to gray, idle]
            └───┘

Time 4.0s:  Success message appears
            ╔════════════════════════╗
            ║ ✓ Spesa aggiunta       ║
            ╚════════════════════════╝

Time 6.0s:  Success message fades out
            User can review and save
```

## Visual Hierarchy

### Information Priority
1. **Highest**: Amount field (most critical data)
2. **High**: Voice button (new feature, prominent)
3. **Medium**: Name/description field
4. **Medium**: Participant & Category
5. **Low**: Voice hint text
6. **Lowest**: Action buttons (standard position)

### Visual Weight
- Voice button: Medium size, colored when active
- Hint text: Small, gray, non-distracting
- Form fields: Standard Material 3 outlined style
- Success feedback: Prominent but temporary (SnackBar)
