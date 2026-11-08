#!/usr/bin/env bash
# Puts the prebuilt SQLite libraries the `sqlite3` package's build hook needs
# where the hook looks for them before downloading, so a bad download from
# GitHub's release CDN can't fail the build.
#
# The hook (sqlite3 >= 3.x, hook/build.dart) downloads
# libsqlite3.<abi>.<os>.so from the sqlite3.dart GitHub release into
# .dart_tool/hooks_runner/shared/sqlite3/build/download-<first 8 of sha256>/
# and reuses a file already there when its sha256 matches. It doesn't check
# the HTTP status: when the CDN answers with an error page, the hook saves the
# page and fails with "Hash of downloaded file ... expected ...". Here each
# file is fetched with retries until its hash matches, then copied into every
# package that resolves sqlite3 (its pubspec.lock). Without a match after
# all the retries, nothing is copied and the hook tries on its own.
#
# Run after `flutter pub get` in the root (the hash table comes from the
# package in the pub cache).
set -uo pipefail

# Linux x64 for `flutter test`, the Android ABIs for `flutter build`.
ASSETS=(
  libsqlite3.x64.linux.so
  libsqlite3.arm.android.so
  libsqlite3.arm64.android.so
  libsqlite3.x64.android.so
)
ATTEMPTS=12
DELAY=20

pub_cache="${PUB_CACHE:-$HOME/.pub-cache}"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

version_in() {
  awk '/^  sqlite3:/{f=1} f&&/version:/{gsub(/"/,"",$2);print $2;exit}' "$1"
}

sha256() { sha256sum "$1" | cut -d' ' -f1; }

# fetch <url> <expected sha256> <out>: retries until the hash matches.
fetch() {
  local url="$1" want="$2" out="$3" got i
  for ((i = 1; i <= ATTEMPTS; i++)); do
    if curl -fsSL --retry 3 --retry-all-errors -o "$out" "$url"; then
      got="$(sha256 "$out")"
      [ "$got" = "$want" ] && return 0
      echo "  attempt $i: sha256 $got, expected $want"
    else
      echo "  attempt $i: download failed"
    fi
    sleep "$DELAY"
  done
  return 1
}

dirs=()
for lock in pubspec.lock packages/*/pubspec.lock; do
  [ -f "$lock" ] && [ -n "$(version_in "$lock")" ] && dirs+=("$(dirname "$lock")")
done
[ ${#dirs[@]} -eq 0 ] && { echo "No package resolves sqlite3: nothing to do."; exit 0; }

for dir in "${dirs[@]}"; do
  version="$(version_in "$dir/pubspec.lock")"
  hashes="$pub_cache/hosted/pub.dev/sqlite3-$version/lib/src/hook/asset_hashes.dart"
  if [ ! -f "$hashes" ]; then
    echo "::warning::sqlite3 $version not in the pub cache ($hashes): skipping $dir"
    continue
  fi
  tag="$(sed -n "s/^const String? releaseTag = '\(.*\)';/\1/p" "$hashes")"
  for asset in "${ASSETS[@]}"; do
    want="$(sed -n "s/^  '$asset': '\([0-9a-f]*\)',/\1/p" "$hashes")"
    [ -z "$want" ] && { echo "::warning::no hash for $asset in sqlite3 $version"; continue; }
    file="$tmp/$want"
    # One download per file, shared by the packages ($want.ok / .failed).
    if [ ! -e "$file.ok" ] && [ ! -e "$file.failed" ]; then
      echo "Fetching $asset ($tag)"
      if fetch "https://github.com/simolus3/sqlite3.dart/releases/download/$tag/$asset" "$want" "$file"; then
        touch "$file.ok"
      else
        touch "$file.failed"
        echo "::warning::$asset: no good download after $ATTEMPTS attempts; the build hook will try itself"
      fi
    fi
    [ -e "$file.ok" ] || continue
    dest="$dir/.dart_tool/hooks_runner/shared/sqlite3/build/download-${want:0:8}"
    mkdir -p "$dest"
    cp "$file" "$dest/libsqlite3.so"
    echo "  -> $dest/libsqlite3.so"
  done
done
exit 0
