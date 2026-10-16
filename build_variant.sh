#!/usr/bin/env bash
# Build-time switch between the Play build and the F-Droid (FOSS) build.
#
# Everything that needs proprietary Google libraries (Play Services, ML Kit,
# Play Core) lives in packages/caravella_gms. packages/caravella_gms_foss is
# a package with the same name and API but no Google libraries; the FOSS
# variant points the app's `caravella_gms` dependency at it through
# pubspec_overrides.yaml, so none of those libraries are compiled into the
# APK (a dart-define could only hide them). See docs/BUILD_VARIANTS.md.
#
# Usage:
#   ./build_variant.sh            # print the current variant
#   ./build_variant.sh foss       # F-Droid: no Google libraries
#   ./build_variant.sh gms        # Play Store (default): everything
#   ./build_variant.sh check      # fail if the Android release classpath
#                                 # contains a proprietary Google artifact
#                                 # (meant for the foss variant)
#
# foss/gms run `flutter pub get` afterwards; pass --no-pub-get to skip it.

set -euo pipefail
cd "$(dirname "$0")"

OVERRIDES=pubspec_overrides.yaml
MARKER='# Written by build_variant.sh'
# Group IDs F-Droid's scanner rejects as non-free.
NONFREE='com\.google\.android\.gms|com\.google\.mlkit|com\.google\.firebase|com\.google\.android\.play|com\.google\.android\.datatransport|com\.google\.android\.odml'

current() {
  if [[ -f $OVERRIDES ]] && grep -q 'caravella_gms_foss' "$OVERRIDES"; then
    echo foss
  else
    echo gms
  fi
}

pub_get() {
  [[ ${1:-} == --no-pub-get ]] && return 0
  flutter pub get
}

case "${1:-}" in
  "")
    current
    ;;
  foss)
    if [[ -f $OVERRIDES ]] && ! grep -q "$MARKER" "$OVERRIDES"; then
      echo "error: $OVERRIDES exists and wasn't written by this script" >&2
      exit 1
    fi
    cat > "$OVERRIDES" <<YAML
$MARKER (foss variant) — delete it, or run
# ./build_variant.sh gms, to go back to the Play build.
dependency_overrides:
  caravella_gms:
    path: packages/caravella_gms_foss
YAML
    echo "Variant: foss (packages/caravella_gms_foss)"
    pub_get "${2:-}"
    ;;
  gms)
    if [[ -f $OVERRIDES ]]; then
      if ! grep -q "$MARKER" "$OVERRIDES"; then
        echo "error: $OVERRIDES wasn't written by this script; not touching it" >&2
        exit 1
      fi
      rm "$OVERRIDES"
    fi
    echo "Variant: gms (packages/caravella_gms)"
    pub_get "${2:-}"
    ;;
  check)
    echo "Variant: $(current) — scanning prodReleaseRuntimeClasspath…"
    deps=$(cd android && ./gradlew -q :app:dependencies --configuration prodReleaseRuntimeClasspath)
    hits=$(grep -oE "($NONFREE):[A-Za-z0-9._-]+" <<<"$deps" | sort -u || true)
    if [[ -n $hits ]]; then
      echo "Non-free Google artifacts on the classpath:" >&2
      echo "$hits" >&2
      exit 1
    fi
    echo "OK: no non-free Google artifacts."
    ;;
  *)
    echo "usage: $0 [foss|gms|check] [--no-pub-get]" >&2
    exit 2
    ;;
esac
