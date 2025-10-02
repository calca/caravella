# F-Droid Quick Reference

This file provides a quick reference for F-Droid distribution of Caravella.

## Status
✅ Ready for F-Droid submission

## Files Prepared

### Root Level
- `metadata.yml` - Main F-Droid metadata file
- `CHANGELOG.md` - Version history

### Fastlane Structure
- `fastlane/metadata/android/en-US/` - English metadata
- `fastlane/metadata/android/it-IT/` - Italian metadata

Each language includes:
- `title.txt` - App name
- `short_description.txt` - 80 character summary
- `full_description.txt` - Detailed description
- `changelogs/44.txt` - Current version changelog
- `images/icon.png` - App icon
- `images/phoneScreenshots/*.png` - 5 screenshots

### Documentation
- `docs/FDROID_SUBMISSION.md` - Complete submission guide

## Quick Start

### To Submit to F-Droid (RFP Method)

1. Go to https://gitlab.com/fdroid/rfp/-/issues
2. Create new issue with title: "Caravella - Group Expense Manager"
3. Fill in:
   - App Name: Caravella
   - Source: https://github.com/calca/caravella
   - License: MIT
   - Categories: Money, Office
4. Wait for maintainer review

### Build Configuration

**Flavor**: prod  
**Build Command**: `flutter build apk --flavor prod --release --dart-define=FLAVOR=prod`  
**Output**: `build/app/outputs/flutter-apk/app-prod-release.apk`  
**Package Name**: `io.caravella.egm`

## Checklist

- [x] MIT License verified
- [x] All dependencies are FOSS
- [x] No tracking or analytics
- [x] Privacy policy available
- [x] Metadata files created
- [x] Screenshots prepared
- [x] Changelog created
- [x] Documentation complete
- [x] Permissions marked as optional
- [x] Build configuration defined

## Next Steps

1. Review [F-Droid Submission Guide](../docs/FDROID_SUBMISSION.md)
2. Submit RFP or create merge request
3. Respond to reviewer feedback
4. Monitor build status after acceptance

## Resources

- F-Droid RFP: https://gitlab.com/fdroid/rfp/-/issues
- F-Droid Data: https://gitlab.com/fdroid/fdroiddata
- Documentation: https://f-droid.org/docs/
- App Repository: https://github.com/calca/caravella

## Version Info

Current Version: 1.0.44+44  
Last Updated: 2025-01-XX
