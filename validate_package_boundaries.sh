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

# All local packages (by directory), so an import of any of them is checked
# against the allow-list below, whichever package it's found in.
# packages/caravella_gms_foss is published as `caravella_gms` too (the
# F-Droid stand-in), so it's never imported under its directory name.
all_packages=(caravella_core caravella_core_ui android_app_functions play_store_updates google_drive_sync caravella_gms caravella_gms_foss)

# package -> space-separated list of local packages it may import.
allowed_deps() {
  case "$1" in
    caravella_core) echo "" ;;
    caravella_core_ui) echo "caravella_core" ;;
    android_app_functions) echo "caravella_core" ;;
    play_store_updates) echo "caravella_core caravella_core_ui" ;;
    google_drive_sync) echo "caravella_core" ;;
    caravella_gms) echo "caravella_core google_drive_sync play_store_updates" ;;
    caravella_gms_foss) echo "caravella_core" ;;
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

# Proprietary Google libraries (and the packages wrapping them) may only be
# used inside packages/caravella_gms and the packages it depends on —
# anywhere else they'd end up in the F-Droid build, which swaps
# caravella_gms for caravella_gms_foss (see docs/PACKAGE_CARAVELLA_GMS.md).
nonfree='geolocator|google_mlkit_[a-z_]+|in_app_review|in_app_update|mobile_scanner|nearby_connections|google_sign_in|google_drive_sync|play_store_updates'
echo "== Proprietary libraries only via caravella_gms =="
hits=$(grep -rnE --include="*.dart" "package:($nonfree)/" lib test \
  packages/caravella_core/lib packages/caravella_core_ui/lib \
  packages/android_app_functions/lib packages/caravella_gms_foss 2>/dev/null)
if [[ -n "$hits" ]]; then
  echo "FAIL: proprietary library imported outside packages/caravella_gms"
  echo "$hits" | sed 's/^/  /'
  fail=1
fi
for pubspec in pubspec.yaml packages/caravella_core/pubspec.yaml \
  packages/caravella_core_ui/pubspec.yaml \
  packages/android_app_functions/pubspec.yaml \
  packages/caravella_gms_foss/pubspec.yaml; do
  dep_hits=$(grep -nE "^  ($nonfree):" "$pubspec")
  if [[ -n "$dep_hits" ]]; then
    echo "FAIL: $pubspec depends on a proprietary library directly"
    echo "$dep_hits" | sed 's/^/  /'
    fail=1
  fi
done

if [[ "$fail" -eq 0 ]]; then
  echo "OK: no local package imports outside docs/ARCHITECTURE.md's allow-list"
  echo "OK: proprietary libraries only used through caravella_gms"
fi

exit $fail
