# F-Droid Submission Guide for Caravella

This guide provides comprehensive instructions for submitting Caravella to F-Droid, the free and open-source Android app repository.

## Overview

F-Droid is a community-maintained catalog of free and open-source software (FOSS) applications for Android. Getting your app on F-Droid increases visibility among privacy-conscious users and demonstrates your commitment to open-source principles.

## Prerequisites

Before submitting to F-Droid, ensure:

1. ✅ **Open Source License**: Caravella uses MIT License (verified in `LICENSE` file)
2. ✅ **No Proprietary Dependencies**: All dependencies are FOSS-compatible
3. ✅ **Privacy-Friendly**: No tracking, analytics, or non-free network services
4. ✅ **Reproducible Builds**: Builds are deterministic and verifiable
5. ✅ **Source Code Available**: Hosted on GitHub at https://github.com/calca/caravella

## Files Created for F-Droid

The following files have been created to support F-Droid distribution:

### 1. Root Metadata File
- **File**: `metadata.yml`
- **Purpose**: Main F-Droid metadata describing the app
- **Location**: Repository root
- **Content**: App details, build configuration, categories, anti-features

### 2. Fastlane Metadata Structure
```
fastlane/metadata/android/
├── en-US/
│   ├── title.txt                    # App name
│   ├── short_description.txt        # 80 char summary
│   ├── full_description.txt         # Detailed description
│   ├── changelogs/
│   │   └── 44.txt                   # Version 1.0.44 changelog
│   └── images/
│       ├── icon.png                 # App icon (512x512 recommended)
│       └── phoneScreenshots/        # App screenshots
│           ├── 1.png
│           ├── 2.png
│           ├── 3.png
│           ├── 4.png
│           └── 5.png
└── it-IT/
    ├── title.txt
    ├── short_description.txt
    ├── full_description.txt
    ├── changelogs/
    │   └── 44.txt
    └── images/
        ├── icon.png
        └── phoneScreenshots/
            ├── 1.png
            ├── 2.png
            ├── 3.png
            ├── 4.png
            └── 5.png
```

### 3. Changelog
- **File**: `CHANGELOG.md`
- **Purpose**: Version history for users and F-Droid maintainers
- **Location**: Repository root

## Submission Process

### Option 1: Request for Packaging (RFP) - Recommended for First-Time Submissions

1. **Create an Issue on F-Droid GitLab**
   - Go to: https://gitlab.com/fdroid/rfp/-/issues
   - Click "New issue"
   - Use template "Request for Packaging"

2. **Provide Required Information**
   ```
   Title: Caravella - Group Expense Manager
   
   App Name: Caravella
   Short Description: Modern group expense management app for trips, shared costs, and participants
   
   Source Code: https://github.com/calca/caravella
   License: MIT
   Categories: Money, Office
   
   Description:
   Caravella is a modern Flutter application for managing group expenses with local-only 
   data storage, Material 3 UI, and multi-platform support. Perfect for group trips, 
   shared household expenses, and event cost tracking.
   
   Why it should be included:
   - 100% FOSS with MIT license
   - Privacy-focused with local-only data storage
   - No tracking, analytics, or proprietary dependencies
   - Active development and maintenance
   - Multi-language support (English, Italian, Spanish)
   ```

3. **Wait for Review**
   - F-Droid maintainers will review your request
   - They may ask questions or request changes
   - Respond promptly to feedback

### Option 2: Direct Merge Request (For Experienced Contributors)

1. **Fork F-Droid Data Repository**
   ```bash
   git clone https://gitlab.com/fdroid/fdroiddata.git
   cd fdroiddata
   ```

2. **Create Metadata File**
   - Copy the `metadata.yml` from this repository
   - Place it in `fdroiddata/metadata/io.caravella.egm.yml`
   - Adjust paths and commit references as needed

3. **Test Locally with fdroidserver**
   ```bash
   # Install fdroidserver
   pip install fdroidserver
   
   # Initialize
   fdroid init
   
   # Test build
   fdroid build io.caravella.egm
   ```

