

# Caravella

Caravella è un'app Flutter moderna per la gestione di gruppi di spesa, viaggi e partecipanti, con persistenza locale e UX Material 3. Ideale per viaggi di gruppo, coinquilini, eventi o qualsiasi situazione in cui più persone condividono spese. Progettata per essere semplice, intuitiva, multi-piattaforma (Android/iOS/web/desktop) e facilmente estendibile.

## Funzionalità principali
- **Gestione gruppi di spesa**: crea gruppi (viaggi, coinquilini, eventi, ecc.), aggiungi partecipanti e gestisci tutte le spese condivise.
- **UI Material 3**: interfaccia moderna, flat, con card, colori dinamici e supporto dark/light mode.
- **Home page**: mostra il gruppo/viaggio corrente, totale speso e accesso rapido ai dettagli.
- **Storico gruppi/viaggi**: elenco di tutti i gruppi creati, con filtri, ordinamento e accesso ai dettagli.
- **Dettaglio gruppo/viaggio**: partecipanti, periodo, tutte le spese, azioni rapide (pinna, archivia, esporta CSV, elimina, modifica).
- **Aggiunta/modifica gruppo**: pagina dedicata per inserire/modificare dati, partecipanti e periodo.
- **Aggiunta/modifica spesa**: sheet per inserire categoria, importo, chi ha pagato e chi partecipa, direttamente dalla home o dal dettaglio.
- **Calcolo quote e riepilogo**: riepilogo delle quote per ogni partecipante e saldo finale del gruppo.
- **Backup e ripristino**: esporta e importa tutti i dati in formato ZIP/JSON, con conferma e feedback.
- **Persistenza dati**: tutti i dati sono salvati in locale su file JSON tramite `path_provider`.
- **Esportazione CSV**: esporta le spese di un gruppo/viaggio in CSV e condividi con `SharePlus`.
- **Icone personalizzate**: icona app generata da `assets/images/logo-w.png`.
- **Multi-tema e multi-lingua**: selettore tema (chiaro, scuro, automatico) e lingua (IT/EN) integrati nei settings.
- **Info e licenza**: sezione info con link, versione app, flavor, licenza e credits.

## Struttura del progetto
- `lib/` — codice sorgente principale (pagine, moduli, widgets, storage, stato)
- `assets/` — immagini, icone, font
- `pubspec.yaml` — configurazione dipendenze e asset
- `flutter_launcher_icons.yaml` — configurazione icone app
- `test/` — test widget/unitari

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
- Supporto a flavor (staging/prod) e build info tramite `package_info_plus`.

## Licenza
MIT

