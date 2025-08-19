#!/usr/bin/env bash
# Robust auto-start for Android emulator (fallback to iOS Simulator on macOS) if no devices are attached.
# - Non-blocking failure: always exits 0
# - Waits until sys.boot_completed (or timeout) to avoid early flutter run failures
# - Override emulator/AVD via env var: CARAVELLA_AVD=<id|name>

set -u  # (avoid -e to not abort on transient tool errors)

log() { echo "[auto-emulator] $*" >&2; }
debug() { [ "${AUTO_EMU_DEBUG:-0}" = 1 ] && log "DEBUG: $*"; }

BOOT_TIMEOUT_SEC=${BOOT_TIMEOUT_SEC:-90}
SLEEP_INTERVAL=3

# 1. Skip if a usable device is already connected
if flutter devices 2>/dev/null | grep -E '• (android|emulator|ios)' >/dev/null; then
  log "Device already present. Skip."
  exit 0
fi

# 2. Determine emulator id
EMULATOR_ID="${CARAVELLA_AVD:-}"  # user override
if [ -z "$EMULATOR_ID" ]; then
  # Try JSON machine output
  json_ids=$(flutter emulators --machine 2>/dev/null | sed -n 's/.*"id":"\([^"]*\)".*/\1/p' || true)
  for cid in $json_ids; do
    if [ "$cid" != "id" ]; then EMULATOR_ID=$cid; break; fi
  done
fi
if [ -z "$EMULATOR_ID" ]; then
  # Fallback table parse (skip header 'Id')
  EMULATOR_ID=$(flutter emulators 2>/dev/null | awk 'NF && $1 != "Id" && /android/ {print $1}' | head -n1 || true)
fi

if [ -z "$EMULATOR_ID" ]; then
  log "Nessun emulatore Android trovato (flutter emulators vuoto)."
else
  log "Avvio emulatore Android: $EMULATOR_ID"
  # Launch (do not background the parent shell; we detach with nohup)
  (nohup flutter emulators --launch "$EMULATOR_ID" >/dev/null 2>&1 &)
  # Ensure adb server is up
  adb start-server >/dev/null 2>&1 || true
  # Wait for any emulator device line
  waited=0
  while [ $waited -lt $BOOT_TIMEOUT_SEC ]; do
    if flutter devices 2>/dev/null | grep -E '• (android|emulator)' >/dev/null; then
      debug "Device entry visible after ${waited}s"
      break
    fi
    sleep $SLEEP_INTERVAL; waited=$((waited + SLEEP_INTERVAL))
  done
  if [ $waited -ge $BOOT_TIMEOUT_SEC ]; then
    log "Timeout (${BOOT_TIMEOUT_SEC}s) senza device visibile. Procedo comunque."
  else
    # Wait boot_completed property
    waited_boot=0
    while [ $waited_boot -lt $BOOT_TIMEOUT_SEC ]; do
      boot_prop=$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r') || true
      if [ "$boot_prop" = "1" ]; then
        log "Emulatore pronto (boot_completed)."
        break
      fi
      sleep $SLEEP_INTERVAL; waited_boot=$((waited_boot + SLEEP_INTERVAL))
    done
    [ $waited_boot -ge $BOOT_TIMEOUT_SEC ] && log "Timeout attesa boot_completed (procedo)."
  fi
fi

# 3. macOS fallback (solo se ancora nessun device dopo Android attempt)
if flutter devices 2>/dev/null | grep -E '• (android|emulator|ios)' >/dev/null; then
  exit 0
fi
if [[ "$(uname -s)" == "Darwin" ]]; then
  if command -v xcrun >/dev/null 2>&1; then
    if ! xcrun simctl list devices booted 2>/dev/null | grep -q Booted; then
      log "Apro iOS Simulator (fallback)"
      open -a Simulator || true
    else
      debug "iOS Simulator già avviato"
    fi
  else
    debug "xcrun non disponibile; salto fallback iOS"
  fi
fi

exit 0