4. **Create Merge Request**
   - Push your changes to your fork
   - Create MR to fdroid/fdroiddata
   - Include build test results
   - Wait for maintainer review

## Build Configuration Details

### Flavor Selection
Caravella uses Flutter flavors. For F-Droid, we use the **prod** flavor:
- No debug information
- Production settings
- Optimized build
- Clean package name: `io.caravella.egm`

### Build Command
```bash
flutter build apk --flavor prod --release --dart-define=FLAVOR=prod
```

### Output Location
```
build/app/outputs/flutter-apk/app-prod-release.apk
```

### Signing
F-Droid signs all APKs with their own key, so the keystore configuration in the repository is not used for F-Droid builds.

## Dependency Verification

All dependencies in `pubspec.yaml` are FOSS-compatible:

| Dependency | License | F-Droid Compatible |
|------------|---------|-------------------|
| provider | MIT | ✅ |
| file_picker | MIT | ✅ |
| image_picker | Apache 2.0 | ✅ |
| path_provider | BSD-3-Clause | ✅ |
| shared_preferences | BSD-3-Clause | ✅ |
| url_launcher | BSD-3-Clause | ✅ |
| fl_chart | MIT | ✅ |
| uuid | MIT | ✅ |
| share_plus | BSD-3-Clause | ✅ |
| archive | MIT | ✅ |
| flag_secure | MIT | ✅ |
| geolocator | MIT | ✅ |
| geocoding | MIT | ✅ |
| intl | BSD-3-Clause | ✅ |
| timeago | MIT | ✅ |
| gpt_markdown | MIT | ✅ |

## Anti-Features

Caravella has **NO** anti-features according to F-Droid guidelines:
- ❌ No ads
- ❌ No tracking
- ❌ No non-free dependencies
- ❌ No non-free network services
- ❌ No non-free assets
- ❌ No upstream non-free components

## Permissions Justification

Document permissions for F-Droid reviewers:

1. **CAMERA** (optional)
   - Purpose: Take photos for group backgrounds and expense attachments
   - Declared as not required: `android:required="false"`
   - Can be denied without affecting core functionality

2. **ACCESS_FINE_LOCATION / ACCESS_COARSE_LOCATION** (optional)
   - Purpose: Add location context to expenses
   - Declared as not required: `android:required="false"`
   - Can be denied without affecting core functionality

3. **READ_EXTERNAL_STORAGE** (API ≤ 32)
   - Purpose: Select existing photos (legacy Android versions)
   - Modern versions use Android Photo Picker (no permission needed)

All permissions are optional and the app works fully without granting them.

## Privacy Policy

Privacy policy is available at:
- URL: https://calca.github.io/caravella/privacy-policy.html
- File: `store/PRIVACY_POLICY.md`

Key points:
- All data stored locally on device
- No data collection or transmission
- No third-party services
- Full user control over data
- GDPR compliant

## Reproducible Builds

To ensure build reproducibility:

1. **Pin Flutter Version**
   - CI uses stable channel (currently 3.35.1)
   - Lock file: `pubspec.lock` is committed

2. **No Build Date/Time**
   - No timestamps in build
   - Version from `pubspec.yaml` only

3. **Deterministic Dependencies**
   - All dependencies pinned in `pubspec.lock`
   - No dynamic version resolution during build

## Maintenance and Updates

### Version Updates
- Version format: `MAJOR.MINOR.PATCH+BUILD_CODE`
- Current: `1.0.44+44`
- Each release increments both version and build code
- Changelog updated for each version

### F-Droid Auto-Update
The metadata includes:
```yaml
AutoUpdateMode: Version
UpdateCheckMode: Tags
```

This allows F-Droid to automatically detect new versions when you:
1. Create a new release on GitHub
2. Tag it with format `vX.Y.Z`
3. F-Droid will pick it up and build automatically

