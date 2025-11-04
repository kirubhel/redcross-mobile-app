# Release Build Instructions

## Building Release APK

1. **Build the release APK:**
   ```bash
   flutter build apk --release
   ```
   
   The APK will be generated at: `build/app/outputs/flutter-apk/app-release.apk`

2. **Build App Bundle (for Google Play Store):**
   ```bash
   flutter build appbundle --release
   ```
   
   The AAB will be generated at: `build/app/outputs/bundle/release/app-release.aab`

## Installing Release APK

1. **Install on connected device:**
   ```bash
   flutter install --release
   ```

2. **Or manually install the APK:**
   ```bash
   adb install build/app/outputs/flutter-apk/app-release.apk
   ```

## Important Notes

- The app is currently signed with debug keys. For production, you need to:
  1. Create a keystore file
  2. Configure signing in `android/app/build.gradle.kts`
  3. Add your keystore credentials to `android/key.properties`

- ProGuard/R8 is enabled for release builds to:
  - Shrink code size
  - Obfuscate code
  - Optimize performance

- Debug logging is disabled in release builds (using `kDebugMode` checks)

- The app name is set to "Demo" and uses the Red Cross logo

## Current Configuration

- **App Name:** Demo
- **Package ID:** com.example.red_cross_app
- **Version:** 1.0.0+1
- **Minify Enabled:** Yes
- **Shrink Resources:** Yes

