# Caravella

Caravella è un'app Flutter per la gestione di viaggi, spese e partecipanti, con persistenza locale su file JSON. Progettata per essere semplice, intuitiva e multi-piattaforma (Android/iOS).

## Funzionalità principali
- **Home page**: mostra il viaggio corrente con totale speso e accesso rapido al dettaglio.
- **Storico viaggi**: elenco di tutti i viaggi salvati, con accesso ai dettagli.
- **Dettaglio viaggio**: visualizza partecipanti, periodo e tutte le spese del viaggio.
- **Aggiunta/modifica viaggio**: pagina dedicata per inserire o modificare dati, partecipanti e periodo.
- **Aggiunta spesa**: sheet per inserire categoria, importo e chi ha pagato, direttamente dalla home o dal dettaglio.
- **Persistenza dati**: tutti i dati sono salvati in locale su file JSON tramite `path_provider`.
- **Icone personalizzate**: icona app generata da `assets/images/logo-w.png` con background azzurro.

## Struttura del progetto
- `lib/` — codice sorgente principale (pagine, modelli, storage)
- `assets/images/` — immagini e icone
- `pubspec.yaml` — configurazione dipendenze e asset
- `flutter_launcher_icons.yaml` — configurazione icone app

## Avvio rapido
1. **Installazione dipendenze**
   ```sh
   flutter pub get
   ```
2. **Generazione icone**
   ```sh
   flutter pub run flutter_launcher_icons:main -f flutter_launcher_icons.yaml
   ```
3. **Avvio su emulatore/dispositivo**
   ```sh
   flutter run
   ```

## Build e debug
- Usa le configurazioni VS Code in `.vscode/launch.json` per debug rapido su Android/iOS.
- Hot reload e hot restart supportati.

## Licenza
MIT

