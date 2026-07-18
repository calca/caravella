#!/usr/bin/env bash
# Design-token regression checks for Caravella (see plan.todo.ds.md).
#
# Two kinds of checks, mirroring validate_accessibility.sh:
#  1. Hard failures — patterns that should stay at zero occurrences in lib/
#     because a token now exists in caravella_core_ui (AppTypography,
#     AppTextStyles, AppSpacing, AppRadius). A new hit here is a regression
#     of design-system debt that was already paid down, not pre-existing
#     debt.
#  2. Debt report — non-fatal counts of raw design values still hardcoded in
#     lib/, so drift is visible without blocking CI until they're actually
#     audited (see plan.todo.ds.md Fase 4 for why these aren't hard-zero
#     checks: font size/weight, spacing and radius numbers are legitimately
#     reused for one-off decorative purposes too, not just debt).
#
# Usage: ./validate_design_tokens.sh

set -uo pipefail
cd "$(dirname "$0")"

fail=0

echo "== Regression guards (must stay at zero) =="

check_zero() {
  local desc="$1" pattern="$2" path="$3"
  local hits
  hits=$(grep -rn --include="*.dart" -E "$pattern" "$path" 2>/dev/null | grep -v '_test\.dart')
  local count=0
  if [[ -n "$hits" ]]; then
    count=$(echo "$hits" | wc -l | tr -d ' ')
  fi
  if [[ "$count" -gt 0 ]]; then
    echo "FAIL: $desc ($count occorrenze)"
    echo "$hits" | sed 's/^/  /'
    fail=1
  else
    echo "OK: $desc"
  fi
}

check_zero "TextStyle(color: Colors.white54, fontSize: 16) invece di AppTextStyles.mediaOverlayMessage" \
  'TextStyle\(color: Colors\.white54, fontSize: 16\)' "lib"

check_zero "TextStyle(color: Colors.white54, fontSize: 14) invece di AppTextStyles.mediaOverlayCaption" \
  'TextStyle\(color: Colors\.white54, fontSize: 14\)' "lib"

check_zero "TextStyle(fontSize: 72) invece di AppTextStyles.emojiDisplay" \
  'TextStyle\(fontSize: 72\)' "lib"

check_zero "'Montserrat' hardcoded fuori da AppTypography.fontFamily" \
  "'Montserrat'" "lib packages/caravella_core_ui/lib/widgets"

echo
echo "== Debito noto (report, non bloccante — vedi plan.todo.ds.md) =="

report_count() {
  local desc="$1" pattern="$2"
  shift 2
  local count
  count=$(grep -rhoE --include="*.dart" "$pattern" "$@" 2>/dev/null | wc -l | tr -d ' ')
  echo "  - $desc: $count occorrenze"
}

report_count "fontSize: diretto" 'fontSize: *[0-9]+' lib
report_count "fontWeight: diretto" 'fontWeight: *FontWeight\.[a-zA-Z0-9]+' lib
report_count "TextStyle( istanziato direttamente" 'TextStyle\(' lib
report_count "EdgeInsets.* diretto" 'EdgeInsets\.[a-zA-Z]+\(' lib
report_count "BorderRadius.circular(...) diretto" 'BorderRadius\.circular\([0-9.]+\)' lib

echo
if [[ "$fail" -ne 0 ]]; then
  echo "Design token check FAILED."
  exit 1
fi

echo "Design token check passed."
