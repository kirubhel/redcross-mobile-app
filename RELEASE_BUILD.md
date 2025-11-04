# Release Build Instructions

## Building Release APK

1. **Build the release APK:**
   ```bash
   flutter build apk --release --no-codesign
   ```
   
   Note: If you encounter Xcode license issues, the `--no-codesign` flag helps.
   
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

- ProGuard/R8 is currently disabled (minification can be enabled later with proper rules)
  - Code shrinking can be enabled by uncommenting settings in `android/app/build.gradle.kts`

- Debug logging is disabled in release builds (using `kDebugMode` checks)

- The app name is set to "Demo" and uses the Red Cross logo

## Building for iOS

### Prerequisites

1. **Apple Developer Account** (required for App Store distribution)
   - Sign up at [developer.apple.com](https://developer.apple.com)
   - Cost: $99/year for individual accounts

2. **macOS and Xcode** (required)
   - macOS 12.0 or later
   - Xcode 14.0 or later (latest version recommended)
   - Install from Mac App Store or [developer.apple.com/xcode](https://developer.apple.com/xcode)

3. **CocoaPods** (for iOS dependencies)
   ```bash
   sudo gem install cocoapods
   ```

4. **Flutter iOS Setup**
   ```bash
   flutter doctor
   # Make sure iOS toolchain shows as installed
   ```

### Step 1: Configure App Signing

1. **Open Xcode:**
   ```bash
   cd ios
   open Runner.xcworkspace
   # Note: Use .xcworkspace, not .xcodeproj
   ```

2. **Configure Signing & Capabilities:**
   - Select the "Runner" project in the left sidebar
   - Select the "Runner" target
   - Go to "Signing & Capabilities" tab
   - Check "Automatically manage signing"
   - Select your Team (Apple Developer account)
   - Xcode will automatically create/select provisioning profiles

3. **Update Bundle Identifier** (if needed):
   - Current: `com.example.redCrossApp`
   - Change to your unique identifier (e.g., `com.yourcompany.redcrossapp`)
   - In Xcode: Target → General → Bundle Identifier

### Step 2: Install iOS Dependencies

```bash
cd ios
pod install
cd ..
```

### Step 3: Build iOS Release

1. **Clean previous builds:**
   ```bash
   flutter clean
   flutter pub get
   ```

2. **Build iOS release (creates .app file):**
   ```bash
   flutter build ios --release
   ```
   
   The build will be at: `build/ios/iphoneos/Runner.app`

3. **Build iOS Archive (for App Store):**
   ```bash
   flutter build ipa --release
   ```
   
   The IPA will be at: `build/ios/ipa/red_cross_app.ipa`

### Step 4: Archive and Export via Xcode

1. **Open Xcode:**
   ```bash
   cd ios
   open Runner.xcworkspace
   ```

2. **Select Generic iOS Device or Any iOS Device** from the device selector (top toolbar)

3. **Create Archive:**
   - Product → Archive (or press Cmd+B then Archive)
   - Wait for build to complete
   - Organizer window will open automatically

4. **Distribute App:**
   - In Organizer, select your archive
   - Click "Distribute App"
   - Choose distribution method:
     - **App Store Connect** (for App Store)
     - **Ad Hoc** (for specific devices)
     - **Enterprise** (for enterprise distribution)
     - **Development** (for testing)

5. **Follow the wizard:**
   - Select distribution options
   - Choose signing certificate
   - Export the IPA file

### Step 5: TestFlight Distribution (Beta Testing)

1. **Upload to App Store Connect:**
   - Use Xcode Organizer → Distribute App → App Store Connect
   - Or use Transporter app (download from Mac App Store)
   - Or use command line: `xcrun altool --upload-app --file app.ipa --apiKey YOUR_KEY --apiIssuer YOUR_ISSUER`

2. **Configure in App Store Connect:**
   - Go to [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
   - Select your app
   - Go to TestFlight tab
   - Add internal/external testers
   - Submit for review (if external testing)

### Step 6: App Store Submission

1. **Prepare App Store Listing:**
   - App Store Connect → Your App → App Store
   - Fill in:
     - App name, subtitle, description
     - Screenshots (required for different device sizes)
     - App icon (1024x1024)
     - Privacy policy URL
     - Keywords, category, etc.

2. **Submit for Review:**
   - App Store Connect → Your App → App Store
   - Click "+ Version or Platform"
   - Select iOS
   - Enter version number
   - Upload build (from TestFlight or directly)
   - Fill in required information
   - Submit for review

### Alternative: Build IPA via Command Line

```bash
# Build and archive
flutter build ipa --release

# Or with specific export options
flutter build ipa --release \
  --export-options-plist=ios/ExportOptions.plist
```

### Install on Connected Device (Development)

```bash
# Build and install
flutter install

# Or via Xcode
# 1. Connect iPhone via USB
# 2. Select device in Xcode
# 3. Click Run (▶️)
```

### Current iOS Configuration

- **App Name:** Red Cross App
- **Bundle ID:** com.example.redCrossApp
- **Version:** 1.0.0+1 (from pubspec.yaml)
- **Minimum iOS Version:** 12.0
- **Supports:** iPhone and iPad

### Important Notes

- **Signing:** You must have a valid Apple Developer account and signing certificate
- **Bundle ID:** Must be unique and registered in your Apple Developer account
- **App Icons:** Make sure all required icon sizes are present in `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
- **Privacy Permissions:** If your app uses camera, location, etc., add descriptions in `Info.plist`
- **TestFlight:** First build may take longer to process (up to 2 hours)
- **App Store Review:** Typically takes 1-3 days

### Troubleshooting

**"No profiles for 'com.example.redCrossApp' were found":**
- Make sure you're signed in with Apple Developer account in Xcode
- Check "Automatically manage signing" is enabled
- Verify bundle identifier matches your App ID in Apple Developer portal

**"Code signing is required":**
- Select your team in Xcode → Signing & Capabilities
- Ensure you have a valid provisioning profile

**Build fails with CocoaPods errors:**
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter pub get
```

**Xcode license issues:**
```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -license accept
```

## Current Configuration

- **App Name:** Demo (Android) / Red Cross App (iOS)
- **Package ID:** com.example.red_cross_app (Android) / com.example.redCrossApp (iOS)
- **Version:** 1.0.0+1
- **Minify Enabled:** No (disabled to avoid R8 issues)
- **Shrink Resources:** No
- **Signing:** Debug keys (change for production)

