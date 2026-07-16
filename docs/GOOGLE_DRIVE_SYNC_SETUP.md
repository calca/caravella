# Google Drive Sync — Setup Guide

Step-by-step instructions for configuring the Google Cloud OAuth client(s) that back the **optional** Google Drive cloud relay (see [package reference](PACKAGE_GOOGLE_DRIVE_SYNC.md) for how the code fits together, [Build Variants & Flavors](BUILD_VARIANTS.md) for the `ENABLE_GOOGLE_DRIVE_SYNC` flag).

This is a **build-time opt-in feature**. Without following this guide, the app builds and runs exactly as before — the Cloud Sync section stays hidden and no Google code runs. You only need this if you want to enable and test the real Google Drive channel yourself.

## What you're setting up, and why

`google_drive_sync` (`packages/google_drive_sync`) uses Google Sign-In to get an OAuth token, then calls the Drive API to store one JSON "shard" per paired device in the user's own Drive `appDataFolder` — a hidden, per-app space invisible in the user's normal Drive UI and unreachable by other apps. Nothing is uploaded to any server you run; storage is entirely inside the *user's own* Google account. See [caravella_core § CloudRelayChannel](PACKAGE_CARAVELLA_CORE.md) for the interface this implements.

To make sign-in work you need, in a Google Cloud project you control:
1. The **Drive API** enabled.
2. An **OAuth consent screen** configured.
3. One **OAuth client ID** per Android `applicationId` you want to test/ship (the app has three: `.dev`, `.staging`, and the prod one with no suffix — see the flavor table in [Build Variants](BUILD_VARIANTS.md)), each tied to a signing certificate fingerprint.
4. Optionally, an **iOS OAuth client ID** if you build for iOS.

None of this costs money for this use case — see the "Cost" section at the bottom.

## Step 1 — Create or select a Google Cloud project

