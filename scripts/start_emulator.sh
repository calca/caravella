#!/usr/bin/env bash
# Auto-start first available Android emulator (or iOS Simulator) if no device is connected.
# Safe & quiet: never fails the build; exits 0.
set -euo pipefail

log() { echo "[auto-emulator] $*" >&2; }

# 1. Already a device? (android/emulator/ios/web) -> exit.
if flutter devices 2>/dev/null | grep -E '• (android|emulator|ios|chrome)' >/dev/null; then
  log "Device already connected. Skipping startup."
  exit 0
fi

# 2. Try to get first emulator id (prefer machine JSON, fallback to text parsing)
EMULATOR_ID=""
if flutter emulators --machine 2>/dev/null | sed -n 's/.*"id":"\([^"]*\)".*/\1/p' | head -n1 >/dev/null; then
  EMULATOR_ID=$(flutter emulators --machine 2>/dev/null | sed -n 's/.*"id":"\([^"]*\)".*/\1/p' | head -n1)
fi
if [ -z "$EMULATOR_ID" ]; then
  # Fallback parse: skip header line (exact 'Id') and blank lines
  EMULATOR_ID=$(flutter emulators 2>/dev/null | awk 'NF && $1 != "Id" && /•/ {print $1}' | head -n1 || true)
fi

if [ -n "$EMULATOR_ID" ] && [[ "$EMULATOR_ID" != "Id" && "$EMULATOR_ID" != "id" ]]; then
  log "Launching Android emulator: $EMULATOR_ID"
  # Launch in background (avoid blocking)
  (flutter emulators --launch "$EMULATOR_ID" >/dev/null 2>&1 || true &)
  # Wait up to 60s for a device to appear
  for i in $(seq 1 30); do
    if flutter devices 2>/dev/null | grep -E '• (android|emulator)' >/dev/null; then
      log "Android emulator ready."
      exit 0
    fi
    sleep 2
  done
  log "Timeout waiting for Android emulator. Proceeding anyway."
else
  log "No Android emulator id found."
fi

# 3. macOS fallback: open iOS Simulator if possible
if [[ "$(uname -s)" == "Darwin" ]]; then
  if command -v xcrun >/dev/null 2>&1; then
    if ! xcrun simctl list devices booted 2>/dev/null | grep -q Booted; then
      log "Opening iOS Simulator"
      open -a Simulator || true
      # Allow short boot period (do not block too long)
      sleep 5
    else
      log "iOS Simulator already booted."
    fi
  else
    log "xcrun not available; skipping iOS Simulator fallback."
  fi
fi

exit 0