### Release Process for F-Droid
1. Update `CHANGELOG.md` with new version changes
2. Update version in `pubspec.yaml`
3. Create changelog file: `fastlane/metadata/android/*/changelogs/NEW_VERSION_CODE.txt`
4. Commit and push changes
5. Create GitHub release with tag `vX.Y.Z`
6. F-Droid will automatically build and publish (if auto-update is enabled)

## Testing Before Submission

1. **Build APK Locally**
   ```bash
   flutter build apk --flavor prod --release --dart-define=FLAVOR=prod
   ```

2. **Install and Test**
   ```bash
   adb install build/app/outputs/flutter-apk/app-prod-release.apk
   ```

3. **Verify**
   - App installs correctly
   - All features work without internet
   - Permissions are optional
   - No crashes or errors
   - UI is responsive

4. **Check APK**
   ```bash
   # Check for non-free components
   unzip -l app-prod-release.apk | grep -i google
   
   # Verify signing
   apksigner verify --print-certs app-prod-release.apk
   ```

## Common Issues and Solutions

### Issue: Build Fails on F-Droid
**Solution**: Check that:
- All dependencies are in `pubspec.yaml`
- No local or git dependencies
- Flutter SDK version is compatible
- Build command is correct in metadata

### Issue: "Non-Free Dependencies" Warning
**Solution**: Verify all dependencies are FOSS:
- Check licenses on pub.dev
- Remove any proprietary dependencies
- Use FOSS alternatives if needed

### Issue: Permissions Not Optional
**Solution**: Ensure `AndroidManifest.xml` has:
```xml
<uses-feature android:name="android.hardware.camera" android:required="false" />
<uses-feature android:name="android.hardware.location" android:required="false" />
```

### Issue: Build Not Reproducible
**Solution**:
- Remove timestamps from build
- Commit `pubspec.lock`
- Use specific Flutter version
- Avoid platform-specific code generation

## Support and Resources

### F-Droid Documentation
- Main docs: https://f-droid.org/docs/
- Metadata format: https://f-droid.org/docs/Build_Metadata_Reference/
- Inclusion policy: https://f-droid.org/docs/Inclusion_Policy/

### F-Droid Community
- Forum: https://forum.f-droid.org/
- Matrix chat: #fdroid:f-droid.org
- GitLab issues: https://gitlab.com/fdroid/fdroiddata/-/issues

### Caravella Resources
- Repository: https://github.com/calca/caravella
- Issues: https://github.com/calca/caravella/issues
- Website: https://calca.github.io/caravella

## Timeline

Typical F-Droid submission timeline:
1. **RFP Creation**: Immediate
2. **Initial Review**: 1-7 days
3. **Build Testing**: 1-3 days
4. **Publication**: 1-2 days after approval
5. **Total**: 3-14 days (varies by reviewer availability)

## Post-Submission

After your app is accepted:

1. **Monitor F-Droid Build Status**
   - Check: https://f-droid.org/packages/io.caravella.egm
   - Watch for build failures

2. **Respond to User Feedback**
   - F-Droid users may report issues
   - Check F-Droid forum for feedback

3. **Keep Metadata Updated**
   - Update screenshots for major UI changes
   - Keep changelog current
   - Update descriptions as features change

4. **Maintain Auto-Update**
   - Continue using semantic versioning
   - Tag releases properly
   - Update changelog with each release

## Conclusion

Your F-Droid submission is ready! All necessary files are in place:
- ✅ metadata.yml
- ✅ fastlane metadata structure
- ✅ Screenshots
- ✅ Changelogs
- ✅ Privacy policy
- ✅ FOSS-compatible dependencies
- ✅ Optional permissions

Next steps:
1. Review this guide
2. Choose submission method (RFP recommended)
3. Submit to F-Droid
4. Respond to reviewer feedback
5. Celebrate when published! 🎉

For questions or issues with F-Droid submission, please open an issue at:
https://github.com/calca/caravella/issues
