# Plan di miglioramento — `lib/sync/bluetooth_sync_channel.dart`

Rivisto insieme a `lib/sync/bluetooth_sync_sheet.dart` (unico consumer). Nessun test esistente per questo canale (`test/sync/` non contiene `bluetooth_sync_channel_test.dart`).

## P0 — Bug di correttezza

- [x] **Race condition nel completer di risposta** (`syncWithPeer`): il `Completer` viene ora registrato in `_pendingResponses` **prima** di chiamare `_sendPayload`, eliminando la finestra in cui una risposta troppo rapida del peer poteva essere scambiata per una nuova richiesta in ingresso.
- [x] **Completer non rimosso allo scadere del timeout**: `onTimeout` ora chiama `_pendingResponses.remove(endpointId)` esplicitamente.
- [x] **`stopAll()` non risolve i completer pendenti**: prima di `clear()`, ogni completer non ancora completato viene risolto con una mappa vuota, sbloccando eventuali `syncWithPeer` in attesa.
- [x] *(bonus, emerso implementando il fix sopra)* aggiunta pulizia di `_pendingResponses.remove(endpointId)` anche nel blocco `catch` di `syncWithPeer`, per evitare che un errore a metà flusso (es. `_sendPayload` che lancia) lasci un completer orfano in mappa.

## P1 — Robustezza

- [ ] **Permessi runtime mancanti**: nessun codice richiede `BLUETOOTH_SCAN` / `BLUETOOTH_ADVERTISE` / `BLUETOOTH_CONNECT` (Android 12+, API 31+) né sono dichiarati in `AndroidManifest.xml` (verificato: solo `ACCESS_FINE_LOCATION`/`ACCESS_COARSE_LOCATION` presenti). Su Android 12+ `startAdvertising`/`startDiscovery` falliranno silenziosamente (`started == false`, loggato come warning) senza che l'utente capisca perché — nella UI (`bluetooth_sync_sheet.dart`) questo si traduce in una ricerca che non trova mai nulla. Serve: dichiarare i permessi nel manifest, richiederli a runtime (es. via `permission_handler`) prima di `startAdvertising`/`startDiscovery`, e propagare un errore esplicito (`BtSyncError`) se negati.
- [ ] **`_onConnectionResult` ignora lo stato della connessione** (righe 365-370): logga soltanto, non distingue `CONNECTED` da `REJECTED`/`ERROR`. Se una connessione viene rifiutata durante `syncWithPeer`, il flusso continua comunque verso `_sendPayload`/attesa risposta invece di fallire subito con un errore chiaro.
- [ ] **Buffer chunk orfani**: se solo una parte dei chunk arriva (peer disconnesso a metà trasferimento), `_chunkBuffers[endpointId]` resta allocato finché non arriva `_onDisconnected` per lo stesso endpoint — non c'è timeout né limite di memoria per riassemblaggi mai completati.
- [ ] **`dispose()` non ferma il canale** (righe 342-344): chiude solo lo `StreamController`; non chiama `stopAll()`, quindi advertising/discovery Nearby possono restare attivi dopo che il widget/canale è stato "disposed".

## P1 — Sicurezza

- [ ] **Auto-accept incondizionato delle connessioni** (`_onConnectionInitiated`, righe 350-363): qualunque dispositivo che pubblicizzi lo stesso `serviceId` (`com.caravella.expensesync`, valore statico e pubblico nel codice sorgente) viene accettato automaticamente, senza verifica di `ConnectionInfo.authenticationDigits`/PIN o conferma utente. Valutare se mostrare un prompt di conferma con il codice di autenticazione prima di accettare, specialmente perché il canale scambia dati di spesa dell'utente.

## P2 — Test coverage

- [ ] Non esiste `test/sync/bluetooth_sync_channel_test.dart`. Aggiungere test unitari per:
  - `_ChunkHeader.toJson/fromJson` round-trip
  - logica di chunking/riassemblaggio in `_sendPayload`/`_handleChunk` (payload sopra/sotto i 32KB, chunk fuori ordine)
  - distinzione risposta-a-richiesta-nostra vs richiesta-in-ingresso in `_handleCompletePayload`
  - comportamento di `stopAll()` sui completer pendenti (una volta risolto il bug P0 corrispondente)

## P2 — Altro

- [ ] `BtSyncError.error` espone `e.toString()` direttamente in UI (via `bluetooth_sync_sheet.dart:289`) — valutare messaggi utente localizzati invece dello stack/eccezione grezza per errori comuni (permessi negati, timeout, connessione rifiutata).
- [ ] Timeout di sync fisso a 30s (riga 286) e `_maxChunkSize` a 32KB (riga 12) sono hardcoded: considerare se renderli configurabili se emergono casi con reti/payload più lenti o più grandi.
