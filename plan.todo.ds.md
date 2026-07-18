# Piano: Vero Design System — Token UI centralizzati in `caravella_core_ui`

Continuazione di `PLAN_DESIGN_SYSTEM.TODO.MD` (completato: componenti condivisi, empty state, colori semantici, accessibilità WCAG 2.2). Quel piano ha fatto l'audit *esatto* solo sui duplicati byte-identici di `AppTextStyles` (Fase 3.1). Questo piano affronta il resto: oggi `caravella_core_ui` definisce colori e touch target, ma **non** una vera scala tipografica, di spaziatura o di raggi — font size, font weight, padding e border radius restano in gran parte valori "magici" scritti a mano dentro `lib/`.

Obiettivo: che nessun file in `lib/` debba mai scrivere un numero di design a mano (fontSize, fontWeight, EdgeInsets, BorderRadius) — solo referenziare token esposti da `caravella_core_ui`.

Numeri di base (grep esatto, luglio 2026 — da riverificare a inizio di ogni fase, il codice si muove):
- `fontSize:` diretto in `lib/`: **45** occorrenze
- `fontWeight:` diretto in `lib/`: **41** occorrenze
- `TextStyle(` istanziato direttamente in `lib/`: **22** occorrenze
- `EdgeInsets.*` diretto in `lib/`: **230** occorrenze
- `BorderRadius.circular(...)` diretto in `lib/`: **59** occorrenze
- `'Montserrat'` hardcoded **due volte** nello stesso file (`caravella_themes.dart:202` e `:235`), invece di una costante unica

Non tutti questi numeri sono debito: molti sono valori decorativi legittimi e unici (es. emoji a 72px nel wizard). Ogni fase qui sotto parte da un audit che separa i duplicati reali (debito) dai one-off (non debito) — niente find-replace di massa senza aver prima classificato ogni occorrenza, sul modello dell'audit "match esatto" già fatto in Fase 3.1 del piano precedente.

---

## Fase 0 — Fondamenta

- [ ] **Deduplicare `'Montserrat'`**: introdurre `AppTypography.fontFamily` (o costante equivalente) in `caravella_core_ui/lib/themes/`, e far riferire sia `_createTextTheme` che `_createThemeData` (`caravella_themes.dart:202,235`) a quell'unica costante. Zero cambi visivi, solo single source of truth.
- [ ] **Audit esatto** dei 45 `fontSize:` + 41 `fontWeight:` + 22 `TextStyle(` in `lib/`: per ciascuno, verificare se è un duplicato (stesso valore/pattern ripetuto altrove) o un one-off decorativo. Pattern già individuati come probabili duplicati da consolidare:
  - `TextStyle(color: Colors.white54/white70, fontSize: 14/16/18)` ripetuto identico in 5 file dei media viewer (`attachment_viewer_page.dart`, `image_viewer_page.dart`, `pdf_viewer_page.dart`, `video_player_page.dart`).
  - `TextStyle(fontSize: 72)` per l'emoji selezionata, ripetuto in 3 step del wizard (`wizard_user_name_step.dart`, `wizard_type_and_name_step.dart`, `wizard_completion_step.dart`).
  - Verificare se altri pattern emergono dall'audit esatto (script grep/perl come in Fase 3.1 del piano precedente, non un'euristica).

---

## Fase 1 — Scala tipografica come vero design system

- [ ] Estendere `app_text_styles.dart` (oggi solo 4 helper: `sectionTitle`, `listItem`, `listItemStrong`, `subtle`) con gli helper emersi dall'audit di Fase 0 — es. `AppTextStyles.mediaOverlayPrimary/secondary(context)` per il pattern white54/white70, `AppTextStyles.emojiDisplay` per il pattern 72px.
- [ ] Migrare solo i call site duplicati identificati in Fase 0 sui nuovi helper. I one-off restano `TextStyle(...)` locali — non è debito, forzarli in helper condivisi userebbe un'API "kitchen sink" senza reale riuso (stesso principio già applicato in Fase 1/2 del piano precedente per gli empty state).
- [ ] Verificare `flutter analyze` pulito + diff visivo nullo sui file toccati.

---

## Fase 2 — Scala di spaziatura (`AppSpacing`)

