# F-Droid Submission Guide

F-Droid is a community-maintained FOSS Android app catalog. This page covers what's specific to Caravella's F-Droid packaging; for the general submission process see F-Droid's own docs (linked at the bottom).

**Note on version numbers**: this page intentionally avoids hardcoding the current app version or F-Droid version code — those live in `pubspec.yaml` (`version:`) and `metadata.yml` (`CurrentVersion`/`CurrentVersionCode`, `Builds:`) respectively, and go stale immediately if duplicated here. Before an F-Droid submission or update, always diff those two files against each other rather than trusting a number written in this doc.

## Build configuration

F-Droid builds the **`prod`** flavor, without `ENABLE_PLAY_UPDATES` (so `play_store_updates`'s factory falls back to the no-op implementation — see [Build Variants & Flavors](BUILD_VARIANTS.md) and [play_store_updates package](PACKAGE_PLAY_STORE_UPDATES.md)):

```bash
flutter build apk --flavor prod --release --dart-define=FLAVOR=prod
```

Cross-check the exact build stanza (including any `--dart-define=ENABLE_ANDROID_WIDGET=...`) against `metadata.yml`'s `Builds:` section directly — do not rely on the command shown above being current if `metadata.yml` has since changed.

Package name: `io.caravella.egm`. F-Droid signs the APK with its own key — the repo's release keystore is not used for F-Droid builds.

## Metadata locations

- `metadata.yml` (repo root) — F-Droid app metadata: categories, license, links, anti-features, `AutoUpdateMode: Version` / `UpdateCheckMode: Tags` (F-Droid picks up new versions from GitHub release tags in `vX.Y.Z` format).
- `fastlane/metadata/android/<locale>/` — per-locale store listing (`title.txt`, `short_description.txt`, `full_description.txt`, `changelogs/<versionCode>.txt`, `images/`). As of the last documentation pass, **not every locale directory has a full listing** — some only have `changelogs/` without `title`/`description`/`images`. Check `fastlane/metadata/android/` directly for the current locale coverage rather than trusting a list here; add the missing files for any locale you want fully represented on F-Droid before a submission review.

## Keeping `metadata.yml` in sync

`metadata.yml`'s version fields drift independently from `pubspec.yaml` and from the actual release process (CI auto-bumps `pubspec.yaml` on every published release — see [CI Pipelines](CI_PIPELINES.md) — but does not touch `metadata.yml`). Whenever you cut a release intended for F-Droid:

1. Confirm `pubspec.yaml`'s `version:` matches the GitHub release tag.
2. Update `metadata.yml`'s `CurrentVersion`/`CurrentVersionCode` and add a new `Builds:` entry if the build recipe changed.
3. Add the matching `fastlane/metadata/android/<locale>/changelogs/<versionCode>.txt` file(s).

## Dependency / anti-feature review points

F-Droid requires no non-free dependencies and no non-free network services. Two things in the current dependency set are worth re-checking against F-Droid's policy at submission time rather than assuming they're fine:

- **`google_mlkit_text_recognition`** (receipt OCR — see [Receipt OCR](RECEIPT_OCR.md)) bundles Google ML Kit. Confirm current F-Droid inclusion policy on ML Kit before submitting/updating.
- **`UNSPLASH_ACCESS_KEY`** (background photo search — see [Group Management § photo/background flow](APP_GROUP_MANAGEMENT.md#photobackground-flow)) is a keyed third-party network service. It degrades gracefully to "feature unavailable" with no key set, but if a key is baked into F-Droid's reproducible build it becomes a non-free network dependency; if not, the feature is simply absent from F-Droid builds. Decide and document which is intended before submission.

For everything else, verify licenses against `pubspec.yaml`/`pubspec.lock` directly (pub.dev shows each package's license) rather than trusting a hardcoded table — the dependency set changes often enough that a static table here would go stale within a few releases.

## Permissions

Camera and location are declared `android:required="false"` in `AndroidManifest.xml` — the app is fully usable with both denied. Storage permission is only needed pre-Android-13 (modern versions use the system Photo Picker, no permission required).

## Reproducible builds

- `pubspec.lock` is committed — dependency versions are pinned.
- No build timestamps are embedded; version comes from `pubspec.yaml` only.
- Confirm the Flutter version F-Droid's build server uses matches (or is compatible with) the version pinned in CI — see [CI Pipelines](CI_PIPELINES.md) for CI's current pin, and re-check this at submission time since both drift independently.

## External resources

- F-Droid docs: https://f-droid.org/docs/
- Metadata reference: https://f-droid.org/docs/Build_Metadata_Reference/
- Inclusion policy: https://f-droid.org/docs/Inclusion_Policy/
- Request for Packaging (first submission): https://gitlab.com/fdroid/rfp/-/issues

## See also

- [Build Variants & Flavors](BUILD_VARIANTS.md)
- [CI Pipelines](CI_PIPELINES.md)
- [play_store_updates package](PACKAGE_PLAY_STORE_UPDATES.md)
