# Package Name Review and Recommendations

## Current Package Name
`org.app.caravella`

## Issues with Current Package Name
1. **Generic Domain**: "org.app" is a generic placeholder domain
2. **No Domain Ownership**: The domain "app.org" is not owned by the developer
3. **Play Store Concerns**: Google Play Store prefers meaningful package names
4. **Brand Consistency**: Package name should reflect actual brand/domain

## Recommended Package Names

### Option 1: GitHub-based (Recommended)
`io.github.calca.caravella`
- Uses GitHub domain which is verifiable
- Follows reverse domain naming convention
- Aligns with existing GitHub repository
- Clear ownership through GitHub account

### Option 2: Generic but Proper
`com.caravellaapp.android`
- Professional appearance
- Clear app identification
- Could be paired with future domain registration

### Option 3: Developer-based
`dev.calca.caravella`
- Uses .dev domain which is common for developers
- Short and clean
- Professional appearance

## Implementation Steps

### For GitHub-based Package Name (Recommended)

1. **Update Android Configuration**:
   ```kotlin
   // In android/app/build.gradle.kts
   defaultConfig {
       applicationId = "io.github.calca.caravella"
   }
   
   // Update flavors
   productFlavors {
       create("dev") {
           applicationIdSuffix = ".dev"
           // Results in: io.github.calca.caravella.dev
       }
       create("staging") {
           applicationIdSuffix = ".staging"
           // Results in: io.github.calca.caravella.staging
       }
       create("prod") {
           // Results in: io.github.calca.caravella
       }
   }
   ```

2. **Update Android Manifest**:
   ```xml
   <manifest xmlns:android="http://schemas.android.com/apk/res/android"
       package="io.github.calca.caravella">
   ```

3. **Update Native Android Code** (if any exists):
   - Rename package directories
   - Update imports and package declarations

## Migration Considerations

### For Existing Installations
- Package name change means new app installation
- Users will need to uninstall old version and install new
- Data will not transfer automatically (export/import required)

### For First Release
- No migration needed
- Use recommended package name from start

## Google Play Store Requirements

### Package Name Guidelines
✅ Must be unique across Google Play Store
✅ Should follow reverse domain name notation
✅ Should reflect app's brand or developer
✅ Cannot be changed after first publish
❌ Cannot use generic placeholders like "org.app"

### Verification Steps
1. **Domain Ownership**: While not required, having matching domain helps credibility
2. **GitHub Verification**: GitHub profile shows ownership of calca/caravella repository
3. **Consistency**: Package name should match developer information in Play Console

## Implementation Priority
**HIGH PRIORITY** - Package name cannot be changed after initial Google Play Store publication

## Recommended Action
Implement GitHub-based package name (`io.github.calca.caravella`) before first Play Store submission to avoid future migration issues.