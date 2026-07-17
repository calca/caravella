#!/usr/bin/env bash
# Accessibility regression checks for Caravella.
#
# Two kinds of checks:
#  1. Hard failures — patterns that should stay at zero occurrences because a
#     compliant alternative already exists in the design system. A new hit
#     here is a regression, not pre-existing debt.
#  2. Debt report — non-fatal counts of known gaps tracked in
#     PLAN_DESIGN_SYSTEM.TODO.MD, so progress is visible without blocking CI
#     until each item is actually fixed.
#
# Usage: ./validate_accessibility.sh [--skip-tests]

set -uo pipefail
cd "$(dirname "$0")"

skip_tests=false
[[ "${1:-}" == "--skip-tests" ]] && skip_tests=true

fail=0

if [[ "$skip_tests" == false ]]; then
  echo "== Accessibility & localization tests =="
  flutter test test/accessibility_test.dart test/accessibility_localization_test.dart
  if [[ $? -ne 0 ]]; then
    fail=1
  fi
  echo
fi

echo "== Regression guards (must stay at zero) =="

check_zero() {
  local desc="$1" pattern="$2" path="$3"
  local hits
  hits=$(grep -rn --include="*.dart" "$pattern" "$path" 2>/dev/null | grep -v '_test\.dart')
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

check_zero "ScaffoldMessenger.showSnackBar usato direttamente invece di AppToast" \
  'ScaffoldMessenger\.of(context)\.showSnackBar' "lib"

check_zero "AlertDialog raw invece di Material3Dialog" \
  'AlertDialog(' "lib"

echo
echo "== Debito noto (report, non bloccante — vedi PLAN_DESIGN_SYSTEM.TODO.MD) =="

report_count() {
  local desc="$1" pattern="$2" path="$3"
  local count
  count=$(grep -rl --include="*.dart" "$pattern" "$path" 2>/dev/null | wc -l | tr -d ' ')
  echo "  - $desc: $count file"
}

report_count "IconButton( presenti" 'IconButton(' "lib"
report_count "TextField/TextFormField con hintText (verificare presenza labelText)" 'hintText:' "lib"
report_count "FocusTraversalGroup in uso" 'FocusTraversalGroup' "lib"
report_count "MergeSemantics in uso" 'MergeSemantics' "lib packages/caravella_core_ui/lib"

echo
if [[ "$fail" -ne 0 ]]; then
  echo "Accessibility check FAILED."
  exit 1
fi

echo "Accessibility check passed."
