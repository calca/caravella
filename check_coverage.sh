#!/usr/bin/env bash
# Fails when the line coverage in an lcov report drops below a floor.
#
#   ./check_coverage.sh <lcov.info> <minimum %> [exclude regex]
#
# Files whose path matches the exclude regex (e.g. generated localizations)
# don't count. Used by CI after `flutter test --coverage`, for the app and
# for the packages with a floor; raise a floor when coverage has grown.
set -euo pipefail

report="${1:?lcov report}"
minimum="${2:?minimum percent}"
exclude="${3:-^$}"

awk -v min="$minimum" -v ex="$exclude" '
  /^SF:/ { skip = (substr($0, 4) ~ ex) }
  /^LF:/ && !skip { found += substr($0, 4) }
  /^LH:/ && !skip { hit += substr($0, 4) }
  END {
    if (found == 0) { print "No lines in the report"; exit 1 }
    pct = 100 * hit / found
    printf "Line coverage: %.1f%% (%d of %d lines), floor %s%%\n", pct, hit, found, min
    if (pct < min) { print "Coverage is below the floor"; exit 1 }
  }
' "$report"
