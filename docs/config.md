# Configuration For iOS & Android

Google Maps + Location setup for `peng_houth_cycle`.

> [!WARNING]
> These are **native config changes** — hot reload will NOT pick them up.
> Always do a full `flutter run` (or stop and relaunch) after editing anything below.

---

# 1. Android

> Path: `android/app/src/main/AndroidManifest.xml`

### 1.1 Location Permission

Paste this **above** the `<application>` tag:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
```

### 1.2 Google Maps API Key

Paste this **inside** the `<application>` tag, next to the existing
`flutterEmbedding` meta-data (do NOT replace it — both must exist):

```xml
<meta-data
  android:name="com.google.android.geo.API_KEY"
  android:value="AIzaSyXXXXXXXXXXXXXXXXXXXXXXXX"/>
```

Real Google keys always start with `AIza...` — if yours doesn't, it's the wrong key.

### 1.3 (Optional) Hide Kotlin Warning

> Path: `android/gradle.properties`

```gradle
kotlin.jvm.target.validation.mode=warning
```

### Checklist — do NOT touch these (already in the template)

- `android:windowSoftInputMode="adjustResize"` → lives on the `<activity>` tag, ships by default
- `<meta-data android:name="flutterEmbedding" android:value="2"/>` → must stay, deleting it causes the "deleted Android v1 embedding" build error
- `android:name="${applicationName}"` on `<application>` → must stay

---

<br>

# 2. iOS

### 2.1 Podfile — minimum iOS version

> Path: `ios/Podfile`

Uncomment the first line and set it to **15.0** (google_maps_flutter_ios
requires it — 14.0 is not enough):

```ruby
platform :ios, '15.0'
```

### 2.2 Xcode project — deployment target

> Path: `ios/Runner.xcodeproj/project.pbxproj`

Change **every** occurrence (usually 3) of:

```
IPHONEOS_DEPLOYMENT_TARGET = 13.0;
```

to:

```
IPHONEOS_DEPLOYMENT_TARGET = 15.0;
```

Or via Xcode: open `ios/Runner.xcworkspace` → Runner target → General →
Minimum Deployments → **15.0**.

### 2.3 Location Permission

> Path: `ios/Runner/Info.plist`

Add inside the main `<dict>`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We use your location to show nearby bike stations.</string>
```

### 2.4 AppDelegate — Google Maps API Key

> Path: `ios/Runner/AppDelegate.swift`

Replace the file with this, and paste your real key into
`GMSServices.provideAPIKey`:

```swift
import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyXXXXXXXXXXXXXXXXXXXXXXXX")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
```

> [!WARNING]
> `GeneratedPluginRegistrant.register` must appear **only once** — inside
> `didInitializeImplicitFlutterEngine`. Adding a second call in
> `didFinishLaunchingWithOptions` causes the
> "This FlutterEngine was already invoked" crash.

---

# 3. Rebuild Commands

Run step by step from the project root:

```bash
flutter clean
flutter pub get
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
flutter run
```

If CocoaPods still complains about versions, add `pod repo update` before
`pod install`.

---

# 4. Full iOS Folder Reset (nuclear option)

Only if the ios folder is beyond saving. From the project root:

```bash
rm -rf ios
flutter create --platforms=ios .
```

Then re-apply **all of Section 2** (Podfile 15.0, deployment target,
Info.plist permission, AppDelegate key) and run Section 3.

---

# 5. Troubleshooting

| Symptom                                                   | Fix                                                                                                           |
| --------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------- |
| `requires a higher minimum deployment target`             | Sections 2.1 + 2.2, then Section 3                                                                            |
| `Cannot find 'GMSServices' in scope`                      | Missing `import GoogleMaps` in AppDelegate                                                                    |
| `This FlutterEngine was already invoked`                  | Duplicate `GeneratedPluginRegistrant.register` — see 2.4                                                      |
| `Build failed due to use of deleted Android v1 embedding` | `flutterEmbedding` meta-data missing — see Android checklist                                                  |
| Map shows blank/beige tiles                               | Wrong key, Maps SDK not enabled in Google Cloud, or billing not linked                                        |
| Blue dot / locate button missing on iOS                   | Info.plist permission missing (2.3), or simulator has no location set (Features → Location → Custom Location) |
| API timeout on first request                              | Render free tier cold start — wait ~60s or retry                                                              |
