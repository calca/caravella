# Google Places API Setup Guide

This guide explains how to configure the Google Places API for the location search feature in Caravella.

## Overview

Caravella uses the Google Places API to provide location search and autocomplete functionality when adding expenses. This allows users to search for and select locations more easily than manual text entry.

## Getting a Google Places API Key

1. **Go to Google Cloud Console**
   - Visit [Google Cloud Console](https://console.cloud.google.com/)
   - Create a new project or select an existing one

2. **Enable the Places API**
   - Navigate to "APIs & Services" > "Library"
   - Search for "Places API"
   - Click on it and press "Enable"

3. **Create API Credentials**
   - Go to "APIs & Services" > "Credentials"
   - Click "Create Credentials" > "API Key"
   - Copy the generated API key

4. **Restrict the API Key (Recommended)**
   - Click on the created API key to edit it
   - Under "Application restrictions", select "Android apps" or "iOS apps"
   - Add your app's package name and SHA-1 certificate fingerprint
   - Under "API restrictions", select "Restrict key" and choose "Places API"
   - Save the changes

## Configuration

### For Development

When running the app in development mode, set the API key as an environment variable:

```bash
flutter run --dart-define=GOOGLE_PLACES_API_KEY=your_api_key_here
```

### For Production Builds

For production builds, you should set the API key in your build configuration:

```bash
flutter build apk --dart-define=GOOGLE_PLACES_API_KEY=your_api_key_here
```

### CI/CD Configuration

For GitHub Actions or other CI/CD systems, add the API key as a secret:

1. Go to your repository Settings > Secrets and variables > Actions
2. Add a new secret named `GOOGLE_PLACES_API_KEY`
3. Update your workflow file to pass the key:

```yaml
- name: Build APK
  run: flutter build apk --dart-define=GOOGLE_PLACES_API_KEY=${{ secrets.GOOGLE_PLACES_API_KEY }}
```

## Without API Key

If no API key is provided, the location search feature will not work, but users can still:
- Use GPS to get their current location
- Manually enter location text
- Leave location empty

The app will continue to function normally, just without the search functionality.

## Cost Considerations

Google Places API has a generous free tier:
- First $200 of usage per month is free (covers ~28,500 autocomplete requests)
- After that, charges apply per request

For most personal and small group use cases, you should stay well within the free tier.

## Troubleshooting

### "API key not configured" message
- Ensure you've passed the `GOOGLE_PLACES_API_KEY` via `--dart-define`
- Check that the key is not empty or invalid

### Autocomplete not working
- Verify the Places API is enabled in your Google Cloud project
- Check API key restrictions (they might be blocking requests)
- Ensure your device has internet connectivity

### "REQUEST_DENIED" errors
- The API key might be restricted to specific apps/domains
- Add your app's package name and signing certificate to the restrictions
- Make sure the Places API is enabled for your project

## Alternative: F-Droid Build

For F-Droid builds that should not include Google services, the place picker dependency can be excluded. The app will fall back to GPS and manual entry only.

## Privacy Note

When using the Google Places API:
- Location searches are sent to Google servers
- Google's privacy policy applies to these requests
- No personal data beyond the search query is sent
- Users can always choose GPS or manual entry instead

For complete privacy, users can simply not configure the API key and rely on GPS/manual entry only.
