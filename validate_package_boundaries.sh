#!/usr/bin/env bash
# Enforces the local-package dependency rules documented in
# docs/ARCHITECTURE.md ("Package dependency rules"), which today are only
# enforced by convention. A new hit here means a package started importing
# another local package it isn't allowed to depend on — fix the import (or,
# if the rule itself should change, update both this script and
# docs/ARCHITECTURE.md together).
#
# Usage: ./validate_package_boundaries.sh

set -uo pipefail
cd "$(dirname "$0")"

fail=0

# All five local packages, so an import of any of them is checked against
# the allow-list below, whichever package it's found in.
all_packages=(caravella_core caravella_core_ui android_app_functions play_store_updates google_drive_sync)

# package -> space-separated list of local packages it may import.
allowed_deps() {
  case "$1" in
    caravella_core) echo "" ;;
    caravella_core_ui) echo "caravella_core" ;;
    android_app_functions) echo "caravella_core" ;;
    play_store_updates) echo "caravella_core caravella_core_ui" ;;
    google_drive_sync) echo "caravella_core" ;;
    *) echo "" ;;
  esac
}

check_package() {
  local pkg="$1"
  local lib_dir="packages/$pkg/lib"
  [[ -d "$lib_dir" ]] || return 0

  local allowed
  allowed=" $(allowed_deps "$pkg") "

  local other
  for other in "${all_packages[@]}"; do
    [[ "$other" == "$pkg" ]] && continue
    if [[ "$allowed" == *" $other "* ]]; then
      continue
    fi

    local hits
    hits=$(grep -rn --include="*.dart" "package:$other/" "$lib_dir" 2>/dev/null)
    if [[ -n "$hits" ]]; then
      echo "FAIL: $pkg imports $other, which docs/ARCHITECTURE.md does not allow"
      echo "$hits" | sed 's/^/  /'
      fail=1
    fi
  done
}

echo "== Package boundary guards (see docs/ARCHITECTURE.md) =="
for pkg in "${all_packages[@]}"; do
  check_package "$pkg"
done

if [[ "$fail" -eq 0 ]]; then
  echo "OK: no local package imports outside docs/ARCHITECTURE.md's allow-list"
fi

exit $fail