- [ ] Oggi zero token di spacing condivisi: 230 `EdgeInsets.*` scritti a mano in `lib/`. Fare un istogramma dei valori più frequenti (grep + conteggio) per dedurre la scala realmente in uso nell'app (tipicamente multipli di 4/8: 4, 8, 12, 16, 24, 32...) invece di inventarne una teorica.
- [ ] Introdurre `AppSpacing` in `packages/caravella_core_ui/lib/themes/app_spacing.dart` (xs/sm/md/lg/xl) con i valori dell'istogramma, esportato dal barrel.
- [ ] Migrazione **incrementale e mirata**, non un find-replace sui 230 siti: iniziare dai container più riusati e ad alto traffico — `BaseCard`, `SettingsCard`/`SettingsSection`, i form field via `form_theme.dart` — dove un valore sbagliato ha il blast radius più alto se resta incoerente. I 230 siti restanti restano fuori scope finché non c'è evidenza che valga il rischio di regressione visiva.

---

## Fase 3 — Scala dei raggi (`AppRadius`)

- [ ] 59 `BorderRadius.circular(...)` diretti in `lib/`, nessuna costante condivisa (es. dialog usa 28 hardcoded in `caravella_themes.dart`, `BaseCard` ha un suo raggio proprio). Fare audit dei valori distinti realmente in uso prima di decidere la scala — se sono già in pratica 2-3 "sapori" coerenti, la scala li rispecchia; se sono sparsi e incoerenti, decidere i canonici richiede un confronto visivo caso per caso (come già fatto per l'alpha bordo 0.2→0.12 in Fase 2.2 del piano precedente).
- [ ] Introdurre `AppRadius` (es. `sm`/`md`/`lg`/`pill`) in `caravella_core_ui`, esportato dal barrel.
- [ ] Migrare `caravella_themes.dart` (dialog radius) e i componenti condivisi (`BaseCard`, bottom sheet, dialog) per primi — sono la superficie che definisce il "linguaggio visivo" dell'app, il resto di `lib/` segue solo se emergono duplicati chiari nell'audit.

---

## Fase 4 — Altri token UI sparsi

- [ ] Audit mirato (non esplorativo a tappeto) su altre categorie che tipicamente finiscono per essere reinventate ad-hoc: icon size, elevation, durate/curve di animazione (`Duration(milliseconds: ...)` ricorrenti), valori di opacità/alpha oltre a `success`/`warning` già coperti. Solo per le categorie dove l'audit trova ≥3 duplicati identici vale la pena di un token — altrimenti non è debito, è varietà legittima.
- [ ] Per ogni categoria promossa: stesso criterio delle fasi precedenti — token in `caravella_core_ui`, migrazione mirata ai duplicati reali, non un refactor totale di `lib/`.

---

## Fase 5 — Prevenire la regressione

- [ ] Estendere `validate_accessibility.sh` (o creare uno script gemello, es. `validate_design_tokens.sh`, seguendo lo stesso pattern "conta il debito noto, fallisci solo se supera la baseline registrata qui") per segnalare nuovi `fontSize:`/`TextStyle(`/`BorderRadius.circular(`/`EdgeInsets.*` hardcoded introdotti fuori da `caravella_core_ui` dopo questa migrazione.
- [ ] Collegare lo script alla CI (`.github/workflows/Development - Android.yml`), come già fatto per `validate_accessibility.sh` in Fase 4.7 del piano precedente.
- [ ] Aggiornare `docs/PACKAGE_CARAVELLA_CORE_UI.md` e `.github/copilot-instructions.md` con i nuovi token (`AppTypography`, `AppSpacing`, `AppRadius`, eventuali altri da Fase 4) e le linee guida su quando usarli.

---

## Note di scope

- Nessuna modifica di codice è stata fatta finora — questo è solo il piano.
- Ogni fase è pensata per essere eseguita ed eventualmente accettata/scartata indipendentemente dalle altre (come il piano precedente), non serve completarle in ordine rigido, ma Fase 0 va fatta per prima perché alimenta gli audit delle fasi successive.
- Dove l'audit non trova duplicati reali (solo one-off legittimi), la fase si chiude con "nessuna azione" documentata — non forzare token per il gusto di avere una scala completa.