1. Go to the [Google Cloud Console](https://console.cloud.google.com/) and sign in with the Google account you want to own this integration.
2. Create a new project (or reuse an existing one) — top-left project picker → **New Project**. Any name works; it's only shown to you as the developer, never to end users.

## Step 2 — Enable the Google Drive API

1. In the Cloud Console, go to **APIs & Services → Library**.
2. Search for **Google Drive API** and click **Enable**.

That's the only API this feature calls — no Sheets, no Gmail, nothing else.

## Step 3 — Configure the OAuth consent screen

1. **APIs & Services → OAuth consent screen**.
2. Choose **External** (unless every tester is inside a Google Workspace organization you control, in which case **Internal** avoids the verification concerns below entirely).
3. Fill in the app name (e.g. "Caravella"), your support email, and developer contact email. A privacy policy URL is required before you can publish beyond testing — this repo's is [`store/PRIVACY_POLICY.md`](../store/PRIVACY_POLICY.md); host it somewhere public (e.g. GitHub Pages) and link it here.
4. **Scopes**: add `.../auth/drive.appdata` (search for "Drive API" in the scope picker — pick the one whose description mentions "application data folder", *not* the broad `drive` or `drive.file` scopes; `drive.appdata` is the narrowest scope that can do what this feature needs, and narrow scopes go through Google's verification process with far less friction).
5. **Test users** (while the app is in "Testing" publishing status): add every Google account you'll sign in with during development — unlisted accounts get an "access blocked" error, not the "unverified app" warning.

### Do you need to "publish" / get verified?

- While your OAuth consent screen is in **Testing** status, only the test users you explicitly added can sign in, and they'll see an "unverified app" warning they have to click through (**Advanced → Go to Caravella (unsafe)**) — fine for development and for a small trusted group.
- To let *any* Google user sign in without that warning, you must submit the app for verification (**OAuth consent screen → Publish App**, then Google's review). For `drive.appdata` this is normally a lightweight review (no CASA security assessment — that only applies to broader "restricted" scopes like full Gmail/Drive access), but it still requires a privacy policy URL, a demo video showing the OAuth flow, and can take from a few days to a few weeks. Budget for this separately from the code — it's outside this repo's control.

## Step 4 — Create the Android OAuth client(s)

Each **(applicationId, signing certificate)** pair needs its own OAuth client. The app has three `applicationId`s (`android/app/build.gradle.kts`):

| Flavor | `applicationId` |
|---|---|
| `dev` | `io.caravella.egm.dev` |
| `staging` | `io.caravella.egm.staging` |
| `prod` | `io.caravella.egm` |

And two signing certificates in play:
- **Debug** — the shared Android debug keystore, used by plain `flutter run`/`flutter build apk` (no `--release`).
- **Release** — `android/app/build.gradle.kts`'s `signingConfigs.release`, sourced from `android/key.properties` (not committed — see whoever manages release signing for this project if you don't have it). Used for every flavor's `--release` build, including CI's staging APK build (see [CI Pipelines](CI_PIPELINES.md)).

You only need to register the combinations you'll actually use. For most local development, that's just `io.caravella.egm.dev` + your debug keystore.

### 4a. Get the SHA-1 fingerprint

**Debug keystore:**

```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

(On first `flutter run`, Android Studio/Gradle creates `~/.android/debug.keystore` automatically if it doesn't exist yet — run once before this command if the file is missing.)

**Release keystore** (values from `android/key.properties`):

```bash
keytool -list -v -keystore <storeFile from key.properties> -alias <keyAlias from key.properties>
```

Either command prints a `SHA1:` line like `AA:BB:CC:...` — copy it.

### 4b. Register the OAuth client

1. **APIs & Services → Credentials → Create Credentials → OAuth client ID**.
2. Application type: **Android**.
3. Package name: one of the three `applicationId`s above.
4. SHA-1 certificate fingerprint: from step 4a.
5. Create. Repeat for every (applicationId, keystore) combination you need.

**No client ID string goes into the app for Android** — `google_sign_in` resolves the right OAuth client automatically at runtime from the package name + the certificate the APK was actually signed with. If sign-in fails with `ApiException: 10` (`DEVELOPER_ERROR`), the package name/SHA-1 pair you registered doesn't match what you're running — the single most common setup mistake here.

## Step 5 — (Optional) iOS OAuth client

Only needed if you build for iOS — the app's Android build is the primary CI/release target (see [CI Pipelines](CI_PIPELINES.md)); iOS isn't currently built by CI.

1. **Credentials → Create Credentials → OAuth client ID → iOS**.
2. Bundle ID: match `ios/Runner.xcodeproj`'s `PRODUCT_BUNDLE_IDENTIFIER` for the scheme you're building.
3. Create — copy the generated **Client ID** (looks like `1234567890-abc...apps.googleusercontent.com`) and the **reversed client ID** shown right below it (`com.googleusercontent.apps.1234567890-abc...`).
4. Add the reversed client ID as a URL scheme in `ios/Runner/Info.plist`:
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
     <dict>
       <key>CFBundleURLSchemes</key>
       <array>
         <string>com.googleusercontent.apps.1234567890-abc...</string>
       </array>
     </dict>
   </array>
   ```
5. Pass the (non-reversed) client ID at build time — `GoogleDriveSyncFactory` reads it from `GOOGLE_DRIVE_IOS_CLIENT_ID` (see the build command below).

## Step 6 — Build with the flag

```bash
# Android, dev flavor, with Drive sync enabled
flutter run --flavor dev --dart-define=FLAVOR=dev --dart-define=ENABLE_GOOGLE_DRIVE_SYNC=true

# Android release build, staging flavor
flutter build apk --flavor staging --release \
  --dart-define=FLAVOR=staging \
  --dart-define=ENABLE_GOOGLE_DRIVE_SYNC=true

# iOS, with the client ID from Step 5
flutter run --dart-define=ENABLE_GOOGLE_DRIVE_SYNC=true \
  --dart-define=GOOGLE_DRIVE_IOS_CLIENT_ID=1234567890-abc...apps.googleusercontent.com
```

Omit `ENABLE_GOOGLE_DRIVE_SYNC` entirely (the normal F-Droid/default build) and none of this matters — `GoogleDriveSyncFactory.createCloudChannel()` returns `null`, the Cloud Sync section stays hidden, and `google_sign_in`/`googleapis` are never touched at runtime.

## Verifying it works

1. Build and run with the flag as above.
2. Settings → Data → Sync → **Cloud Sync** section should now be visible (it's hidden entirely when the flag is off).
3. Toggle **Enable cloud sync** → accept the privacy dialog → the Google sign-in picker should appear.
4. Sign in with a test user you added in Step 3. Success shows "Signed in as `<email>`" under the toggle.
5. On a group with sync enabled, tap **Sync now** — check the app logs (Settings → Debug Logs, or `adb logcat`) for `sync.channel.cloud.drive` entries confirming an upload/download round-trip.
6. To confirm data actually lands in `appDataFolder` (not visible in the normal Drive UI by design), use the [Drive API Explorer](https://developers.google.com/drive/api/v3/reference/files/list) with `spaces=appDataFolder` while signed in as the same test account.

## Troubleshooting

| Symptom | Likely cause |
|---|---|
| `PlatformException(sign_in_failed, ApiException: 10, ...)` | Android package name/SHA-1 doesn't match a registered OAuth client — redo Step 4, and double check you're signing with the keystore you think you are (`flutter run` vs `flutter build apk --release` use different ones by default) |
| "This app isn't verified" blocking screen with no way through | The signed-in Google account isn't in the OAuth consent screen's **Test users** list (Step 3) — publishing status is still "Testing" |
| Sign-in succeeds but uploads silently do nothing | Check `sync.channel.cloud.drive` logs — usually means the Drive API isn't enabled for the project (Step 2), or the scope granted doesn't match `drive.appdata` |
| iOS: nothing happens when tapping "Enable cloud sync" | Missing or mismatched `CFBundleURLSchemes` entry (Step 5.4), or `GOOGLE_DRIVE_IOS_CLIENT_ID` wasn't passed at build time |

## Cost

Free for this use case: Drive API calls aren't billed, the Cloud Console project itself is free, and shard data is stored against the *signed-in user's own* Drive storage quota — not a bucket you pay for. The only real cost is time: setting up the consent screen and, if you publish beyond a small test-user list, going through Google's (also free) verification review.

## See also

- [package reference](PACKAGE_GOOGLE_DRIVE_SYNC.md) — what the code actually does
- [Build Variants & Flavors](BUILD_VARIANTS.md) — `ENABLE_GOOGLE_DRIVE_SYNC` and every other dart-define
- [F-Droid Submission](FDROID_SUBMISSION.md) — why this stays off by default
- [caravella_core reference](PACKAGE_CARAVELLA_CORE.md) — the `CloudRelayChannel` interface this plugs into
