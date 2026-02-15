# Hello Multiplatform

A Kotlin Multiplatform project targeting Android and iOS, using Compose Multiplatform for shared UI.

## Project Structure

```
├── shared/          Kotlin Multiplatform shared module (common UI and logic)
├── androidApp/      Android application
└── iosApp/          iOS application (Xcode project)
```

## Building

### Android

```bash
# Debug APK
./gradlew :androidApp:assembleDebug

# Release APK
./gradlew :androidApp:assembleRelease
```

**Output locations:**
- Debug: `androidApp/build/outputs/apk/debug/androidApp-debug.apk`
- Release: `androidApp/build/outputs/apk/release/androidApp-release-unsigned.apk`

### iOS

Build the shared framework first, then build the app with Xcode:

```bash
# Build shared framework for iOS Simulator (arm64)
./gradlew :shared:linkDebugFrameworkIosSimulatorArm64

# Build shared framework for device
./gradlew :shared:linkReleaseFrameworkIosArm64
```

Then open `iosApp/iosApp.xcodeproj` in Xcode and build, or use the command line:

```bash
cd iosApp

# List available simulators to find a valid destination:
xcodebuild -scheme iosApp -showdestinations

# Then build with a matching destination, e.g.:
xcodebuild build \
  -project iosApp.xcodeproj \
  -scheme iosApp \
  -configuration Debug \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath build
```

**Output locations:**
- Simulator app: `iosApp/build/Build/Products/Debug-iphonesimulator/iosApp.app`
- Shared frameworks: `shared/build/bin/ios*/releaseFramework/`

## CI Artifacts

The GitHub Actions workflow (`.github/workflows/build.yml`) builds both platforms on every push to `main` and on pull requests. Build artifacts are uploaded and can be downloaded from the workflow run's **Artifacts** section in GitHub:

| Artifact | Contents | How to use |
|---|---|---|
| `android-apk` | Debug and release `.apk` files | Install on a device/emulator with `adb install <file>.apk` |
| `ios-app` | iOS simulator `.app` bundle | Drag into an open Simulator window, or install with `xcrun simctl install booted iosApp.app` |
| `ios-device-ipa` | Signed `.ipa` for real devices | Install via Apple Configurator, `ios-deploy`, or Finder drag-and-drop (requires signing secrets — see below) |
| `ios-frameworks` | Shared Kotlin/Native `.framework` binaries (all iOS architectures) | Build dependency only — used by Xcode when compiling the iOS app, not directly installable |

To download: go to **Actions** > select a workflow run > scroll to the **Artifacts** section at the bottom of the page.

### Setting up iOS device builds in CI

The `ios-device-ipa` artifact is only produced when iOS signing is configured. This requires an [Apple Developer Program](https://developer.apple.com/programs/) membership ($99/year).

**1. Create the required GitHub secrets** (Settings > Secrets and variables > Actions > Secrets):

| Secret | How to get it |
|---|---|
| `IOS_CERTIFICATE_BASE64` | Export your distribution certificate as a `.p12` from Keychain Access, then run `base64 -i certificate.p12` |
| `IOS_CERTIFICATE_PASSWORD` | The password you set when exporting the `.p12` |
| `IOS_PROVISIONING_PROFILE_BASE64` | Download an Ad Hoc provisioning profile from the Apple Developer portal, then run `base64 -i profile.mobileprovision` |
| `IOS_TEAM_ID` | Your 10-character Team ID (visible at [developer.apple.com/account](https://developer.apple.com/account) > Membership Details) |

**2. Create the required GitHub variable** (Settings > Secrets and variables > Actions > Variables):

| Variable | Value |
|---|---|
| `IOS_SIGNING_ENABLED` | `true` |
| `IOS_BUNDLE_ID` | *(optional)* Override the bundle ID — defaults to `com.example.hellomultiplatform.ios` |

**3. Register your test devices** in the Apple Developer portal under Devices, and include their UDIDs in the provisioning profile.

Once configured, every push to `main` or `claude/**` branches will produce a signed IPA you can install directly on registered devices.

## Running on a Physical iOS Device

If CI signing is not configured (see above), you can build locally. To run on a real iPhone or iPad:

1. Open `iosApp/iosApp.xcodeproj` in Xcode
2. Connect your device via USB (or set up wireless debugging)
3. Select your device from the destination dropdown
4. Go to **Signing & Capabilities** and select a team — a free Apple ID works for personal testing
5. Xcode may prompt you to trust the developer profile on your device: go to **Settings > General > VPN & Device Management** on the device and trust your profile
6. Press **Run** (Cmd+R)

> **Note:** A free Apple ID limits you to 3 app IDs per week and apps expire after 7 days. An [Apple Developer Program](https://developer.apple.com/programs/) membership ($99/year) removes these limits and is required for App Store or TestFlight distribution.

## Requirements

- JDK 17
- Android SDK (compileSdk 34, minSdk 24)
- Xcode 15+ (for iOS builds)
