# Google Play Store Release Checklist

## Pre-Submission Requirements ✅

### App Configuration
- [x] **Package Name**: Updated to `io.github.calca.caravella` (proper reverse domain)
- [x] **Version Info**: Currently v1.0.33+35 (increment for release)
- [x] **Target SDK**: Using Flutter's default (ensure API 34+ for new apps)
- [x] **Permissions**: Properly documented and justified
- [x] **Signing**: Release signing configuration ready

### Privacy & Compliance  
- [x] **Privacy Policy**: Created and hosted at https://calca.github.io/caravella/privacy-policy.html
- [x] **Permission Usage**: All permissions documented with clear justification
- [x] **Data Safety**: Ready for Play Console Data Safety section
- [x] **Content Rating**: App suitable for Everyone rating
- [x] **GDPR Compliance**: Privacy policy covers all requirements

### Technical Requirements
- [x] **Android Manifest**: Updated with proper permissions and features
- [x] **Backup Rules**: Configured for app data backup
- [x] **Locale Support**: Configured for English and Italian
- [x] **Security**: Local data storage, no sensitive data exposure

## Required Artifacts

### Build Artifacts
- [ ] **Signed Release APK/AAB**: Build production signed app bundle
- [ ] **Testing**: Complete manual testing on target devices
- [ ] **Performance**: Verify app performance and memory usage

### Store Assets (Required)
- [ ] **App Icon**: High-resolution app icon (512x512 PNG)
- [ ] **Feature Graphic**: 1024x500 PNG for store listing
- [ ] **Screenshots**: At least 2 phone screenshots (16:9 ratio recommended)
  - Home screen with expense groups
  - Expense form with features highlighted
  - Settings/features overview
- [ ] **App Description**: Short (80 chars) and full description ready

### Optional Store Assets
- [ ] **Promotional Video**: 30-second feature showcase
- [ ] **Additional Screenshots**: Tablet screenshots if supporting tablets
- [ ] **Localized Descriptions**: Italian translations for descriptions

## Play Console Configuration

### App Information
- [ ] **App Name**: "Caravella"
- [ ] **Short Description**: "Modern group expense management for trips and shared costs"
- [ ] **Full Description**: Prepared marketing copy with features
- [ ] **Contact Email**: privacy@caravella.app
- [ ] **Website**: https://calca.github.io/caravella/
- [ ] **Privacy Policy URL**: https://calca.github.io/caravella/privacy-policy.html

### Content Rating
- [ ] **Target Audience**: Everyone
- [ ] **Content Rating Questionnaire**: Complete IARC questionnaire
- [ ] **Content Guidelines**: Verify compliance with Play policies

### Data Safety Section
Answer these questions based on our app:

**Does your app collect or share any of the required user data types?**
- Personal Info: ❌ No
- Financial Info: ✅ Yes - "Expense data stored locally only, never shared"
- Location: ✅ Yes - "Optional, user-initiated for expense context only"  
- Photos and Videos: ✅ Yes - "Optional, for backgrounds and attachments only"

**How is user data used?**
- App functionality: ✅ Core expense tracking features
- Analytics: ❌ No analytics or tracking
- Developer communications: ❌ No
- Advertising: ❌ No advertising
- Account management: ❌ No user accounts

**Data sharing:**
- ❌ No data shared with third parties

**Data security:**
- ✅ Data encrypted in transit: N/A (no network transmission)
- ✅ Users can request data deletion: Yes (app settings)
- ✅ Data handling practices follow Google Play policies

### App Signing
- [ ] **Play App Signing**: Enroll in Google Play App Signing
- [ ] **Upload Key**: Generate and securely store upload certificate
- [ ] **Key Security**: Follow Android keystore security best practices

## Testing Requirements

### Pre-Launch Testing
- [ ] **Internal Testing**: Test with internal team
- [ ] **Closed Testing**: Alpha/Beta testing with limited users
- [ ] **Device Compatibility**: Test on various Android versions and screen sizes
- [ ] **Permission Flows**: Test all permission request scenarios
- [ ] **Edge Cases**: Test with permissions denied, limited storage, etc.

### Feature Testing
- [ ] **Core Functionality**: Create groups, add expenses, calculations work
- [ ] **Optional Features**: Camera, location, file operations work correctly
- [ ] **Data Operations**: Import/export, backup/restore functions work
- [ ] **Localization**: Test English and Italian language support
- [ ] **Theme Support**: Test light/dark mode switching

## Release Strategy

### Phased Rollout (Recommended)
1. **Internal Testing** (Development team)
2. **Closed Alpha** (5-10 trusted users)
3. **Closed Beta** (20-50 users)
4. **Open Beta** (Optional, wider testing)
5. **Production Release** (Gradual rollout: 5% → 20% → 50% → 100%)

### Version Management
- **Current**: v1.0.33+35
- **Release**: v1.1.0+36 (increment for Play Store release)
- **Future**: Follow semantic versioning (major.minor.patch)

## Post-Launch Monitoring

### Metrics to Track
- [ ] **Crash Rate**: < 2% (Google Play requirement)
- [ ] **ANR Rate**: < 0.5% (Google Play requirement)  
- [ ] **User Reviews**: Monitor and respond to feedback
- [ ] **Performance**: App startup time, memory usage
- [ ] **Feature Usage**: Which optional features are most used

### Compliance Monitoring
- [ ] **Policy Updates**: Monitor Google Play policy changes
- [ ] **Security Updates**: Keep target SDK current
- [ ] **Privacy Compliance**: Monitor privacy regulation changes

## Emergency Procedures

### If Rejected
- [ ] **Review Rejection Reason**: Understand specific policy violation
- [ ] **Fix Issues**: Address all mentioned problems
- [ ] **Re-submit**: Update version and re-upload
- [ ] **Appeal Process**: If rejection seems incorrect

### Post-Launch Issues
- [ ] **Critical Bugs**: Hotfix process ready
- [ ] **Security Issues**: Emergency update procedure
- [ ] **Policy Violations**: Rapid response plan

## Success Criteria

### Technical Metrics
- ✅ Crash rate < 2%
- ✅ ANR rate < 0.5%
- ✅ App size < 100MB
- ✅ Startup time < 3 seconds

### Business Metrics
- 📊 User acquisition rate
- 📊 User retention (1-day, 7-day, 30-day)
- 📊 Feature adoption (camera, location usage)
- 📊 App store rating > 4.0

## Notes
- Package name cannot be changed after publication
- Privacy policy must be accessible and cannot return 404
- All permissions must be necessary and documented
- App must handle permission denials gracefully