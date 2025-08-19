#!/usr/bin/env bash
# Auto-start first available Android emulator (or iOS Simulator on macOS) if none is running before Flutter launch.
set -euo pipefail

# If at least one device (physical or emulator) is connected, exit.
if flutter devices 2>/dev/null | grep -E '• (android|emulator|chrome|ios)' >/dev/null; then
  exit 0
fi

# Try Android emulator first
EMULATOR_ID=$(flutter emulators 2>/dev/null | awk '/•/ {print $1; exit}')
if [ -n "${EMULATOR_ID}" ]; then
  echo "[auto-emulator] Launching Android emulator: ${EMULATOR_ID}" >&2
  (flutter emulators --launch "${EMULATOR_ID}" >/dev/null 2>&1 &)
  # Wait up to ~60s for a device to appear
  for i in {1..30}; do
    if flutter devices 2>/dev/null | grep -E '• (android|emulator)' >/dev/null; then
      echo "[auto-emulator] Android emulator ready" >&2
      exit 0
    fi
    sleep 2
  done
fi

# Fallback: on macOS try opening iOS Simulator
if [[ "$(uname -s)" == "Darwin" ]]; then
  if ! xcrun simctl list devices booted | grep -q Booted; then
    echo "[auto-emulator] Opening iOS Simulator" >&2
    open -a Simulator || true
    # wait a little for it to boot
    sleep 5
  fi
fi

exit 0
